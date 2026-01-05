import Foundation

enum UserMode: String, Codable {
    case basic = "Básico"
    case zzp = "ZZP / Autónomo"
    case pro = "Pro"
    
    var description: String {
        switch self {
        case .basic:
            return "Simple para uso personal"
        case .zzp:
            return "Con herramientas BTW"
        case .pro:
            return "Todas las funciones (próximamente)"
        }
    }
    
    var icon: String {
        switch self {
        case .basic:
            return "person.fill"
        case .zzp:
            return "briefcase.fill"
        case .pro:
            return "star.fill"
        }
    }
}
