import PackageDescription

let package = Package(
    name: "AlertNotifications",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/LoggerAPI", majorVersion: 1)
    ]
)
