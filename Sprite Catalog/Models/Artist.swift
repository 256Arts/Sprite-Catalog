//
//  Artist.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-04-06.
//

import Foundation

struct Artist: Identifiable, Hashable, Codable {
    
    let name: String
    var id: String {
        name
    }
    
    var url: URL? {
        let urlString: String? = {
            switch name {
            case "Alex's Assets":
                return "https://itch.io/profile/alexs-assets"
            case "Alvoria":
                return "https://www.minecraftforum.net/members/Alvoria"
            case "AngryMeteor.com":
                return "www.angrymeteor.com"
            case "ANoob":
                return "https://anoob.itch.io"
            case "Anonymous":
                return nil
            case "ansimuz":
                return "http://www.patreon.com/ansimuz"
            case "AV Reference":
                return "http://www.patreon.com/rmocci"
            case "Blarumyrran":
                return "https://opengameart.org/users/blarumyrran"
            case "bart":
                return "http://www.patreon.com/opengameart"
            case "Beast Pixels":
                return "https://beast-pixels.itch.io"
            case "Bonsaiheldin":
                return "http://bonsaiheld.org"
            case "Borco Rosso":
                return "https://borcorosso.itch.io/"
            case "Caz Wolf":
                return "https://cazwolf.itch.io"
            case "devurandom":
                return "https://opengameart.org/users/devurandom"
            case "Eikester":
                return "https://opengameart.org/users/eikester"
            case "joemaya":
                return "https://opengameart.org/users/joemaya"
            case "Josehzz":
                return "https://opengameart.org/users/josehzz"
            case "Jayden Irwin":
                return "https://www.jaydenirwin.com/"
            case "Pixel-Boy & AAA":
                return "https://twitter.com/2Pblog1"
            case "polyphorge":
                return "https://polyphorge.itch.io/"
            case "Limofeus":
                return "https://limofeus.itch.io/"
            case "Lucas312":
                return "https://opengameart.org/users/lucas312"
            case "Franuka":
                return "https://twitter.com/franuka_art"
            case "Gentile Cat Studio":
                return "https://gentlecatstudio.itch.io/"
            case "Gif":
                return "https://twitter.com/gif_not_jif"
            case "Ghostpixxells":
                return "https://ghostpixxells.itch.io"
            case "GrafxKid":
                return "https://twitter.com/GrafxKid"
            case "Romain Oltra":
                return "https://www.artstation.com/imanor"
            case "rubycave":
                return "www.rubycave.com.ar"
            case "Henry Software":
                return "https://henrysoftware.itch.io/"
            case "hippo":
                return "https://opengameart.org/users/hippo"
            case "Kyrise":
                return "https://www.ascensiongamedev.com/profile/1137-kyrise/"
            case "Macko":
                return nil
            case "Matt Firth (cheekyinkling)":
                return "https://game-icons.net"
            case "Megacrash":
                return "https://megacrash.itch.io/"
            case "Mobius_Peverell":
                return "https://www.curseforge.com/members/mobius_peverell/"
            case "Cpt Corn":
                return "https://www.minecraftforum.net/forums/mapping-and-modding-java-edition/resource-packs/1223548-32x-16x-coterie-craft-default-revamped"
            case "uheartbeast":
                return "http://www.patreon.com/uheartbeast"
            case "loel":
                return "https://opengameart.org/users/loel"
            case "Quintino Pixels":
                return "https://ko-fi.com/quintinopixels"
            case "RedVoxel":
                return "https://red-voxel.itch.io/"
            case "Refuzzle":
                return "https://opengameart.org/users/refuzzle"
            case "RodrixAP":
                return "https://www.flickr.com/photos/rodrixap/"
            case "RunCoyoteKidRun":
                return nil
            case "SciGho":
                return "https://itch.io/profile/ninjikin"
            case "Shepardskin":
                return "https://opengameart.org/users/shepardskin"
            case "Stealthix":
                return "https://www.patreon.com/Stealthix"
            case "StormtrooperJon":
                return "https://opengameart.org/users/stormtrooperjon"
            default:
                #if DEBUG
                fatalError()
                #else
                return nil
                #endif
            }
        }()
        if let urlString = urlString {
            return URL(string: urlString)
        }
        return nil
    }
    
}

extension URL {
    
    var label: String {
        let domain = host?.components(separatedBy: ".").suffix(2).joined(separator: ".")
        switch domain {
        case "itch.io":
            return "Itch"
        case "twitter.com":
            return "Twitter"
        case "patreon.com":
            return "Patreon"
        default:
            return "Website"
        }
    }
    
}
