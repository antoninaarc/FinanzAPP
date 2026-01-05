import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: String = ""
    @State private var selectedCategory = Category.allCategories[0]
    @State private var selectedType: TransactionType = .expense
    @State private var note: String = ""
    @State private var date = Date()
    @State private var showingScanner = false
    @State private var scannedImages: [UIImage] = []
    @State private var isProcessing = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(spacing: 12) {
                        // Botón Escanear
                        Button(action: {
                            showingScanner = true
                        }) {
                            HStack {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.title2)
                                Text("Escanear con Cámara")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Botón Galería
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                Text("Seleccionar de Galería")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if isProcessing {
                            HStack {
                                ProgressView()
                                Text("Procesando...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
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
            .sheet(isPresented: $showingScanner) {
                DocumentScannerView(scannedImages: $scannedImages)
            }
            .onChange(of: scannedImages) { newValue in
                if let image = newValue.last {
                    processScannedReceipt(image)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) { newValue in
                if let image = newValue {
                    processScannedReceipt(image)
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
    
    private func processScannedReceipt(_ image: UIImage) {
        isProcessing = true
        
        ReceiptParser.parseReceipt(from: image) { parsed in
            isProcessing = false
            
            if let amount = parsed.amount {
                self.amount = String(format: "%.2f", amount)
            }
            
            if let parsedDate = parsed.date {
                self.date = parsedDate
            }
            
            if let merchant = parsed.merchant {
                self.note = merchant
            }
            
            let lowerText = parsed.fullText.lowercased()
            if lowerText.contains("mercadona") || lowerText.contains("carrefour") || lowerText.contains("lidl") {
                if let foodCategory = Category.allCategories.first(where: { $0.name == "Comida" }) {
                    self.selectedCategory = foodCategory
                }
            }
        }
    }
}
