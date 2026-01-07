import SwiftUI

struct BTWVaultCard: View {
    let collected: Double
    let expected: Double
    let daysUntil: Int
    let deadline: Date
    
    var shortage: Double {
        max(0, expected - collected)
    }
    
    var progress: Double {
        guard expected > 0 else { return 0 }
        return min(1.0, collected / expected)
    }
    
    var statusColor: Color {
        if progress >= 0.9 { return .green }
        if progress >= 0.7 { return .orange }
        return .red
    }
    
    var statusText: String {
        if progress >= 0.9 { return "On track!" }
        if progress >= 0.7 { return "Good job" }
        return "Watch out!"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("💰")
                            .font(.title2)
                        Text("VAT Savings Vault")
                            .font(.headline)
                    }
                    
                    Text("Next VAT filing:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text(deadline, style: .date)
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("(\(daysUntil) days)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(statusColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)
                    
                    VStack(spacing: 2) {
                        Text("\(Int(progress * 100))%")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(statusText)
                            .font(.caption2)
                            .foregroundColor(statusColor)
                    }
                }
            }
            
            Divider()
            
            // Amounts
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("€\(collected, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Expected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("€\(expected, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(shortage > 0 ? "Shortage" : "Extra")
                        .font(.caption)
                        .foregroundColor(shortage > 0 ? .red : .green)
                    Text("€\(abs(shortage), specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(shortage > 0 ? .red : .green)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [statusColor.opacity(0.7), statusColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 12)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 12)
            
            // Info text
            if shortage > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.orange)
                    Text("Save €\(shortage / Double(max(1, daysUntil)), specifier: "%.2f")/day to be on time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("You have saved enough for the next filing!")
                        .font(.caption)
                        .foregroundColor(.secondary)
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

struct BTWVaultCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            BTWVaultCard(
                collected: 450,
                expected: 500,
                daysUntil: 15,
                deadline: Date().addingTimeInterval(15 * 24 * 60 * 60)
            )
            
            BTWVaultCard(
                collected: 520,
                expected: 500,
                daysUntil: 15,
                deadline: Date().addingTimeInterval(15 * 24 * 60 * 60)
            )
        }
        .padding()
    }
}
