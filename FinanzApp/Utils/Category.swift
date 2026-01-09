import Foundation

struct Category: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var emoji: String
    var parentID: UUID? // For subcategories
    
    static let defaultCategories = [
        Category(name: "Groceries", emoji: "🛒"),
        Category(name: "Transport", emoji: "🚗"),
        Category(name: "Housing", emoji: "🏠"),
        Category(name: "Salary", emoji: "💰"),
        Category(name: "Healthcare", emoji: "🏥"),
        Category(name: "Entertainment", emoji: "🎮"),
        Category(name: "Clothing", emoji: "👕"),
        Category(name: "Subscriptions", emoji: "📱"),
        Category(name: "Travel", emoji: "✈️"),
        Category(name: "Other", emoji: "📦")
    ]
    
    static let availableEmojis = [
        "🛒", "🚗", "🏠", "💰", "🏥", "🎮", "👕", "📱", "✈️", "📦",
        "🍔", "☕️", "🎬", "📚", "💻", "🎵", "🏋️", "🎨", "🌮", "🍕",
        "🎯", "🎪", "🎨", "🏖️", "⚽️", "🎸", "📷", "🎭", "🎰", "🎲",
        "🏀", "🎾", "⛷️", "🏊", "🚴", "🧘", "💊", "🩺", "🦷", "👶",
        "🧒", "👴", "👵", "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻",
        "🍎", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒",
        "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🍆", "🥑", "🥦", "🥬",
        "🥒", "🌶️", "🌽", "🥕", "🫒", "🧄", "🧅", "🥔", "🍠", "🫘",
        "🥐", "🥯", "🍞", "🥖", "🥨", "🧀", "🥚", "🍳", "🧈", "🥞",
        "🧇", "🥓", "🥩", "🍗", "🍖", "🦴", "🌭", "🍔", "🍟", "🍕",
        "🫓", "🥪", "🥙", "🧆", "🌮", "🌯", "🫔", "🥗", "🥘", "🫕"
    ]
}
