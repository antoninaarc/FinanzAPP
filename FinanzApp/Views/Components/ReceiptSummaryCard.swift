import SwiftUI

struct ReceiptSummaryCard: View {
    let total: Double
    let vatRate: Double?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                Text("Receipt Scanned")
                    .font(.headline)
                    .foregroundColor(.green)
                Spacer()
            }
            .padding()
            .background(Color.green.opacity(0.1))
            
            // Breakdown
            VStack(spacing: 12) {
                if let rate = vatRate, rate > 0 {
                    let baseAmount = total / (1 + rate)
                    let vatAmount = total - baseAmount
                    
                    // Total
                    HStack {
                        Text("Total Amount")
                            .font(.headline)
                        Spacer()
                        Text("€\(total, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Divider()
                    
                    // Breakdown
                    VStack(spacing: 8) {
                        HStack {
                            Text("Base (excl. VAT)")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("€\(baseAmount, specifier: "%.2f")")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("VAT (\(Int(rate * 100))%)")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("€\(vatAmount, specifier: "%.2f")")
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                    }
                } else {
                    // No VAT detected
                    HStack {
                        Text("Total Amount")
                            .font(.headline)
                        Spacer()
                        Text("€\(total, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Text("No VAT detected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ReceiptSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ReceiptSummaryCard(total: 7.77, vatRate: 0.09)
                .padding()
            
            ReceiptSummaryCard(total: 36.36, vatRate: 0.21)
                .padding()
            
            ReceiptSummaryCard(total: 15.50, vatRate: nil)
                .padding()
        }
    }
}
