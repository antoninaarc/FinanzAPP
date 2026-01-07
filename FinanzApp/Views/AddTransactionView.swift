import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: String = ""
    @State private var selectedCategory = Category.defaultCategories[0]
    @State private var selectedType: TransactionType = .expense
    @State private var note: String = ""
    @State private var date = Date()
    @State private var showingScanner = false
    @State private var scannedImages: [UIImage] = []
    @State private var isProcessing = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingCameraUnavailableAlert = false
    
    // Receipt summary
    @State private var showReceiptSummary = false
    @State private var scannedTotal: Double?
    @State private var scannedVATRate: Double?
    
    // BTW
    @State private var selectedBTWRate: Double? = nil
    @State private var showBTWCalculation = false
    
    var availableCategories: [Category] {
        return store.allCategories
    }
    
    var body: some View {
        NavigationView {
            Form {
                scannerSection
                
                if showReceiptSummary, let total = scannedTotal {
                    Section {
                        ReceiptSummaryCard(total: total, vatRate: scannedVATRate)
                    }
                }
                
                typeSection
                amountSection
                if store.userMode == .zzp {
                    btwSection
                }
                categorySection
                detailsSection
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveTransaction() }
                        .disabled(amount.isEmpty)
                }
            }
            .sheet(isPresented: $showingScanner) {
                if DocumentScannerView.isAvailable {
                    DocumentScannerView(scannedImages: $scannedImages)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .alert("Camera Not Available", isPresented: $showingCameraUnavailableAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Document scanning is not available on the simulator. Please use a physical device or select from gallery instead.")
            }
            .onChange(of: scannedImages) { newValue in
                if let image = newValue.last {
                    processScannedReceipt(image)
                }
            }
            .onChange(of: selectedImage) { newValue in
                if let image = newValue {
                    processScannedReceipt(image)
                }
            }
            .onAppear {
                if let firstCategory = availableCategories.first {
                    selectedCategory = firstCategory
                }
            }
        }
    }
    
    private var scannerSection: some View {
        Section {
            VStack(spacing: 12) {
                Button(action: {
                    if DocumentScannerView.isAvailable {
                        showingScanner = true
                    } else {
                        showingCameraUnavailableAlert = true
                    }
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
                
                Button(action: { showingImagePicker = true }) {
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
                        Text("Processing receipt...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var typeSection: some View {
        Section("Type") {
            Picker("Type", selection: $selectedType) {
                Text("Expense").tag(TransactionType.expense)
                Text("Income").tag(TransactionType.income)
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var amountSection: some View {
        Section("Amount") {
            HStack {
                Text("€")
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
            }
        }
    }
    
    private var btwSection: some View {
        Section("VAT (BTW)") {
            HStack(spacing: 12) {
                btwButton(rate: 0.21, label: "21%")
                btwButton(rate: 0.09, label: "9%")
                btwButton(rate: 0.0, label: "0%")
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
    
    private func btwButton(rate: Double, label: String) -> some View {
        Button(action: {
            selectedBTWRate = rate
            showBTWCalculation = rate > 0
        }) {
            Text(label)
                .fontWeight(selectedBTWRate == rate ? .bold : .regular)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedBTWRate == rate ? Color.green : Color.gray.opacity(0.2))
                .foregroundColor(selectedBTWRate == rate ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var categorySection: some View {
        Section("Category") {
            Picker("Category", selection: $selectedCategory) {
                ForEach(availableCategories.filter { $0.parentID == nil }) { parentCategory in
                    HStack {
                        Text(parentCategory.emoji)
                        Text(parentCategory.name)
                    }
                    .tag(parentCategory)
                    
                    ForEach(store.getSubcategories(for: parentCategory.id)) { subcategory in
                        HStack {
                            Text("  ")
                            Text(subcategory.emoji)
                            Text(subcategory.name)
                        }
                        .tag(subcategory)
                    }
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    private var detailsSection: some View {
        Section("Details") {
            TextField("Note (optional)", text: $note)
            DatePicker("Date", selection: $date, displayedComponents: .date)
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
            
            if let total = parsed.amount {
                self.amount = String(format: "%.2f", total)
                self.scannedTotal = total
            }
            
            if let rate = parsed.detectedBTWRate {
                self.selectedBTWRate = rate
                self.showBTWCalculation = rate > 0
                self.scannedVATRate = rate
            }
            
            if parsed.amount != nil {
                self.showReceiptSummary = true
            }
            
            if let parsedDate = parsed.date {
                self.date = parsedDate
            }
            
            if let merchant = parsed.merchant {
                self.note = merchant
            }
            
            let merchantLower = (parsed.merchant ?? "").lowercased()
            if merchantLower.contains("albert heijn") || merchantLower.contains("jumbo") ||
               merchantLower.contains("lidl") || merchantLower.contains("aldi") {
                if let foodCategory = availableCategories.first(where: { $0.name == "Food" }) {
                    self.selectedCategory = foodCategory
                }
            }
        }
    }
}
