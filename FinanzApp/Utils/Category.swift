import Foundation

struct Category: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let emoji: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.name == rhs.name
    }
}

extension Category {
    static let allCategories = [
        Category(name: "Comida", emoji: "🍔"),
        Category(name: "Transporte", emoji: "🚗"),
        Category(name: "Hogar", emoji: "🏠"),
        Category(name: "Salud", emoji: "💊"),
        Category(name: "Entretenimiento", emoji: "🎮"),
        Category(name: "Salario", emoji: "💰"),
        Category(name: "Educación", emoji: "📚"),
        Category(name: "Compras", emoji: "🛍️"),
        Category(name: "Otros", emoji: "✨")
    ]
}
