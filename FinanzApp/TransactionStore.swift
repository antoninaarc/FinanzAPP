import Foundation
import SwiftUI

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var userMode: UserMode = .basic
    @Published var customCategories: [Category] = []
    
    var allCategories: [Category] {
        return customCategories.isEmpty ? Category.defaultCategories : customCategories
    }
    
    init() {
        loadTransactions()
        loadUserMode()
    }
    
    // MARK: - Transaction Management
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveTransactions()
    }
    
    // MARK: - User Mode
    func saveUserMode(_ mode: UserMode) {
        userMode = mode
        if let encoded = try? JSONEncoder().encode(mode) {
            UserDefaults.standard.set(encoded, forKey: "userMode")
        }
    }
    
    private func loadUserMode() {
        if let data = UserDefaults.standard.data(forKey: "userMode"),
           let decoded = try? JSONDecoder().decode(UserMode.self, from: data) {
            userMode = decoded
        }
    }
    
    // MARK: - Custom Categories
    func addCategory(_ category: Category) {
        customCategories.append(category)
        saveCategories()
    }
    
    func updateCategory(_ category: Category) {
        if let index = customCategories.firstIndex(where: { $0.id == category.id }) {
            customCategories[index] = category
            saveCategories()
        }
    }
    
    func deleteCategory(_ category: Category) {
        customCategories.removeAll { $0.id == category.id }
        customCategories.removeAll { $0.parentID == category.id }
        saveCategories()
    }
    
    func getSubcategories(for parentID: UUID) -> [Category] {
        return customCategories.filter { $0.parentID == parentID }
    }
    
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(customCategories) {
            UserDefaults.standard.set(encoded, forKey: "customCategories")
        }
    }
    
    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: "customCategories"),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            customCategories = decoded
        }
    }
    
    // MARK: - Balance Calculations
    var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var totalBalance: Double {
        totalIncome - totalExpense
    }
    
    func totalIncome(for period: FilterPeriod) -> Double {
        filteredTransactions(by: period).filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    func totalExpense(for period: FilterPeriod) -> Double {
        filteredTransactions(by: period).filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    func totalBalance(for period: FilterPeriod) -> Double {
        totalIncome(for: period) - totalExpense(for: period)
    }
    
    // MARK: - BTW Calculations (for ZZP mode)
    var totalBTWCollected: Double {
        transactions
            .filter { $0.type == .income }
            .compactMap { $0.btwAmount }
            .reduce(0, +)
    }
    
    func daysUntilBTWDeadline() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)
        let currentMonth = calendar.component(.month, from: today)
        
        var deadlineMonth: Int
        if currentMonth <= 3 {
            deadlineMonth = 4 // April
        } else if currentMonth <= 6 {
            deadlineMonth = 7 // July
        } else if currentMonth <= 9 {
            deadlineMonth = 10 // October
        } else {
            deadlineMonth = 1 // January next year
        }
        
        let deadlineYear = deadlineMonth == 1 ? currentYear + 1 : currentYear
        let lastDayOfMonth = deadlineMonth == 2 ? 28 : (deadlineMonth == 4 || deadlineMonth == 7 || deadlineMonth == 10) ? 30 : 31
        
        if let deadline = calendar.date(from: DateComponents(year: deadlineYear, month: deadlineMonth, day: lastDayOfMonth)) {
            return calendar.dateComponents([.day], from: today, to: deadline).day ?? 0
        }
        
        return 0
    }
    
    func nextBTWDeadline() -> Date {
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)
        let currentMonth = calendar.component(.month, from: today)
        
        var deadlineMonth: Int
        if currentMonth <= 3 {
            deadlineMonth = 4
        } else if currentMonth <= 6 {
            deadlineMonth = 7
        } else if currentMonth <= 9 {
            deadlineMonth = 10
        } else {
            deadlineMonth = 1
        }
        
        let deadlineYear = deadlineMonth == 1 ? currentYear + 1 : currentYear
        let lastDayOfMonth = deadlineMonth == 2 ? 28 : (deadlineMonth == 4 || deadlineMonth == 7 || deadlineMonth == 10) ? 30 : 31
        
        return calendar.date(from: DateComponents(year: deadlineYear, month: deadlineMonth, day: lastDayOfMonth)) ?? today
    }
    
    // MARK: - Filtering
    func filteredTransactions(by period: FilterPeriod) -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .all:
            return transactions
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return transactions.filter { $0.date >= weekAgo }
        case .month:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return transactions.filter { $0.date >= startOfMonth }
        case .last30:
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
            return transactions.filter { $0.date >= thirtyDaysAgo }
        }
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
        loadCategories()
    }
}
