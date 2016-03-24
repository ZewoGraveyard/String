import PackageDescription

let package = Package(
    name: "String",
    dependencies: [
        .Package(url: "https://github.com/Zewo/OS.git", majorVersion: 0, minor: 4)
    ]
)
