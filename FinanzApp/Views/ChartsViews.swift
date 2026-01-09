import SwiftUI

struct ChartsView: View {
    @ObservedObject var store: TransactionStore
    @State private var selectedPeriod: FilterPeriod = .month
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Filter
                FilterView(selectedPeriod: $selectedPeriod)
                
                // Summary Cards
                HStack(spacing: 15) {
                    StatCard(
                        title: "Income",
                        amount: store.totalIncome(for: selectedPeriod),
                        icon: "arrow.down.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Expenses",
                        amount: store.totalExpense(for: selectedPeriod),
                        icon: "arrow.up.circle.fill",
                        color: .red
                    )
                }
                .padding(.horizontal)
                
                // Net Balance
                VStack(spacing: 8) {
                    Text("Net Balance")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("€\(store.totalBalance(for: selectedPeriod), specifier: "%.2f")")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(store.totalBalance(for: selectedPeriod) >= 0 ? .green : .red)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Category Breakdown
                if !store.filteredTransactions(by: selectedPeriod).filter({ $0.type == .expense }).isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Expenses by Category")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        CategoryBreakdownView(store: store, period: selectedPeriod)
                    }
                    .padding(.vertical)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No expense data to display")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Add some transactions to see charts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
            }
            .padding(.top)
        }
        .navigationTitle("📊 Statistics")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct StatCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("€\(amount, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
        )
    }
}

struct CategoryBreakdownView: View {
    @ObservedObject var store: TransactionStore
    let period: FilterPeriod
    
    private var categoryTotals: [(String, Double)] {
        let totals = store.transactionsByCategory(for: period)
        return totals.sorted { $0.value > $1.value }
    }
    
    private var totalExpenses: Double {
        categoryTotals.reduce(0) { $0 + $1.1 }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(categoryTotals, id: \.0) { category, amount in
                CategoryBar(
                    category: category,
                    amount: amount,
                    percentage: totalExpenses > 0 ? amount / totalExpenses : 0,
                    emoji: getCategoryEmoji(category)
                )
            }
        }
        .padding(.horizontal)
    }
    
    private func getCategoryEmoji(_ categoryName: String) -> String {
        if let category = Category.defaultCategories.first(where: { $0.name == categoryName }) {
            return category.emoji
        }
        if let customCategory = store.customCategories.first(where: { $0.name == categoryName }) {
            return customCategory.emoji
        }
        return "📦"
    }
}

struct CategoryBar: View {
    let category: String
    let amount: Double
    let percentage: Double
    let emoji: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(emoji)
                    .font(.title3)
                Text(category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("€\(amount, specifier: "%.2f")")
                        .font(.headline)
                    Text("\(Int(percentage * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .animation(.spring(), value: percentage)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
