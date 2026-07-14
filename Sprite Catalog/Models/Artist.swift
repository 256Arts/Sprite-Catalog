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
                "https://itch.io/profile/alexs-assets"
            case "Alvoria":
                "https://www.minecraftforum.net/members/Alvoria"
            case "AngryMeteor.com":
                "www.angrymeteor.com"
            case "ANoob":
                "https://anoob.itch.io"
            case "Anonymous":
                nil
            case "ansimuz":
                "http://www.patreon.com/ansimuz"
            case "AV Reference":
                "http://www.patreon.com/rmocci"
            case "Blarumyrran":
                "https://opengameart.org/users/blarumyrran"
            case "bart":
                "http://www.patreon.com/opengameart"
            case "Beast Pixels":
                "https://beast-pixels.itch.io"
            case "Bonsaiheldin":
                "http://bonsaiheld.org"
            case "Borco Rosso":
                "https://borcorosso.itch.io/"
            case "Caz Wolf":
                "https://cazwolf.itch.io"
            case "devurandom":
                "https://opengameart.org/users/devurandom"
            case "Eikester":
                "https://opengameart.org/users/eikester"
            case "joemaya":
                "https://opengameart.org/users/joemaya"
            case "Josehzz":
                "https://opengameart.org/users/josehzz"
            case "Jayden Irwin":
                "https://www.jaydenirwin.com/"
            case "PiiiXL":
                "https://piiixl.itch.io"
            case "Pixel-Boy & AAA":
                "https://twitter.com/2Pblog1"
            case "polyphorge":
                "https://polyphorge.itch.io/"
            case "Limofeus":
                "https://limofeus.itch.io/"
            case "Lucas312":
                "https://opengameart.org/users/lucas312"
            case "Franuka":
                "https://twitter.com/franuka_art"
            case "Gentile Cat Studio":
                "https://gentlecatstudio.itch.io/"
            case "Gif":
                "https://twitter.com/gif_not_jif"
            case "Ghostpixxells":
                "https://ghostpixxells.itch.io"
            case "GrafxKid":
                "https://twitter.com/GrafxKid"
            case "Romain Oltra":
                "https://www.artstation.com/imanor"
            case "rubycave":
                "www.rubycave.com.ar"
            case "Henry Software":
                "https://henrysoftware.itch.io/"
            case "hippo":
                "https://opengameart.org/users/hippo"
            case "Kyrise":
                "https://www.ascensiongamedev.com/profile/1137-kyrise/"
            case "Macko":
                nil
            case "Matt Firth (cheekyinkling)":
                "https://game-icons.net"
            case "Megacrash":
                "https://megacrash.itch.io/"
            case "Mobius_Peverell":
                "https://www.curseforge.com/members/mobius_peverell/"
            case "Cpt Corn":
                "https://www.minecraftforum.net/forums/mapping-and-modding-java-edition/resource-packs/1223548-32x-16x-coterie-craft-default-revamped"
            case "uheartbeast":
                "http://www.patreon.com/uheartbeast"
            case "loel":
                "https://opengameart.org/users/loel"
            case "Quintino Pixels":
                "https://ko-fi.com/quintinopixels"
            case "RedVoxel":
                "https://red-voxel.itch.io/"
            case "Refuzzle":
                "https://opengameart.org/users/refuzzle"
            case "RodrixAP":
                "https://www.flickr.com/photos/rodrixap/"
            case "RunCoyoteKidRun":
                nil
            case "SciGho":
                "https://itch.io/profile/ninjikin"
            case "Shepardskin":
                "https://opengameart.org/users/shepardskin"
            case "Stealthix":
                "https://www.patreon.com/Stealthix"
            case "StormtrooperJon":
                "https://opengameart.org/users/stormtrooperjon"
            default:
                #if DEBUG
                fatalError()
                #else
                nil
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
        return switch domain {
        case "itch.io":
            "Itch"
        case "twitter.com":
            "Twitter"
        case "patreon.com":
            "Patreon"
        default:
            "Website"
        }
    }
    
}
