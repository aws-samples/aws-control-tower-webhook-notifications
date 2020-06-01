#Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#SPDX-License-Identifier: MIT-0

[CmdletBinding()]
param (
    [Parameter(
        Mandatory=$true)]
    [string]
    $AWSAduitAccountNumber,

    [Parameter(
        Mandatory=$true)]
    [string]
    $WebHookURL,

    [Parameter()]
    [string]
    $RuleFilter = "ALL_RULES"
)

Write-Verbose -Message "Setting control tower notification stacks" -Verbose
Write-Verbose -Message "    Using AWS Account number: $AWSAduitAccountNumber" -Verbose
Write-Verbose -Message "    Using Webhook URL: $WebHookURL" -Verbose
Write-Verbose -Message "    Using Rule filter of: $RuleFilter" -Verbose

$commandLine = "sts assume-role --role-arn arn:aws:iam::$($AWSAduitAccountNumber):role/AWSControlTowerExecution --role-session-name CTNotifications"
Write-Verbose -Message "Running: " -Verbose
Write-Verbose -Message "    aws $commandLine" -Verbose

$outputFile = New-TemporaryFile
Start-Process -FilePath 'aws' -ArgumentList $commandLine -Verbose -NoNewWindow -Wait -RedirectStandardOutput $outputFile
$creds = Get-Content -Path $outputFile | 
    ConvertFrom-Json
Remove-Item -Path $outputFile

$Env:AWS_ACCESS_KEY_ID=$($creds.Credentials.AccessKeyId)
$Env:AWS_SECRET_ACCESS_KEY=$($creds.Credentials.SecretAccessKey)
$ENV:AWS_SESSION_TOKEN=$($creds.Credentials.SessionToken)

Write-Verbose -Message "Installing NPM dependencies" -Verbose
npm install

. .\lib\package.ps1

$regions = @(
    'us-east-1'
    'us-east-2'
    'us-west-2'
    )
foreach($region in $regions)
{

    Write-Verbose -Message "Processing Region: $region" -Verbose
    $Env:AWS_DEFAULT_REGION=$region
    Start-Process -FilePath 'cdk' -ArgumentList 'bootstrap' -NoNewWindow -Wait
    if($region -eq 'us-east-1')
    {
        Start-Process -FilePath 'cdk' -ArgumentList "deploy CtNotificationsStackRole --require-approval never" -NoNewWindow -Wait -WorkingDirectory $PSScriptRoot
    }
    Start-Process -FilePath 'cdk' -ArgumentList "deploy CtNotificationsStack --require-approval never  --parameters notificationWebhook=$WebHookURL --parameters notificationRuleFilter=$RuleFilter" -NoNewWindow -Wait -WorkingDirectory $PSScriptRoot
}

# Cleanup Session Variables
Push-Location -Path 'env:'
Remove-Item -Path AWS_ACCESS_KEY_ID -ErrorAction SilentlyContinue
Remove-Item -Path AWS_SECRET_ACCESS_KEY -ErrorAction SilentlyContinue
Remove-Item -Path AWS_SESSION_TOKEN -ErrorAction SilentlyContinue
Remove-Item -Path AWAWS_DEFAULT_REGIONS_ACCESS_KEY_ID -ErrorAction SilentlyContinue
Pop-Location