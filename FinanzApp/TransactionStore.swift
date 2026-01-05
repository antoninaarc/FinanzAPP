import Foundation

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveTransactions()
    }
    
    var totalBalance: Double {
        transactions.reduce(0) { result, transaction in
            transaction.type == .income ? result + transaction.amount : result - transaction.amount
        }
    }
    
    var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Persistence
    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: "transactions")
        }
    }
    
    func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: "transactions"),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
    }
    // MARK: - Filtros
        func filteredTransactions(by period: FilterPeriod) -> [Transaction] {
            let calendar = Calendar.current
            let now = Date()
            
            switch period {
            case .all:
                return transactions
                
            case .week:
                let startOfWeek = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: now).date!
                return transactions.filter { $0.date >= startOfWeek }
                
            case .month:
                let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
                return transactions.filter { $0.date >= startOfMonth }
                
            case .last30:
                let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
                return transactions.filter { $0.date >= thirtyDaysAgo }
            }
        }
        
        func totalIncome(for period: FilterPeriod) -> Double {
            filteredTransactions(by: period)
                .filter { $0.type == .income }
                .reduce(0) { $0 + $1.amount }
        }
        
        func totalExpense(for period: FilterPeriod) -> Double {
            filteredTransactions(by: period)
                .filter { $0.type == .expense }
                .reduce(0) { $0 + $1.amount }
        }
        
        func totalBalance(for period: FilterPeriod) -> Double {
            totalIncome(for: period) - totalExpense(for: period)
        }}
