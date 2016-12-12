Alert Notification Service SDK
===============================

This SDK is for the consumption/usage of the Alert Notification service and not for administration of the service.

This SDK supports the proactive remediation of issues for applications running on the Bluemix cloud.

Swift Version
-------------

The Alert Notification SDK works with the `3.0.1` release version of the Swift binaries. You can download this version from [Swift.org](https://swift.org/download/#releases).

Usage
-----

In order to use this SDK, you need to add it to the dependencies in your application's `Package.swift` file.

    import PackageDescription

    let package = Package(
        name: "MyAlertEnabledSwiftProject",

        ...

        dependencies: [
            .Package(url: "https://github.com/IBM-Swift/alert-notification-sdk.git", majorVersion: 1),

            ...

        ])

Once the `Package.swift` file has been updated, import the `AlertNotifications` module into your project.

Credentials Setup
-----------------

In order to use all of the features of the Alert Notifications SDK, you need an instance of the Alert Notifications service (be aware that this is a paid service only). Once you have obtained an instance of this service, select it from your Bluemix dashboard, and then click the "Service Credentials" tab. Create a credential if you have not already.

Once you have a credential created, select "View Credentials" and take note of the information that appears there. You will need the entire `name` and `password` fields for your application, but **you should only use the `url` field up to and including `/api/`.** Do not include any portions of the `url` that come after that.

Using this information, you should create a `ServerCredentials` object in your application, which will be used in all functions that create, retrieve or delete alerts or messages.

    let credentials = ServerCredentials(url: "<url>", name: "<name>", password: "<password>")

API
---

### Alert

The `Alert` class is used to specify a single instance of an alert. An `Alert` has the following required properties:
* `summary` - A `String` that gives a short description of the alert.
* `location` - A `String` that describes the area where the condition that caused the alert occurred.
* `severity` - A property of type `Severity` that describes the severity of the alert.

An `Alert` can also be given these additional optional properties by the application:
* `id` - A `String` giving this alert a unique identifier, which is used for deduplication.
* `date` - A `Date` object indicating when the alert was raised.
* `status` - A property of type `AlertStatus` indicating whether or not the alert has been resolved. The default value is `.Problem`.
* `source` - A `String` indicating the source of the alert condition.
* `applicationsOrServices` - An array of `String`s, indicating which Bluemix applications or services are impacted by this alert.
* `URLs` - An array of `AlertURL` objects, to supply additional links associated with the alert.
* `details` - An array of `Detail` objects, to provide additional key-value pairs as details associated with the alert.
* `emailMessageToSend` - An `EmailMessage` object specifying an e-mail message to be sent to recipients when the alert is posted. It may optionally be formatted using Mustache templates.
* `SMSMessageToSend` - A `String` specifying an SMS message to be sent to recipients when the alert is posted. It may optionally be formatted using Mustache templates.
* `voiceMessageToSend` - A `String` specifying a voice message to be sent to recipients when the alert is posted. It may optionally be formatted using Mustache templates.

Lastly, an `Alert` object may contain several more properties when it is sent by the Alert Notification service. These cannot be set by the application.
* `shortId` - A shorter identifying `String` set by the Alert Notification service. This is the identifier that the application should use when attempting to call a `GET` or `DELETE` request on an alert.
* `notificationState` - A property of type `NotificationState` indicating where in the reporting process the alert currently resides.
* `firstOccurrence` - A `Date` object indicating when this alert was first sent.
* `lastNotified` - A `Date` object indicating when the last notification regarding this alert was sent.
* `internalTime` - A `Date` object indicating when this alert was posted.
* `expired` - A `Bool` indicating whether the alert is still valid or has expired. Expired alerts will not appear in the Alert Viewer UI.

All of the properties of an `Alert` are immutable. Once an `Alert` is created, it cannot be modified. The `Alert.Builder` class can be used to create a modified version of an existing `Alert`.

#### AlertURL

The `AlertURL` object is used to provide additional informative links alongside an alert, such as a link to a runbook. An `AlertURL` object has the following properties:
* `description` - A brief `String` description of the link.
* `URL` - A `String` containing the URL of the link.

An `AlertURL` only has one method, the constructor.

    AlertURL(description: String, URL: String)

#### Detail

The `Detail` object is used to provide additional details alongside an alert, in the form of key-value pairs. A `Detail` object has the following properties:
* `name` - A `String` indicating the detail name.
* `value` - A `String` indicating the corresponding value.

A `Detail` only has one method, the constructor.

    Detail(name: String, value: String)

#### EmailMessage

The `EmailMessage` object is used to specify an e-mail message to be sent along with an alert. An `EmailMessage` object has the following properties:
* `subject` - A `String` containing the subject line.
* `body` - A `String` containing the e-mail body.

An `EmailMessage` only has one method, the constructor.

    EmailMessage(subject: String, body: String)

#### Severity

The `Severity` type indicates the level of severity associated with an alert. The type is an enum with the following possible values, as seen in the [Alert Notification service documentation](https://console.ng.bluemix.net/docs/services/AlertNotification/index.html?pos=2):
* `.Fatal` - A service-terminating condition has occurred. Immediate action is required.
* `.Critical` - A service-affecting condition has occurred, and corrective action is immediately required. For example, a device has gone out of service and needs to be restored.
* `.Major` - A service-affecting problem occurred. Corrective action is urgently required. For example, a severe degradation occurred in the capability of a device and full capability must be restored.
* `.Minor` - A non-service affecting problem occurred; take corrective action to prevent alerts of higher severity. For example, a problem occurred on a device but it does not impair the capacity or performance of the device.
* `.Warning` - Potential or impending problems were detected. Further investigation is needed to prevent alerts of higher severity.
* `.Indeterminate` - The severity level cannot be determined from the device.
* `.Clear` - Indicates that the alert was resolved, either manually by an operator, or automatically by a process that determined the fault condition no longer exists.

#### AlertStatus

The `AlertStatus` type indicates whether or not an alert has been acknowledged or reesolved. The type is an enum with the following possible values:
* `.Problem` - The alert has been posted but no action has been taken.
* `.Acknowledged` - The alert has been seen and acknowledged, and action is being taken to resolve it.
* `.Resolved` - The alert has been resolved.

#### NotificationState

The `NotificationState` type indicates in greater detail if users have been alerted to the problem. The type is an enum with the following possible values:
* `.Unnotified` - Alert Notification has received the alert but no notification was generated. Indicates that an alert does not match any existing notification policy.
* `.Notified` - Alert Notification has matched the alert to a notification policy and triggered a notification, which was sent to the users or groups defined in the notification policy. No contact has yet acknowledged the alert. Indicates that no one is working on an alert.
* `.Acknowledged` - Indicates to Alert Notification that the alert is being worked on. A contact has acknowledged the alert, either from the notification or in the Alert Viewer. Alerts can switch between the acknowledged and unacknowledged states, for example, if an alert was mistakenly acknowledged.
* `.Escalated` - A time period specified in the notification policy has passed without the alert being acknowledged. An escalation notification has been sent to the users or groups defined in the notification policy.
* `.Archived` - The alert is currently archived. An alert API request with a Type = Resolution converts the alert into an Archived state. When an incoming alert deduplicates an existing alert that is older than eight hours, the existing alert is archived (not the incoming alert).

### Alert.Builder

Because the `Alert` class has so many properties, a builder class has been provided. The `Alert.Builder` class is currently the only way to create an `Alert` object, or to modify an existing `Alert` (which will create a new one, as `Alert` objects are immutable). A builder has two different constructors:
* `Alert.Builder()` - Creates a new builder with all properties initialized to nil.
* `Alert.Builder(from: Alert)` - Creates a new builder with all properties initialized to the values they have in the provided `Alert`.

While building, the following methods will set certain properties:
* `setSummary(_: String)`
* `setLocation(_: String)`
* `setSeverity(_: Severity)`
* `setID(_: String)`
* `setDate(_: Date)`
* `setDate(fromString: String)` - Creates a `Date` object from a formatted date string. The string must have the format `yyyy-MM-dd HH:mm:ss`.
* `setDate(fromIntInMilliseconds: Int)` - Creates a `Date` object from an integer indicating the number of milliseconds since the epoch.
* `setStatus(_: AlertStatus)`
* `setSource(_: String)`
* `setApplicationsOrServices(_: [String])`
* `setURLs(_: [AlertURL])`
* `setDetails(_: [Detail])`
* `setEmailMessageToSend(_: EmailMessage)`
* `setSMSMessageToSend(_: String)`
* `setVoiceMessageToSend(_: String)`

Each of the above methods returns an `Alert.Builder` object, so they can be chained together such as in the following example:

    Alert.Builder().setSummary("summary").setLocation("location").setSeverity(.Fatal).build()

When all of the desired properties are set, the `build()` function will complete the build and return an `Alert` object. If the `summary`, `location` or `severity` variables are not set, `build()` will return `nil`.

### AlertService

The `AlertService` class is a static class used to create, retrieve and delete alerts from the Alert Notification service. All of the API functions are asynchronous, so callback functions must be provided if the application is to use the data returned from them. In order to authenticate with the service, a `ServerCredentials` object is required for all functions (see "Credentials Setup" above). The following methods are provided:

    AlertService.post(_: Alert, usingCredentials: ServerCredentials, callback: ((Alert?, Error?) -> Void)? = nil) throws

Posts a provided `Alert` object to the Alert Notification service. The service returns an `Alert` object with additional fields initialized, such as `shortId`. While optional, a callback function with the signature `(Alert?, Error?) -> Void` must be included in order to view this returned alert or any possible errors. This method only throws errors that occur before the underlying POST request is made, or while making the request; any errors that occur after this point are passed through the callback function.

    AlertService.get(shortId: String, usingCredentials: ServerCredentials, callback: (Alert?, Error?) -> Void) throws

Retrieves an `Alert` object from the Alert Notification service corresponding to the provided `shortId` parameter. Note that this is not the same as the `id` parameter that is used for deduplication. Unlike the `post` function, a callback function with the signature `(Alert?, Error?) -> Void` is required for this method. This method only throws errors that occur before the underlying GET request is made, or while making the request; any errors that occur after this point are passed through the callback function.

    AlertService.delete(shortId: String, usingCredentials: ServerCredentials, callback: ((Error?) -> Void)? = nil) throws

Deletes an `Alert` object from the Alert Notification service corresponding to the provided `shortId` parameter. Note that this is not the same as the `id` parameter that is used for deduplication. An optional callback function with the signature `(Error?) -> Void` is required to view errors that may return from the Alert Notification service. This method only throws errors that occur before the underlying DELETE request is made, or while making the request; any errors that occur after this point are passed through the callback function.

### Message

The `Message` class is used to specify a single instance of a message related to alerts and alert notifications. A `Message` has the following required properties:
* `subject` - A `String` that acts as the subject line of the message. This can be no more than 80 characters long.
* `message` - A `String` that acts as the body of the message. This can be no more than 1500 characters long.
* `recipient` - An array of `Recipient` objects that specifies which people, groups or integrations are to receive the message.

A `Message` may contain two more properties when it is sent by the Alert Notification service. These cannot be set by the application.
* `shortId` - A shorter identifying `String` set by the Alert Notification service. This is the identifier that the application should use when attempting to call a `GET` request on a message.
* `internalTime` - A `Date` object indicating when this message was posted.

All of the properties of a `Message` are immutable. Once a `Message` is created, it cannot be modified.

Unlike the `Alert` class, the `Message` class does not have a builder, and uses a simple constructor. If the length restrictions on `subject` or `message` are violated, the constructor will return `nil`.

    Message?(subject: String, message: String, recipients: [Recipient])

#### Recipient

The `Recipient` object is used to specify a person, group or integration that is to receive the message. A `Recipient` object has the following properties:
* `name` - A `String` specifying the name of the recipient.
* `type` - A `RecipientType` property indicating which kind of recipient this is (see `RecipientType` below).
* `broadcast` - A `String` used to indicate which integration this recipient is intended to hook into. This property is only required if the `type` is `.Integration`.

A `Recipient` only has one method, the constructor. If the `type` is `.Integration` and the `broadcast` property is `nil`, this constructor will return `nil`.

    Recipient?(name: String, type: RecipientType, broadcast: String? = nil)

#### RecipientType

The `RecipientType` type indicates which kind of recipient a `Recipient` object is intended for. The type is an enum with the following possible values:
* `.User` - An individual user.
* `.Group` - A user group.
* `.Integration` - An integrated service such as Slack.

### MessageService

The `MessageService` class is a static class used to create and retrieve messages from the Alert Notification service. All of the API functions are asynchronous, so callback functions must be provided if the application is to use the data returned from them. In order to authenticate with the service, a `ServerCredentials` object is required for all functions (see "Credentials Setup" above). The following methods are provided:

    MessageService.post(_: Message, usingCredentials: ServerCredentials, callback: ((Message?, Error?) -> Void)? = nil) throws

Posts a provided `Message` object to the Alert Notification service. The service returns a `Message` object with additional fields initialized, such as `shortId`. While optional, a callback function with the signature `(Message?, Error?) -> Void` must be included in order to view this returned message or any possible errors. This method only throws errors that occur before the underlying POST request is made, or while making the request; any errors that occur after this point are passed through the callback function.

    MessageService.get(shortId: String, usingCredentials: ServerCredentials, callback: (Message?, Error?) -> Void) throws

Retrieves a `Message` object from the Alert Notification service corresponding to the provided `shortId` parameter. Note that this is not the same as the `id` parameter that is used for deduplication. Unlike the `post` function, a callback function with the signature `(Message?, Error?) -> Void` is required for this method. This method only throws errors that occur before the underlying GET request is made, or while making the request; any errors that occur after this point are passed through the callback function.

License
-------

This Swift package is licensed under Apache 2.0. Full license text is available in [LICENSE](../blob/master/LICENSE).
