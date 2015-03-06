#!/usr/bin/env bash
cwd=$(pwd)
set -e


PUBLISH_SDK=0
COMMIT_MESSAGE=$(git show -s --format=%B $TRAVIS_COMMIT | tr -d '\n')
echo $COMMIT_MESSAGE
if test "${COMMIT_MESSAGE#*'[publish binary]'}" != "$COMMIT_MESSAGE"
then
    echo "PUBLISHING mapnik SDK"
    PUBLISH_SDK=1
else
    echo "NOT publishing"
fi



sudo pip install awscli

gitsha="$1"
date_time=`date +%Y%m%d%H%M`
maxtimeout=600
user_data="<powershell>
    ([ADSI]\"WinNT://./Administrator\").SetPassword(\"Diogenes1234\")
    Invoke-WebRequest https://gist.githubusercontent.com/BergWerkGIS/504a3a4964a48ba3ac03/raw/4da30ca32dbc3750656a9287a5dd9082dce86db8/build.bat -OutFile Z:\\build.bat
    & Z:\\build.bat
    [Environment]::SetEnvironmentVariable(\"PUBLISHMAPNIKSDK\", \"${PUBLISH_SDK}\", \"User\")
    [Environment]::SetEnvironmentVariable(\"AWS_ACCESS_KEY_ID\", \"${AWS_ACCESS_KEY_ID}\", \"User\")
    [Environment]::SetEnvironmentVariable(\"AWS_SECRET_ACCESS_KEY\", \"${AWS_SECRET_ACCESS_KEY}\", \"User\")
    </powershell>
    <persist>true</persist>"

id=$(aws ec2 run-instances \
    --region eu-central-1 \
    --image-id ami-ec390bf1 \
    --count 1 \
    --instance-type c3.4xlarge \
    --user-data "$user_data" | jq -r '.Instances[0].InstanceId')

echo "Created instance: $id"

dns=$(aws ec2 describe-instances --instance-ids i-45cd6b84 --region eu-central-1 --query "Reservations[0].Instances[0].PublicDnsName")
dns="${dns//\"/}"
echo "temporary windows build server: $dns/wbs"

aws ec2 create-tags --region eu-central-1 --resources $id --tags "Key=Name,Value=Temp-mapnik-windows-build-server-${TRAVIS_REPO_SLUG}-${TRAVIS_JOB_NUMBER}"
aws ec2 create-tags --region eu-central-1 --resources $id --tags "Key=GitSha,Value=$gitsha"

instance_status_stopped=$(aws ec2 describe-instances --region eu-central-1 --instance-id $id | jq -r '.Reservations[0].Instances[0].State.Name')
until [ "$instance_status_stopped" = "stopped" ]; do
    if [ `expr $(date "+%s") - $start_timestamp` -gt $maxtimeout ]; then
        echo "The instance has timed out. Terminating instance: $id"
        terminating_status=$(aws ec2 terminate-instances --region eu-central-1 --instance-ids $id | jq -r '.TerminatingInstances[0].CurrentState.Name')
        exit 1
    fi

    instance_status_stopped=$(aws ec2 describe-instances --region eu-central-1 --instance-id $id | jq -r '.Reservations[0].Instances[0].State.Name')
    echo "Instance stopping status eu-central-1 $id: $instance_status_stopped"
    sleep $sleep
done

terminating_status=$(aws ec2 terminate-instances --region eu-central-1 --instance-ids $id | jq -r '.TerminatingInstances[0].CurrentState.Name')
echo "Publish complete, terminating instance: $id"

exit 0
