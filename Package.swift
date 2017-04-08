import PackageDescription

let package = Package(
    name: "jarvis-vapor",
    targets: [
        Target(name: "App", dependencies: ["Jarvis"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

