# Control Tower Notification Enabler

This cdk package installs a Lambda function, with an associated IAM role, and subscribes the Lambda
function to Control Tower aggregate security notifications. In the event of a Control Tower rule violation
(e.g. publicly accessible S3 bucket), the Lambda sends a notification to a web hook.

## Prerequisites
 - Admin access to the organization. This is used to assume the control tower role in the audit account
 - [AWS CDK](https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html) installed
 - Version 2 of the [AWS Cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

## MacOS / Linux
To enable the notifications on a mac or linux, run the `install.sh` script as an administrative user.
The script takes 3 parameters
1. The aws account account number
1. The webhook URL the notifications will be posted too
1. Optional name of Gaurdrail configRuleName(s) you want notification for. Separate multiple rules with comma. Use ALL_RULES for notifciation of all Guardrails 

sample command line:

    . install.sh 123456789012 https://mywebhookURL ALL_RULES

## Windows
To enable the notifications on a windows machine, from `install.ps1` from a powershell window.
The script takes 3 parameters
1. The aws account account number
1. The webhook URL the notifications will be posted too
1. Optional name of Gaurdrail configRuleName(s) you want notification for. Separate multiple rules with comma. Use ALL_RULES for notifciation of all Guardrails 

Sample command line:

    .\install.ps1 -AWSAduitAccountNumber '123456789012' -WebHookURL 'https://mywebhookURL.com/' -RuleFilter ALL_RULES
