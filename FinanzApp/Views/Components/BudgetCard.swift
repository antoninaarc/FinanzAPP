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
    
    // Monthly context (psychological anchor)
    var monthlyBudget: Double {
        weeklyBudget * 4.33 // Average weeks per month
    }
    
    var dailyAllowance: Double {
        remaining / 7 // Days left in week
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with weekly focus
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Budget")
                        .font(.headline)
                    Text("Limit: €\(weeklyBudget, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(isOverBudget ? "Exceeded!" : "Available")
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
                            .fill(progressColor)
                            .frame(
                                width: geometry.size.width * progress,
                                height: 12
                            )
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("Spent: €\(spent, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isOverBudget ? .red : .primary)
                }
            }
            
            // Daily allowance (psychological trick: smaller numbers feel more manageable)
            if !isOverBudget && remaining > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.day.timeline.left")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("You can spend €\(dailyAllowance, specifier: "%.2f")/day this week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            
            // Monthly context (subtle reference point)
            Divider()
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                    .font(.caption2)
                Text("Monthly budget: €\(monthlyBudget, specifier: "%.0f")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("≈ €\(weeklyBudget, specifier: "%.0f")/week")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // Progressive color system (psychological feedback)
    var progressColor: Color {
        if progress < 0.5 {
            return .green  // Safe zone
        } else if progress < 0.8 {
            return .blue   // Warning zone
        } else if progress < 1.0 {
            return .orange // Danger zone
        } else {
            return .red    // Over budget
        }
    }
}

struct BudgetCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            BudgetCard(weeklyBudget: 200, spent: 50)
            BudgetCard(weeklyBudget: 200, spent: 150)
            BudgetCard(weeklyBudget: 200, spent: 250)
        }
        .padding()
    }
}
