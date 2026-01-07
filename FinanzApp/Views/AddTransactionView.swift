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
    
    // BTW
    @State private var selectedBTWRate: Double? = nil
    @State private var showBTWCalculation = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(spacing: 12) {
                        Button(action: {
                            showingScanner = true
                        }) {
                            HStack {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.title2)
                                Text("Scan with Camera")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                Text("Select from Gallery")
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
                                Text("Processing...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("Type") {
                    Picker("Type", selection: $selectedType) {
                        Text("Expense").tag(TransactionType.expense)
                        Text("Income").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Amount") {
                    HStack {
                        Text("€")
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                }
                
                // BTW Section (ZZP mode only)
                if store.userMode == .zzp {
                    Section("VAT (BTW)") {
                        HStack(spacing: 12) {
                            Button(action: {
                                selectedBTWRate = 0.21
                                showBTWCalculation = true
                            }) {
                                Text("21%")
                                    .fontWeight(selectedBTWRate == 0.21 ? .bold : .regular)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedBTWRate == 0.21 ? Color.green : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedBTWRate == 0.21 ? .white : .primary)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                selectedBTWRate = 0.09
                                showBTWCalculation = true
                            }) {
                                Text("9% Low")
                                    .fontWeight(selectedBTWRate == 0.09 ? .bold : .regular)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedBTWRate == 0.09 ? Color.green : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedBTWRate == 0.09 ? .white : .primary)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                selectedBTWRate = 0.0
                                showBTWCalculation = false
                            }) {
                                Text("0% Free")
                                    .fontWeight(selectedBTWRate == 0.0 ? .bold : .regular)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedBTWRate == 0.0 ? Color.green : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedBTWRate == 0.0 ? .white : .primary)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if showBTWCalculation, let rate = selectedBTWRate, rate > 0 {
                            if let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) {
                                let baseAmount = amountValue / (1 + rate)
                                let btwAmount = amountValue - baseAmount
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Amount excl. VAT")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("€\(baseAmount, specifier: "%.2f")")
                                            .fontWeight(.semibold)
                                    }
                                    
                                    HStack {
                                        Text("VAT (\(Int(rate * 100))%)")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("€\(btwAmount, specifier: "%.2f")")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.green)
                                    }
                                    
                                    Divider()
                                    
                                    HStack {
                                        Text("Total incl. VAT")
                                            .fontWeight(.bold)
                                        Spacer()
                                        Text("€\(amountValue, specifier: "%.2f")")
                                            .fontWeight(.bold)
                                    }
                                }
                                .padding()
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Category.allCategories) { category in
                            HStack {
                                Text(category.emoji)
                                Text(category.name)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("Details") {
                    TextField("Note (optional)", text: $note)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
            date: date,
            btwRate: selectedBTWRate
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
                if let foodCategory = Category.allCategories.first(where: { $0.name == "Food" }) {
                    self.selectedCategory = foodCategory
                }
            }
        }
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView(store: TransactionStore())
    }
}
