import ProjectDescription
import ProjectDescriptionHelpers
import Foundation




let workspace = Workspace(
    name:"ShopLive",
    projects: ProjectBundlingManager.getProjects())


public struct ProjectBundlingManager {
    public static func getProjects() -> [Path] {
        var result : [Path] = []
        
        switch ENV.GENTYPE {
        case "ALL":
            result = [
                "Modules/**",
                "Application/**"]
        case "DEPLOY":
            result = [
                "Modules/Common",
                "Modules/Player",
                "Modules/Shortform"
            ]
        case "PLAYERDEMO":
            result = [
                "Modules/Common",
                "Modules/Player",
                "Modules/DropDown",
                "Application/PlayerDemo",
                "Application/PlayerDemo2"
            ]
        case "PLAYER":
            result = [
                "Modules/Player"
            ]
        case "SHORTFORMDEMO":
            result = [
                "Modules/Common",
                "Modules/Shortform",
                "Modules/Editor",
                "Application/ShortformDemo"
            ]
        case "SHORTFORM":
            result = [
                "Modules/Shortform"
            ]
        case "EDITOR":
            result = [
                "Modules/Editor"
            ]
            break
        case "COMMON":
            result = [
                "Modules/Common"
            ]
        default:
            result = [
                "Modules/**",
                "Application/**"]
        }
        return result
    }
}



//ENV.GENTYPE == "ALL" ? [
//    "Modules/**",
//    "Application/**"
//] :
//    ENV.GENTYPE == "PLAYER" ? [
//        "Modules/Common",
//        "Modules/Player",
//        "Modules/DropDown",
//        "Application/PlayerDemo"
//    ] :
//    ENV.GENTYPE == "SHORTFORM" ? [
//        "Modules/Common",
//        "Modules/Shortform",
//        "Modules/Editor",
//        "Application/ShortformDemo"
//    ] :
//    [
//        "Modules/**",
//        "Application/**"
//]
