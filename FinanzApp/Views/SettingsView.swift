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
                    
                    // User Mode Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("USER MODE")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            // Basic Mode
                            Button {
                                store.userMode = .basic
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: "person.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .frame(width: 44)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Basic")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("Simple for personal use")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if store.userMode == .basic {
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
                            
                            // ZZP Mode
                            Button {
                                store.userMode = .zzp
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: "briefcase.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .frame(width: 44)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("ZZP / Freelancer")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("With BTW tools")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if store.userMode == .zzp {
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
                            
                            // Pro Mode (Coming Soon)
                            HStack(spacing: 16) {
                                Image(systemName: "star.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                    .frame(width: 44)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text("Pro")
                                            .font(.headline)
                                        Text("Coming Soon")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.2))
                                            .foregroundColor(.blue)
                                            .cornerRadius(6)
                                    }
                                    Text("All features (coming soon)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                            .opacity(0.6)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Mode Features Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Basic Mode Features
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                Text("Basic Mode")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                FeatureRow(text: "Add and view transactions")
                                FeatureRow(text: "Simple charts")
                                FeatureRow(text: "Weekly budget")
                            }
                            .padding(.leading, 8)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: .secondarySystemBackground))
                        )
                        
                        // ZZP Mode Features
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "briefcase.fill")
                                    .foregroundColor(.blue)
                                Text("ZZP Mode")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                FeatureRow(text: "Everything from Basic")
                                FeatureRow(text: "BTW Calculator")
                                FeatureRow(text: "BTW Savings Vault")
                                FeatureRow(text: "Quarterly reminders")
                            }
                            .padding(.leading, 8)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(uiColor: .secondarySystemBackground))
                        )
                    }
                    .padding(.horizontal)
                    
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

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(.secondary)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: TransactionStore())
    }
}
