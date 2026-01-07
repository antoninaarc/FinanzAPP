import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    @State private var showingManageCategories = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("Choose the mode that best suits your needs")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // User Mode Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("USER MODE")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            // Basic Mode
                            ModeCard(
                                icon: "person.fill",
                                title: "Basic",
                                subtitle: "Simple for personal use",
                                isSelected: store.userMode == .basic,
                                badge: nil
                            ) {
                                store.userMode = .basic
                                store.saveUserMode(.basic)
                            }
                            
                            // ZZP Mode
                            ModeCard(
                                icon: "briefcase.fill",
                                title: "ZZP / Freelancer",
                                subtitle: "With BTW tools",
                                isSelected: store.userMode == .zzp,
                                badge: nil
                            ) {
                                store.userMode = .zzp
                                store.saveUserMode(.zzp)
                            }
                            
                            // Pro Mode (Coming Soon)
                            ModeCard(
                                icon: "star.fill",
                                title: "Pro",
                                subtitle: "All features",
                                isSelected: false,
                                badge: "Coming Soon"
                            ) {
                                // Disabled
                            }
                            .opacity(0.6)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Categories Management Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CUSTOMIZATION")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button {
                            showingManageCategories = true
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "tag.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 44)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Manage Categories")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("\(store.allCategories.count) categories")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                    
                    // Data Management Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DATA")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button {
                            exportToCSV()
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 44)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Export to CSV")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Export all transactions")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                    
                    // Mode Features (Shows features for selected mode)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("FEATURES")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        if store.userMode == .basic {
                            FeaturesList(
                                icon: "person.fill",
                                title: "Basic Mode",
                                features: [
                                    "Add and view transactions",
                                    "Simple charts",
                                    "Weekly budget"
                                ]
                            )
                        } else if store.userMode == .zzp {
                            FeaturesList(
                                icon: "briefcase.fill",
                                title: "ZZP Mode",
                                features: [
                                    "Everything from Basic",
                                    "BTW Calculator",
                                    "BTW Savings Vault",
                                    "Quarterly reminders"
                                ]
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingManageCategories) {
                ManageCategoriesView(store: store)
            }
        }
    }
    
    private func exportToCSV() {
        let csvExporter = CSVExporter()
        csvExporter.exportTransactions(store.transactions)
    }
}

// MARK: - Mode Card Component
struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let badge: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 44)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let badge = badge {
                            Text(badge)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Features List Component
struct FeaturesList: View {
    let icon: String
    let title: String
    let features: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.secondary)
                        Text(feature)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: TransactionStore())
    }
}
