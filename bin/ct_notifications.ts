#!/usr/bin/env node
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import 'source-map-support/register';
import * as cdk from '@aws-cdk/core';
import { CtNotificationsStackRole } from '../lib/ct_notifications_role-stack'
import { CtNotificationsStack } from '../lib/ct_notifications-stack';

const app = new cdk.App();
new CtNotificationsStack(app, 'CtNotificationsStack');
new CtNotificationsStackRole(app, 'CtNotificationsStackRole')
