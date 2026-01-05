import Foundation

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var userMode: UserMode = .basic
    
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
        // Load user mode
        if let modeString = UserDefaults.standard.string(forKey: "userMode"),
           let mode = UserMode(rawValue: modeString) {
            self.userMode = mode
        }
        
        // Load transactions
        if let data = UserDefaults.standard.data(forKey: "transactions"),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
    }
    
    func saveUserMode(_ mode: UserMode) {
        self.userMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "userMode")
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
    }
    
    // MARK: - BTW Functions
    var totalBTWCollected: Double {
        transactions
            .filter { $0.type == .income && $0.btwAmount != nil }
            .reduce(0) { $0 + ($1.btwAmount ?? 0) }
    }
    
    var totalBTWPaid: Double {
        transactions
            .filter { $0.type == .expense && $0.btwAmount != nil }
            .reduce(0) { $0 + ($1.btwAmount ?? 0) }
    }
    
    var netBTW: Double {
        totalBTWCollected - totalBTWPaid
    }
    
    func nextBTWDeadline() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        // BTW quarters in Netherlands: Jan 31, Apr 30, Jul 31, Oct 31
        let quarters = [
            (month: 1, day: 31),
            (month: 4, day: 30),
            (month: 7, day: 31),
            (month: 10, day: 31)
        ]
        
        // Find next quarter
        for quarter in quarters {
            if quarter.month > currentMonth {
                return calendar.date(from: DateComponents(
                    year: currentYear,
                    month: quarter.month,
                    day: quarter.day
                )) ?? now
            }
        }
        
        // If no quarter this year, return Jan 31 next year
        return calendar.date(from: DateComponents(
            year: currentYear + 1,
            month: 1,
            day: 31
        )) ?? now
    }
    
    func daysUntilBTWDeadline() -> Int {
        let deadline = nextBTWDeadline()
        return Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
    }
}
