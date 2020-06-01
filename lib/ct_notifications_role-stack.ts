// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import * as cdk from '@aws-cdk/core';
import * as iam from '@aws-cdk/aws-iam'
import { Role, ServicePrincipal, Policy, ManagedPolicy } from '@aws-cdk/aws-iam';
import { CfnOutput } from '@aws-cdk/core';


export class CtNotificationsStackRole extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const notificationRole = new Role(this, 'ctNotificationRole',{
        assumedBy: new ServicePrincipal('lambda.amazonaws.com'),
        roleName: 'aws-CT-CustomChimeNotificationRole'
    })
   
    notificationRole.addManagedPolicy(
      ManagedPolicy.fromManagedPolicyArn(this,'AWSLambdaBasicExecutionRole',
      'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole')
    )

    notificationRole.addManagedPolicy(
      ManagedPolicy.fromManagedPolicyArn(this,'AWSOrganizationsReadOnlyAccess',
      'arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess')
    )
    
    new CfnOutput(this,"roleArn",{
      value: notificationRole.roleArn
    })
  }
}
