import Foundation
import SwiftUI

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var userMode: UserMode = .basic
    @Published var customCategories: [Category] = []
    
    // MARK: - Budget Configuration
    @Published var monthlyBudget: Double = 2000 {
        didSet {
            saveBudgetSettings()
        }
    }
    
    @Published var weeklyBudget: Double = 500 {
        didSet {
            saveBudgetSettings()
        }
    }
    
    var allCategories: [Category] {
        return customCategories.isEmpty ? Category.defaultCategories : customCategories
    }
    
    init() {
        loadTransactions()
        loadUserMode()
        loadCategories()
        loadBudgetSettings()
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
    
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            saveTransactions()
        }
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
    
    // MARK: - Budget Calculations
    func getMonthlySpending() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        return transactions
            .filter { $0.type == .expense && $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getWeeklySpending() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        return transactions
            .filter { $0.type == .expense && $0.date >= startOfWeek }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getDaysRemainingInMonth() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let range = calendar.range(of: .day, in: .month, for: now)!
        let currentDay = calendar.component(.day, from: now)
        return range.count - currentDay + 1
    }
    
    func getDaysRemainingInWeek() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let currentWeekday = calendar.component(.weekday, from: now)
        return 8 - currentWeekday
    }
    
    func getDailySuggestedSavings() -> Double {
        let daysRemaining = getDaysRemainingInMonth()
        let remainingBudget = monthlyBudget - getMonthlySpending()
        return daysRemaining > 0 ? remainingBudget / Double(daysRemaining) : 0
    }
    
    // MARK: - Budget Persistence
    private func saveBudgetSettings() {
        UserDefaults.standard.set(monthlyBudget, forKey: "monthlyBudget")
        UserDefaults.standard.set(weeklyBudget, forKey: "weeklyBudget")
    }
    
    private func loadBudgetSettings() {
        if UserDefaults.standard.object(forKey: "monthlyBudget") != nil {
            monthlyBudget = UserDefaults.standard.double(forKey: "monthlyBudget")
        }
        if UserDefaults.standard.object(forKey: "weeklyBudget") != nil {
            weeklyBudget = UserDefaults.standard.double(forKey: "weeklyBudget")
        }
    }
    
    // MARK: - BTW Calculations (for ZZP mode)
    var totalBTWCollected: Double {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { total, transaction in
                total + (transaction.btwAmount ?? 0)
            }
    }
    
    var totalBTWPaid: Double {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { total, transaction in
                total + (transaction.btwAmount ?? 0)
            }
    }
    
    var netBTWOwed: Double {
        totalBTWCollected - totalBTWPaid
    }
    
    func daysUntilBTWDeadline() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let deadline = nextBTWDeadline()
        return calendar.dateComponents([.day], from: today, to: deadline).day ?? 0
    }
    
    func nextBTWDeadline() -> Date {
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)
        let currentMonth = calendar.component(.month, from: today)
        
        var deadlineMonth: Int
        var deadlineDay: Int
        
        if currentMonth <= 1 {
            deadlineMonth = 1
            deadlineDay = 31
        } else if currentMonth <= 4 {
            deadlineMonth = 4
            deadlineDay = 30
        } else if currentMonth <= 7 {
            deadlineMonth = 7
            deadlineDay = 31
        } else if currentMonth <= 10 {
            deadlineMonth = 10
            deadlineDay = 31
        } else {
            deadlineMonth = 1
            deadlineDay = 31
        }
        
        let deadlineYear = (currentMonth > 10) ? currentYear + 1 : currentYear
        
        return calendar.date(from: DateComponents(year: deadlineYear, month: deadlineMonth, day: deadlineDay)) ?? today
    }
    
    func getBTWProgress() -> Double {
        guard netBTWOwed > 0 else { return 0 }
        let daysInQuarter = 90.0
        let daysRemaining = Double(daysUntilBTWDeadline())
        return min(1.0, (daysInQuarter - daysRemaining) / daysInQuarter)
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
    
    func transactionsByCategory(for period: FilterPeriod) -> [String: Double] {
        let filtered = filteredTransactions(by: period).filter { $0.type == .expense }
        var categoryTotals: [String: Double] = [:]
        
        for transaction in filtered {
            categoryTotals[transaction.category, default: 0] += transaction.amount
        }
        
        return categoryTotals
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
    
    // MARK: - CSV Export
    func generateCSV() -> String {
        var csv = "Date,Category,Type,Amount,BTW Rate,Amount Excl BTW,BTW Amount,Note\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for transaction in transactions {
            let dateString = dateFormatter.string(from: transaction.date)
            let btwRateString = transaction.btwRate != nil ? String(format: "%.0f%%", transaction.btwRate! * 100) : ""
            let amountExclString = transaction.btwRate != nil ? String(format: "%.2f", transaction.amountExclBTW ?? 0) : ""
            let btwAmountString = transaction.btwRate != nil ? String(format: "%.2f", transaction.btwAmount ?? 0) : ""
            
            csv += "\(dateString),\(transaction.category),\(transaction.type.rawValue),\(String(format: "%.2f", transaction.amount)),\(btwRateString),\(amountExclString),\(btwAmountString),\"\(transaction.note)\"\n"
        }
        
        return csv
    }
}
