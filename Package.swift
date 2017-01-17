import PackageDescription

let package = Package(
    name: "AlertNotifications",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git", majorVersion: 2, minor: 0)
    ]
)
