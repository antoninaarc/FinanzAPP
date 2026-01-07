import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let emoji: String
    let parentID: UUID?
    
    init(id: UUID = UUID(), name: String, emoji: String, parentID: UUID? = nil) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.parentID = parentID
    }
    
    // Available emojis for category selection
    static let availableEmojis: [String] = [
        // Finance & Money
        "💰", "💵", "💴", "💶", "💷", "💳", "🏦", "💸", "📈", "📉",
        // Food & Drink
        "🍔", "🍕", "🍗", "🌮", "🍜", "🍱", "🍝", "🥗", "☕", "🍷",
        // Transportation
        "🚗", "🚕", "🚙", "🚌", "🚎", "🚐", "🚑", "✈️", "🚆", "⛽",
        // Shopping & Retail
        "🛒", "🛍️", "👕", "👗", "👔", "👠", "💄", "📱", "💻", "⌚",
        // Home & Living
        "🏠", "🏡", "🔑", "🛋️", "🛏️", "🚪", "🪟", "💡", "🔌", "🧹",
        // Entertainment
        "🎬", "🎮", "🎯", "🎲", "🎸", "🎹", "📚", "📖", "🎨", "🖼️",
        // Health & Fitness
        "💊", "🏥", "⚕️", "🩺", "💉", "🏋️", "🚴", "🧘", "🏃", "⚽",
        // Education & Work
        "📝", "✏️", "📊", "💼", "📋", "📌", "🖊️", "📎", "🗂️", "📁",
        // Services & Utilities
        "📞", "📧", "📮", "🔧", "🔨", "⚙️", "🛠️", "🔑", "💡", "🔋",
        // Travel & Leisure
        "🧳", "🗺️", "🏖️", "⛱️", "🏕️", "🎿", "🏂", "⛷️", "🚣", "🏊",
        // Pets & Animals
        "🐕", "🐈", "🐾", "🦴", "🐟", "🐦", "🐹", "🐰", "🐴", "🐄",
        // Other
        "🎁", "🎉", "🎊", "🎈", "🌟", "⭐", "❤️", "💙", "💚", "🔔"
    ]
    
    // Default categories (fallback if no custom categories)
    static let defaultCategories: [Category] = [
        Category(name: "Food", emoji: "🍔"),
        Category(name: "Transport", emoji: "🚗"),
        Category(name: "Shopping", emoji: "🛒"),
        Category(name: "Entertainment", emoji: "🎬"),
        Category(name: "Health", emoji: "💊"),
        Category(name: "Home", emoji: "🏠"),
        Category(name: "Education", emoji: "📚"),
        Category(name: "Travel", emoji: "✈️"),
        Category(name: "Utilities", emoji: "💡"),
        Category(name: "Other", emoji: "📦")
    ]
    
    // Helper to get all categories (for backwards compatibility)
    static var allCategories: [Category] {
        return defaultCategories
    }
}
