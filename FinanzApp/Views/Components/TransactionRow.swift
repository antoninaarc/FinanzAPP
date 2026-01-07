import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var categoryEmoji: String {
        Category.allCategories.first(where: { $0.name == transaction.category })?.emoji ?? "📦"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoji + Category name
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(categoryEmoji)
                        .font(.title2)
                    Text(transaction.category)
                        .font(.headline)
                }
                
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(transaction.date, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.type == .income ? "+" : "-")€\(transaction.amount, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(transaction.type == .income ? .green : .red)
                
                if let btwAmount = transaction.btwAmount, btwAmount > 0 {
                    Text("VAT: €\(btwAmount, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRow(transaction: Transaction(
            amount: 25.50,
            category: "Food",
            type: .expense,
            note: "Lunch at restaurant",
            date: Date(),
            btwRate: 0.21
        ))
        .padding()
    }
}
