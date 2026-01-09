import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    @State private var showingExportSheet = false
    
    var body: some View {
        NavigationView {
            List {
                // User Mode Selection
                Section {
                    Text("Choose the mode that best suits your needs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                } header: {
                    VStack(spacing: 12) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                Section("USER MODE") {
                    ModeRow(
                        icon: "person.fill",
                        iconColor: .blue,
                        title: "Basic",
                        subtitle: "Simple for personal use",
                        isSelected: store.userMode == .basic
                    ) {
                        store.saveUserMode(.basic)
                    }
                    
                    ModeRow(
                        icon: "briefcase.fill",
                        iconColor: .blue,
                        title: "ZZP / Freelancer",
                        subtitle: "With BTW tools",
                        isSelected: store.userMode == .zzp
                    ) {
                        store.saveUserMode(.zzp)
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Pro")
                                    .font(.headline)
                                Text("Coming Soon")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                            Text("All features")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .opacity(0.6)
                }
                
                // Customization
                Section("CUSTOMIZATION") {
                    NavigationLink(destination: ManageCategoriesView(store: store)) {
                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            VStack(alignment: .leading) {
                                Text("Manage Categories")
                                    .font(.headline)
                                Text("\(store.allCategories.count) categories")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Data
                Section("DATA") {
                    Button(action: {
                        showingExportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            VStack(alignment: .leading) {
                                Text("Export to CSV")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Export all transactions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // Features based on mode
                Section("FEATURES") {
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
            .sheet(isPresented: $showingExportSheet) {
                ExportCSVView(store: store)
            }
        }
    }
}

struct ModeRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
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
            .padding(.vertical, 8)
        }
    }
}

struct FeaturesList: View {
    let icon: String
    let title: String
    let features: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
            }
            
            ForEach(features, id: \.self) { feature in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(feature)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExportCSVView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Export Transactions")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Export all your transactions to a CSV file")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: exportCSV) {
                    Text("Export")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func exportCSV() {
        let csv = store.generateCSV()
        let activityVC = UIActivityViewController(
            activityItems: [csv],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
        
        dismiss()
    }
}
