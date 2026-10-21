// swift-tools-version: 5.9
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "ThirdRow",
    platforms: [
        // 16.0 rather than 17.0: the author's own iPhone runs iOS 16.7 and has to
        // be able to sideload this. Nothing in the code needs an iOS 17 API.
        .iOS("16.0")
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
