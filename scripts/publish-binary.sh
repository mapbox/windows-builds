#!/usr/bin/env bash
cwd=$(pwd)
set -e

gitsha="$1"
date_time=`date +%Y%m%d%H%M`
maxtimeout=600
user_data="<powershell>
    ([ADSI]\"WinNT://./Administrator\").SetPassword(\"Diogenes1234\")
    Invoke-WebRequest http://www.BergWerk-GIS.at/dl/mapbox/build.txt -OutFile Z:\\build.bat
    & Z:\\build.bat
    </powershell>
    <persist>true</persist>"

id=$(aws ec2 run-instances \
    --region eu-central-1 \
    --image-id ami-ec390bf1 \
    --count 1 \
    --instance-type c3.large \
    --user-data "$user_data")

echo "Created instance: $id"

aws ec2 create-tags --region eu-central-1 --resources $id --tags "Key=Name,Value=Temporary mapnik binary build instance"
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
