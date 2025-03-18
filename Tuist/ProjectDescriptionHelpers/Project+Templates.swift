import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/


import ProjectDescription
import ProjectDescriptionHelpers

public extension Project {
    static func makeModule(
        name: String,
        organizationName: String = "com.app",
        packages: [Package] = [],
        configurations : [Configuration] = [],
        targets : [Target],
        headerSearchPaths : [String : SettingValue] = [:]
    ) -> Project {
        var settings: Settings
        
        if configurations.isEmpty {
            settings = .settings(
                base: headerSearchPaths,
                configurations: [
                    .debug(name: .debug),
                    .release(name: .release)
                ],
                defaultSettings: .recommended)
        }
        else {
            
            var base : [String : SettingValue] = [
                "PRODUCT_BUNDLE_IDENTIFIER":"$SL_APP_BUNDLE_ID",
                "PRODUCT_NAME" : "$SL_APP_NAME",
                "CURRENT_PROJECT_VERSION" : "$SL_APP_BUILD_VERSION",
                "MARKETING_VERSION" : "$SL_APP_MARKETING_VERSION",
                "ENABLE_TESTING_SEARCH_PATHS": "YES",
                "CODE_SIGN_STYLE": "Automatic",
                "DEVELOPMENT_TEAM": "D237UGRPX6",
                "CODE_SIGN_IDENTITY": "Apple Development"
            ]
            
            for (key, value)  in headerSearchPaths {
                base[key] = value
            }
            
            settings = .settings(
                base: base,
                configurations: configurations,
                defaultSettings: .recommended)
        }
        
        
        var schemeTargetName : String = name
        if let target = targets.first {
            schemeTargetName = target.name
        }
        var schemes : [Scheme] = [.makeScheme(target: .debug, name: schemeTargetName),
                                  .makeScheme(target: .release, name: schemeTargetName, useDebugMode: true)]
        
        
        
        var targets: [Target] = targets
        
        return Project(
            name: name,
            organizationName: organizationName,
            options: .options(defaultKnownRegions: ["ko","ja","en"]),
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
        deploymentTarget: DeploymentTargets? = .iOS("12.0"),
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
        
        let appTarget = Target.target(name: name,
                                      destinations: .iOS,
                                      product: .app,
                                      bundleId: "\(organizationName).\(name)",
                                      infoPlist: infoPlist,
                                      sources: sources,
                                      resources: resources,
                                      dependencies: dependencies)
        
        let schemes: [Scheme] = [.makeScheme(target: .debug, name: name),
                                 .makeScheme(target: .release, name: name, useDebugMode: true)]
        
        let targets: [Target] = [appTarget]
        
        return Project(
            name: name,
            organizationName: organizationName,
            options: .options(defaultKnownRegions: ["ko","ja","en"]),
            packages: packages,
            settings: settings,
            targets: targets,
            schemes: schemes
        )
    }
    
}

extension Scheme {
    static func makeScheme(target: ConfigurationName, name: String, useDebugMode: Bool = false) -> Scheme {
        return Scheme.scheme(name: name,
                             shared: true,
                             buildAction: .buildAction(targets: ["\(name)"]),
                             runAction: .runAction(configuration: useDebugMode ? .debug : target),
                             archiveAction: .archiveAction(configuration: target),
                             profileAction: .profileAction(configuration: target),
                             analyzeAction: .analyzeAction(configuration: target))
    }
    
}

public extension InfoPlist {
    
    
    
    
}
