import { expect as expectCDK, matchTemplate, MatchStyle } from '@aws-cdk/assert';
import * as cdk from '@aws-cdk/core';
import * as CtNotifications from '../lib/ct_notifications-stack';

test('Empty Stack', () => {
    const app = new cdk.App();
    // WHEN
    const stack = new CtNotifications.CtNotificationsStack(app, 'MyTestStack');
    // THEN
    expectCDK(stack).to(matchTemplate({
      "Resources": {}
    }, MatchStyle.EXACT))
});
