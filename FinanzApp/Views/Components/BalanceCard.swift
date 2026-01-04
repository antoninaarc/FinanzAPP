import SwiftUI

struct BalanceCard: View {
    let balance: Double
    let income: Double
    let expense: Double
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Balance Total")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("€\(balance, specifier: "%.2f")")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(balance >= 0 ? .green : .red)
            }
            
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("Ingresos")
                            .font(.subheadline)
                    }
                    Text("€\(income, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.red)
                        Text("Gastos")
                            .font(.subheadline)
                    }
                    Text("€\(expense, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10)
        )
    }
}
