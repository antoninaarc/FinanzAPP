import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Elige el modo que mejor se adapte a tus necesidades")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section("Modo de Usuario") {
                    ForEach([UserMode.basic, UserMode.zzp], id: \.self) { mode in
                        Button(action: {
                            store.saveUserMode(mode)
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: mode.icon)
                                    .font(.title2)
                                    .foregroundColor(store.userMode == mode ? .blue : .gray)
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mode.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(mode.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if store.userMode == mode {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Pro mode (disabled)
                    HStack(spacing: 16) {
                        Image(systemName: UserMode.pro.icon)
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(UserMode.pro.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Próximamente")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            Text(UserMode.pro.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .opacity(0.5)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Modo Básico", systemImage: "person.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("• Agregar y ver transacciones\n• Gráficos simples\n• Presupuesto semanal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Modo ZZP", systemImage: "briefcase.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("• Todo lo de Básico\n• BTW Calculator\n• BTW Spaarkluis\n• Recordatorios trimestrales")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("⚙️ Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
}
