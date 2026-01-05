import Foundation

enum TransactionType: String, Codable {
    case income = "Ingreso"
    case expense = "Gasto"
}

struct Transaction: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var category: String
    var type: TransactionType
    var note: String
    var date: Date
    
    // NUEVO: BTW (IVA holandés)
    var btwRate: Double? // 0.21, 0.09, 0.00
    var amountExclBTW: Double? // Base sin IVA
    var btwAmount: Double? // Cantidad de IVA
    
    init(
        amount: Double,
        category: String,
        type: TransactionType,
        note: String = "",
        date: Date = Date(),
        btwRate: Double? = nil
    ) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.type = type
        self.note = note
        self.date = date
        self.btwRate = btwRate
        
        // Calcular BTW automáticamente si hay tasa
        if let rate = btwRate, rate > 0 {
            self.amountExclBTW = amount / (1 + rate)
            self.btwAmount = amount - (amount / (1 + rate))
        } else {
            self.amountExclBTW = amount
            self.btwAmount = 0
        }
    }
}
