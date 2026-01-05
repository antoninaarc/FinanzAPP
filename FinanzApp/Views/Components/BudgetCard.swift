import SwiftUI

struct BudgetCard: View {
    let weeklyBudget: Double
    let spent: Double
    
    var remaining: Double {
        weeklyBudget - spent
    }
    
    var progress: Double {
        min(spent / weeklyBudget, 1.0)
    }
    
    var isOverBudget: Bool {
        spent > weeklyBudget
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Presupuesto Semanal")
                        .font(.headline)
                    Text("Límite: €\(weeklyBudget, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(isOverBudget ? "¡Excedido!" : "Disponible")
                        .font(.caption)
                        .foregroundColor(isOverBudget ? .red : .green)
                    Text("€\(abs(remaining), specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(isOverBudget ? .red : .green)
                }
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isOverBudget ? Color.red : Color.blue)
                            .frame(
                                width: geometry.size.width * progress,
                                height: 12
                            )
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("Gastado: €\(spent, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isOverBudget ? .red : .primary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}
