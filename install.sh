# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#!/bin/sh

if [ "$#" = "0" ]
  then 
    echo "Sample Usuage:"
    echo ". install.sh <AWS Audit Account Number> <Webhook URL> <(Optional) Notification Rule Filter>"
    return 1
fi

export AWS_AUDIT_ACCOUNT=$1
echo "Setting AWS Audit Account Number to: $AWS_AUDIT_ACCOUNT" 

if [ "$2" = '' ]
  then
    echo "Please enter your webhook url: "
    read WEBHOOK_URL
  else
    export WEBHOOK_URL=$2
fi
echo "Using webhook url of: $WEBHOOK_URL"

if [ "$3" = '' ]
  then 
    export RULE_FILTER="ALL_RULES"
  else
    export RULE_FILTER=$3
fi
echo "Using rule fitler: $RULE_FILTER"

npm install
sh ./lib/package.sh

creds=$(aws sts assume-role --role-arn arn:aws:iam::$AWS_AUDIT_ACCOUNT:role/AWSControlTowerExecution --role-session-name 'CTNotifications')
AccessKeyId=$(echo $creds | jq '.[].AccessKeyId' -r | head -n 1)
SecretAccessKey=$(echo $creds | jq '.[].SecretAccessKey' -r | head -n 1)
SessionToken=$(echo $creds | jq '.[].SessionToken' -r | head -n 1)

export AWS_ACCESS_KEY_ID=$AccessKeyId
export AWS_SECRET_ACCESS_KEY=$SecretAccessKey
export AWS_SESSION_TOKEN=$SessionToken

declare -a regions=("us-east-1" "us-east-2" "us-west-2")
for region in "${regions[@]}" 
    do 
        export AWS_DEFAULT_REGION=$region
        cdk bootstrap
        
        if [ $region = "us-east-1" ] 
          then
          cdk deploy CtNotificationsStackRole --require-approval never
        
        fi
        
        cdk deploy CtNotificationsStack --require-approval never  --parameters notificationWebhook=$WEBHOOK_URL --parameters notificationRuleFilter=$RULE_FILTER
done

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
