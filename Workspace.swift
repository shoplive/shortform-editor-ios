import ProjectDescription
import ProjectDescriptionHelpers
import Foundation



let workspace = Workspace(
    name: ENV.GENTYP == "ALL" ? "ShopLive" :
        ENV.GENTYP == "PLAYER" ? "ShoplivePlayer" :
        ENV.GENTYP == "SHORTFORM" ? "ShopliveShortform" :
        "ShopLive",
    projects: ENV.GENTYP == "ALL" ? [
        "Modules/**",
        "Application/**"
    ] :
        ENV.GENTYP == "PLAYER" ? [
            "Modules/Common",
            "Modules/Player",
            "Modules/DropDown",
            "Application/PlayerDemo"
        ] :
        ENV.GENTYP == "SHORTFORM" ? [
            "Modules/Common",
            "Modules/Shortform",
            "Modules/Editor",
            "Application/ShortformDemo"
        ] :
        [
            "Modules/**",
            "Application/**"
    ])
