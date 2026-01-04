import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: String = ""
    @State private var selectedCategory = Category.allCategories[0]
    @State private var selectedType: TransactionType = .expense
    @State private var note: String = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Tipo") {
                    Picker("Tipo", selection: $selectedType) {
                        Text("Gasto").tag(TransactionType.expense)
                        Text("Ingreso").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Cantidad") {
                    HStack {
                        Text("€")
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Categoría") {
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(Category.allCategories) { category in
                            HStack {
                                Text(category.emoji)
                                Text(category.name)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("Detalles") {
                    TextField("Nota (opcional)", text: $note)
                    DatePicker("Fecha", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Nueva Transacción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveTransaction()
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else { return }
        
        let transaction = Transaction(
            amount: amountValue,
            category: selectedCategory.name,
            type: selectedType,
            note: note,
            date: date
        )
        
        store.addTransaction(transaction)
        dismiss()
    }
}
