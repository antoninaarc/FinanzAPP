import SwiftUI

struct ChartsView: View {
    @ObservedObject var store: TransactionStore
    
    var expensesByCategory: [CategoryExpense] {
        let expenses = store.transactions.filter { $0.type == .expense }
        var categoryTotals: [String: Double] = [:]
        
        for expense in expenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }
        
        return categoryTotals.map { key, value in
            let emoji = Category.allCategories.first(where: { $0.name == key })?.emoji ?? "💰"
            return CategoryExpense(category: key, amount: value, emoji: emoji)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    var totalExpenses: Double {
        expensesByCategory.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("📊 Statistics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                if !expensesByCategory.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Expenses by Category")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(expensesByCategory) { item in
                                HStack(spacing: 12) {
                                    Text(item.emoji)
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(item.category)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Text("€\(item.amount, specifier: "%.2f")")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                        }
                                        
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(height: 8)
                                                
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.blue)
                                                    .frame(
                                                        width: geometry.size.width * (item.amount / totalExpenses),
                                                        height: 8
                                                    )
                                            }
                                        }
                                        .frame(height: 8)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(uiColor: .secondarySystemBackground))
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Monthly Balance")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            
                            Text("Income")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("€\(store.totalIncome, specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                        )
                        
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                            
                            Text("Expenses")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("€\(store.totalExpense, specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                    .padding(.horizontal)
                }
                
                if expensesByCategory.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Not enough data")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Text("Add some transactions to see statistics")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 60)
                }
            }
            .padding(.vertical)
        }
    }
}

struct CategoryExpense: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let emoji: String
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView(store: TransactionStore())
    }
}
