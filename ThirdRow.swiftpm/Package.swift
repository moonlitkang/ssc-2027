// swift-tools-version: 5.9
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "ThirdRow",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "ThirdRow",
            targets: ["AppModule"],
            bundleIdentifier: "com.kang.thirdrow",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .butterfly),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
