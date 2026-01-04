import Foundation

struct Transaction: Identifiable, Codable {
    var id: UUID
    var amount: Double
    var category: String
    var type: TransactionType
    var note: String
    var date: Date
    
    init(id: UUID = UUID(), amount: Double, category: String, type: TransactionType, note: String = "", date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.category = category
        self.type = type
        self.note = note
        self.date = date
    }
    
    var emoji: String {
        Category.allCategories.first(where: { $0.name == category })?.emoji ?? "💰"
    }
}

enum TransactionType: String, Codable {
    case income = "Ingreso"
    case expense = "Gasto"
}
