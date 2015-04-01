Transit++ for iOS
=====================================================

Transit++ for iOS requires iOS 7.0 and above.

PCF SDK Usage
--------------

[PCF Push 1.0.4](http://docs.pivotal.io/mobile/push/ios/)<br />
[PCF Data 1.1.0](http://docs.pivotal.io/mobile/data/ios/)<br />
[PCF Auth 1.0.0](http://docs.pivotal.io/mobile/data/ios/)<br />


Overview
------------------

The application included in this repository demonstrates some of the features in Pivotal CF Mobile Services.

You can use Transit++ to browse bus routes and stops, as well as setting an alarm to get push notifications for upcoming transit alerts.

When a user selects a bus route, stop number, and alarm time, a tag is generated and added to the list of tag subscriptions on the *PCF Push* server (`TTCPushRegistrationHelper`). The list of subscriptions is then synchronized with the data server via *PCF Data* (`TTCNotificationsTableViewController::persistDataToRemoteStore`). The data is synchronized every time the user updates the alarm settings.

When a fetch call is made and there is no authorized user, it will trigger *PCF Auth* to display a login screen (`TTCLoginViewController`).

Classes
------------------

`TTCLoginViewController` is a custom class that inherits from `PCFLoginViewController`, which provides methods from the PCF Auth library for password and auth code grant authentication flows.

`TTCPushRegistrationHelper` is a helper class for the Push SDK to handle push registrations and tag subscriptions.   

`TTCNotificationsTableViewController` uses a `PCFKeyValueObject` with a *Collection* and *Key* to fetch and update key-value pairs from the server. The `PCFKeyValueObject` is configured with values specified in `Pivotal.plist`, located in the root of the project.

`Pivotal.plist` should include the following:

*pivotal.push.serviceUrl<br />
pivotal.push.platformUuidDevelopment<br />
pivotal.push.platformSecretDevelopment<br />
pivotal.push.platformUuidProduction<br />
pivotal.push.platformSecretProduction<br /><br />
pivotal.auth.tokenUrl<br />
pivotal.auth.authorizeUrl<br />
pivotal.auth.redirectUrl<br />
pivotal.auth.clientId<br />
pivotal.auth.clientSecret<br /><br />
pivotal.data.serviceUrl<br />
pivotal.data.collisionStrategy<br />*