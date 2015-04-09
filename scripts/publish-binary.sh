#!/usr/bin/env bash
cwd=$(pwd)
set -e


BUILD32BIT=""
FASTBUILD="\$env:FASTBUILD=1"
PACKAGEDEBUGSYMBOLS="\$env:PACKAGEDEBUGSYMBOLS=0"
PUBLISH_SDK=0
PUBLISH_NODEGDAL="\$env:PUBLISH_NODEGDAL=0"
BUILD_CMD="wbs-build.ps1"
STOP_COMPUTER="Stop-Computer"
COMMIT_MESSAGE=$(git show -s --format=%B $TRAVIS_COMMIT | tr -d '\n')
echo $COMMIT_MESSAGE
if test "${COMMIT_MESSAGE#*'[publish binary]'}" != "$COMMIT_MESSAGE"
then
    echo "PUBLISHING mapnik SDK"
    PUBLISH_SDK=1
else
    echo "NOT publishing"
fi
if test "${COMMIT_MESSAGE#*'[publish debug]'}" != "$COMMIT_MESSAGE"
then
    echo "Commit includes [publish debug] skipping stack teardown."
    BUILD_CMD="wbs-build-prepare.ps1"
    STOP_COMPUTER=""
fi

if test "${COMMIT_MESSAGE#*'[build32bit]'}" != "$COMMIT_MESSAGE"
then
    echo "building 32bit, too."
    BUILD32BIT="\$env:BUILD32BIT=1"
fi

if test "${COMMIT_MESSAGE#*'[nofastbuild]'}" != "$COMMIT_MESSAGE"
then
    echo "doing a full build."
    FASTBUILD="\$env:FASTBUILD=0"
fi

if test "${COMMIT_MESSAGE#*'[packagedebugsymbols]'}" != "$COMMIT_MESSAGE"
then
    echo "packaging debug symbols."
    PACKAGEDEBUGSYMBOLS="\$env:PACKAGEDEBUGSYMBOLS=1"
fi

if test "${COMMIT_MESSAGE#*'[publish node-gdal]'}" != "$COMMIT_MESSAGE"
then
    echo "publishing just node-gdal."
    PUBLISH_NODEGDAL="\$env:PUBLISH_NODEGDAL=1"
fi

sudo pip install awscli

gitsha="$1"
sleep=10
date_time=`date +%Y%m%d%H%M`
start_timestamp=`date +"%s"`
maxtimeout=2880
region="eu-central-1"
ami_id="ami-3690a22b"

user_data="<powershell>
    ([ADSI]\"WinNT://./Administrator\").SetPassword(\"${CRED}\");
    ${BUILD32BIT}
    ${FASTBUILD}
    ${PACKAGEDEBUGSYMBOLS}
    ${PUBLISH_NODEGDAL}
    \$env:PUBLISHMAPNIKSDK=${PUBLISH_SDK};
    \$env:AWS_ACCESS_KEY_ID=\"${PUBLISH_KEY}\";
    \$env:AWS_SECRET_ACCESS_KEY=\"${PUBLISH_ACCESS}\";
    Invoke-WebRequest https://mapbox.s3.amazonaws.com/windows-builds/windows-build-server/${BUILD_CMD} -OutFile Z:\\${BUILD_CMD};
    & Z:\\${BUILD_CMD}
    ${STOP_COMPUTER}
    </powershell>
    <persist>true</persist>"

id=$(aws ec2 run-instances \
    --instance-initiated-shutdown-behavior terminate \
    --region $region \
    --image-id $ami_id \
    --count 1 \
    --instance-type c3.4xlarge \
    --user-data "$user_data" | jq -r '.Instances[0].InstanceId')

echo "Created instance: $id"

aws ec2 create-tags --region $region --resources $id --tags "Key=Name,Value=Temp-mapnik-windows-build-server-${TRAVIS_REPO_SLUG}-${TRAVIS_JOB_NUMBER}"
aws ec2 create-tags --region $region --resources $id --tags "Key=GitSha,Value=$gitsha"

dns=''
instance_status_stopped=$(aws ec2 describe-instances --region $region --instance-id $id | jq -r '.Reservations[0].Instances[0].State.Name')
until [ "$instance_status_stopped" = "stopped" ]; do
    if [ `expr $(date "+%s") - $start_timestamp` -gt $maxtimeout ]; then
        echo "The instance has timed out. Terminating instance: $id"
        terminating_status=$(aws ec2 terminate-instances --region $region --instance-ids $id | jq -r '.TerminatingInstances[0].CurrentState.Name')
        exit 1
    fi

    instance_status_stopped=$(aws ec2 describe-instances --region $region --instance-id $id | jq -r '.Reservations[0].Instances[0].State.Name')
    echo "Instance stopping status eu-central-1 $id: $instance_status_stopped"

    if [[ -z $dns ]]; then
        dns=$(aws ec2 describe-instances --instance-ids $id --region $region --query "Reservations[0].Instances[0].PublicDnsName")
        dns="${dns//\"/}"
        echo "temporary windows build server: $dns/wbs"
    fi;
    if [[ ${#dns} -gt 1 ]]; then
        instance_status_stopped="stopped"
    fi;

    sleep $sleep
done

#terminating_status=$(aws ec2 terminate-instances --region $region --instance-ids $id | jq -r '.TerminatingInstances[0].CurrentState.Name')
#echo "Publish complete, terminating instance: $id"

echo "build takes longer than 50 minutes"
echo "exiting travis build"
echo "instance will self-terminate, when finished"


exit 0
