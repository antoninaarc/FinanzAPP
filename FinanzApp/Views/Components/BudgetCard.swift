import SwiftUI

struct BudgetCard: View {
    let weeklyBudget: Double
    let spent: Double
    
    var remaining: Double {
        weeklyBudget - spent
    }
    
    var progress: Double {
        guard weeklyBudget > 0 else { return 0 }
        return min(spent / weeklyBudget, 1.0)
    }
    
    var statusColor: Color {
        if progress < 0.7 {
            return .green
        } else if progress < 0.9 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Budget")
                        .font(.headline)
                    Text("€\(weeklyBudget, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("€\(remaining, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(remaining >= 0 ? statusColor : .red)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [statusColor, statusColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 12)
                            .animation(.spring(), value: progress)
                    }
                }
                .frame(height: 12)
                
                // Stats
                HStack {
                    Text("Spent: €\(spent, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                }
            }
            
            // Warning message if over budget
            if remaining < 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("You've exceeded your weekly budget by €\(abs(remaining), specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            } else if progress > 0.8 {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                    Text("You're approaching your weekly limit")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct BudgetCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            BudgetCard(weeklyBudget: 500, spent: 350)
            BudgetCard(weeklyBudget: 500, spent: 450)
            BudgetCard(weeklyBudget: 500, spent: 550)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
