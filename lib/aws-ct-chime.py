# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import os
import json
import boto3
import requests
from base64 import b64decode

def handler(event, context):
  # Format SNS notification as JSON for processing the Guardrail notification
  message = json.loads(event['Records'][0]['Sns']['Message'])
  
  # Determine if this is a notification of non compliance, rule violation and gather filtering criteria, if any
  compliance_type = message['detail']['newEvaluationResult']['complianceType']
  rule_name = message['detail']['newEvaluationResult']['evaluationResultIdentifier']['evaluationResultQualifier']['configRuleName']
  rule_filter = os.environ['RULE_NAME_FILTER']
  
  if (compliance_type == 'NON_COMPLIANT') and (rule_filter == 'ALL_RULES' or rule_name in rule_filter):
  
    # Collect information on the AWS Organizations Master Account
    client = boto3.client('organizations')
    aws_orgs= client.describe_organization()
    aws_master_account_id = aws_orgs['Organization']['MasterAccountId']
    aws_master_account_email = aws_orgs['Organization']['MasterAccountEmail']
    
    # Parse information on member account violation
    violation_time = message['time']
    account_id = message['detail']['awsAccountId'] 
    resource_type = message['detail']['newEvaluationResult']['evaluationResultIdentifier']['evaluationResultQualifier']['resourceType']
    resource_id = message['detail']['newEvaluationResult']['evaluationResultIdentifier']['evaluationResultQualifier']['resourceId']
    
    # Format and send notification to Webhook
    try:
      content = 'AWS Account Violation! \nTime of Violation: {0}  \nMaster Acccount, Owner Email: {1} \
                \nMaster Account Number: {2} \nAccount Number with Violation: {3} \nRule Violation: {4} \
                \nResource Type: {5} \nResource Id: {6}' \
                .format(violation_time, aws_master_account_email, aws_master_account_id, account_id, rule_name, \
                resource_type, resource_id) 
      # print('Content = ', content)  
      webhook_uri = os.environ['WEBHOOK']
      requests.post(url=webhook_uri, json={ 'Content': content })
      print('Notification sent to Webhook')
    except:
      print('Failed to deliver notification to Webhook!')
      
  else:
    print('Notification is not a Non Compliance Issue, please ignore.')


