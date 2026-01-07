import SwiftUI
import UIKit

struct CSVExporter {
    
    // Method for SwiftUI views
    func exportTransactions(_ transactions: [Transaction]) {
        let csvText = Self.generateCSV(from: transactions)
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("FinanzApp_Export_\(Date().timeIntervalSince1970).csv")
        
        do {
            try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
            
            // Share using SwiftUI
            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    Self.shareCSV(from: rootViewController, url: tempURL)
                }
            }
        } catch {
            print("Error creating CSV: \(error)")
        }
    }
    
    // Static method for direct UIViewController usage
    static func shareCSV(from viewController: UIViewController, transactions: [Transaction]) {
        let csvText = generateCSV(from: transactions)
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("FinanzApp_Export_\(Date().timeIntervalSince1970).csv")
        
        do {
            try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
            shareCSV(from: viewController, url: tempURL)
        } catch {
            print("Error creating CSV: \(error)")
        }
    }
    
    private static func shareCSV(from viewController: UIViewController, url: URL) {
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                       y: viewController.view.bounds.midY,
                                       width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
    
    private static func generateCSV(from transactions: [Transaction]) -> String {
        var csvText = "Date,Type,Amount,VAT Rate,VAT Amount,Amount Excl. VAT,Category,Note\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        for transaction in transactions.sorted(by: { $0.date > $1.date }) {
            let date = dateFormatter.string(from: transaction.date)
            let type = transaction.type == .income ? "Income" : "Expense"
            let amount = String(format: "€%.2f", transaction.amount)
            
            let btwRate = transaction.btwRate.map { String(format: "%.0f%%", $0 * 100) } ?? "0%"
            let btwAmount = transaction.btwAmount.map { String(format: "€%.2f", $0) } ?? "€0.00"
            let amountExcl = transaction.amountExclBTW.map { String(format: "€%.2f", $0) } ?? amount
            
            let category = transaction.category
            let note = transaction.note.replacingOccurrences(of: ",", with: ";")
            
            let row = "\(date),\(type),\(amount),\(btwRate),\(btwAmount),\(amountExcl),\(category),\(note)\n"
            csvText.append(row)
        }
        
        return csvText
    }
}
