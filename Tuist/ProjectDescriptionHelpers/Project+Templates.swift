import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

//extension Project {
//    /// Helper function to create the Project for this ExampleApp
//    public static func app(name: String, destinations: Destinations, additionalTargets: [String]) -> Project {
//        var targets = makeAppTargets(name: name,
//                                     destinations: destinations,
//                                     dependencies: additionalTargets.map { TargetDependency.target(name: $0) })
//        targets += additionalTargets.flatMap({ makeFrameworkTargets(name: $0, destinations: destinations) })
//        return Project(name: name,
//                       organizationName: "tuist.io",
//                       targets: targets)
//    }
//
//    // MARK: - Private
//
//    /// Helper function to create a framework target and an associated unit test target
//    private static func makeFrameworkTargets(name: String, destinations: Destinations) -> [Target] {
//        let sources = Target(name: name,
//                destinations: destinations,
//                product: .framework,
//                bundleId: "io.tuist.\(name)",
//                infoPlist: .default,
//                sources: ["Targets/\(name)/Sources/**"],
//                resources: [],
//                dependencies: [])
//        let tests = Target(name: "\(name)Tests",
//                destinations: destinations,
//                product: .unitTests,
//                bundleId: "io.tuist.\(name)Tests",
//                infoPlist: .default,
//                sources: ["Targets/\(name)/Tests/**"],
//                resources: [],
//                dependencies: [.target(name: name)])
//        return [sources, tests]
//    }
//
//    /// Helper function to create the application target and the unit test target.
//    private static func makeAppTargets(name: String, destinations: Destinations, dependencies: [TargetDependency]) -> [Target] {
//        let infoPlist: [String: Plist.Value] = [
//            "CFBundleShortVersionString": "1.0",
//            "CFBundleVersion": "1",
//            "UILaunchStoryboardName": "LaunchScreen"
//            ]
//
//        let mainTarget = Target(
//            name: name,
//            destinations: destinations,
//            product: .app,
//            bundleId: "io.tuist.\(name)",
//            infoPlist: .extendingDefault(with: infoPlist),
//            sources: ["Targets/\(name)/Sources/**"],
//            resources: ["Targets/\(name)/Resources/**"],
//            dependencies: dependencies
//        )
//
//        let testTarget = Target(
//            name: "\(name)Tests",
//            destinations: destinations,
//            product: .unitTests,
//            bundleId: "io.tuist.\(name)Tests",
//            infoPlist: .default,
//            sources: ["Targets/\(name)/Tests/**"],
//            dependencies: [
//                .target(name: "\(name)")
//        ])
//        return [mainTarget, testTarget]
//    }
//}

import ProjectDescription
import ProjectDescriptionHelpers

public extension Project {
    static func makeModule(
        name: String,
        organizationName: String = "com.app",
        packages: [Package] = [],
        targets : [Target]
    ) -> Project {
        let settings: Settings = .settings(
            base: [:],
            configurations: [
                .debug(name: .debug),
                .release(name: .release)
            ], defaultSettings: .recommended)
        
        var schemeTargetName : String = name
        if let target = targets.first {
            schemeTargetName = target.name
        }
        var schemes : [Scheme] = [.makeScheme(target: .debug, name: schemeTargetName),
                                 .makeScheme(target: .release, name: schemeTargetName)]
        
        
        
        var targets: [Target] = targets
        
        return Project(
            name: name,
            organizationName: organizationName,
            packages: packages,
            settings: settings,
            targets: targets,
            schemes: schemes
        )
    }
    
    static func makeApp(
        name: String,
        platform: Platform = .iOS,
        organizationName: String = "com.app",
        packages: [Package] = [],
        deploymentTarget: DeploymentTarget? = .iOS(targetVersion: "12.0", devices: [.iphone,.ipad]),
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        infoPlist: InfoPlist = .default
    ) -> Project {
        let settings: Settings = .settings(
            base: [:],
            configurations: [
                .debug(name: .debug),
                .release(name: .release)
            ], defaultSettings: .recommended)
        
        let appTarget = Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: "\(organizationName).\(name)",
            deploymentTarget: deploymentTarget,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            dependencies: dependencies
        )
        
        let schemes: [Scheme] = [.makeScheme(target: .debug, name: name),
                                 .makeScheme(target: .release, name: name)]
        
        let targets: [Target] = [appTarget]
        
        return Project(
            name: name,
            organizationName: organizationName,
            packages: packages,
            settings: settings,
            targets: targets,
            schemes: schemes
        )
    }

}

extension Scheme {
    static func makeScheme(target: ConfigurationName, name: String) -> Scheme {
        return Scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .targets(
                ["\(name)"],
                configuration: target,
                options: .options(coverage: true,
                                  codeCoverageTargets: ["\(name)"])
            ),
            runAction: .runAction(configuration: target),
            archiveAction: .archiveAction(configuration: target),
            profileAction: .profileAction(configuration: target),
            analyzeAction: .analyzeAction(configuration: target)
        )
    }
    
}

public extension InfoPlist {
    
    
    
    
}
