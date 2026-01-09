import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    private var categoryEmoji: String {
        if let category = Category.defaultCategories.first(where: { $0.name == transaction.category }) {
            return category.emoji
        }
        return "📦"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Text(categoryEmoji)
                .font(.system(size: 28))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(transaction.type == .income ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                )
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category)
                    .font(.headline)
                
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.type == .income ? "+" : "-")€\(transaction.amount, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.type == .income ? .green : .red)
                
                // BTW indicator for ZZP users
                if let btwRate = transaction.btwRate {
                    Text("BTW \(Int(btwRate * 100))%")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TransactionRow(transaction: Transaction(
                amount: 45.50,
                category: "Groceries",
                type: .expense,
                note: "Weekly shopping",
                date: Date()
            ))
            
            TransactionRow(transaction: Transaction(
                amount: 2500.00,
                category: "Salary",
                type: .income,
                note: "January salary",
                date: Date(),
                btwRate: 0.21
            ))
        }
        .padding()
    }
}
