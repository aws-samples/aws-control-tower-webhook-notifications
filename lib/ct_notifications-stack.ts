// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import * as cdk from '@aws-cdk/core';
import * as lambda from '@aws-cdk/aws-lambda'
import * as path from 'path';
import * as iam from '@aws-cdk/aws-iam';
import * as sns from '@aws-cdk/aws-sns'
import * as snsSubs from '@aws-cdk/aws-sns-subscriptions'
import { CfnParameter } from '@aws-cdk/core';

export class CtNotificationsStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const notificationRuleFilter = new CfnParameter(this,"notificationRuleFilter",{
      description: "Name of Gaurdrail configRuleName(s) you want notification for. Separate multiple rules with comma. Use ALL_RULES for notifciation of all Guardrails"
    })

    const notificationWebHook = new CfnParameter(this,"notificationWebhook",{
      description: "Webhook URL"
    })

    const notificationLambda = new lambda.Function(this, 'notificatinLambda', {
      functionName: "aws-CT-CustomChimeNotification",
      runtime: lambda.Runtime.PYTHON_3_8,
      handler: 'aws-ct-chime.handler',
      code: lambda.Code.fromAsset(path.join(__dirname, 'aws-ct-chime.zip')),
      timeout: cdk.Duration.seconds(10),
      role: iam.Role.fromRoleArn(this, "roleARn", cdk.Arn.format({
        service: 'iam',
        resource: 'role',
        region: '',
        resourceName: 'aws-CT-CustomChimeNotificationRole'
      }, cdk.Stack.of(this))),
      environment: {
        RULE_NAME_FILTER: notificationRuleFilter.valueAsString,
        WEBHOOK: notificationWebHook.valueAsString
      }
    })

    const controlTowerSnsTopic = cdk.Arn.format({
      service: 'sns',
      resource: 'aws-controltower-AggregateSecurityNotifications'
    }, cdk.Stack.of(this))

    notificationLambda.addPermission("notificationLambdaPermission", {
      principal: new iam.ServicePrincipal('sns.amazonaws.com'),
      action: 'lambda:InvokeFunction',
      sourceArn: cdk.Arn.format({
        service: 'sns',
        resource: 'aws-controltower-AggregateSecurityNotifications'
      }, cdk.Stack.of(this))
    })

    const notificationSNS = sns.Topic.fromTopicArn(this,'ctSNSTopic',controlTowerSnsTopic)
    notificationSNS.addSubscription(new snsSubs.LambdaSubscription(notificationLambda))
  
  }
}
