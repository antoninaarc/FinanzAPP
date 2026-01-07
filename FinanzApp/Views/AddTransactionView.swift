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
    
    // MARK: - Scanner Section
    private var scannerSection: some View {
        Section {
            VStack(spacing: 12) {
                scanCameraButton
                selectGalleryButton
                if isProcessing {
                    processingIndicator
                }
            }
        }
    }
    
    private var scanCameraButton: some View {
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
    }
    
    private var selectGalleryButton: some View {
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
    }
    
    private var processingIndicator: some View {
        HStack {
            ProgressView()
            Text("Processing...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Type Section
    private var typeSection: some View {
        Section("Type") {
            Picker("Type", selection: $selectedType) {
                Text("Expense").tag(TransactionType.expense)
                Text("Income").tag(TransactionType.income)
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - Amount Section
    private var amountSection: some View {
        Section("Amount") {
            HStack {
                Text("€")
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
            }
        }
    }
    
    // MARK: - BTW Section
    private var btwSection: some View {
        Section("VAT (BTW)") {
            btwButtons
            if showBTWCalculation, let rate = selectedBTWRate, rate > 0 {
                btwCalculation(rate: rate)
            }
        }
    }
    
    private var btwButtons: some View {
        HStack(spacing: 12) {
            btwButton(rate: 0.21, label: "21%")
            btwButton(rate: 0.09, label: "9% Low")
            btwButton(rate: 0.0, label: "0% Free")
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
    
    private func btwCalculation(rate: Double) -> some View {
        Group {
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
    
    // MARK: - Category Section
    private var categorySection: some View {
        Section("Category") {
            Picker("Category", selection: $selectedCategory) {
                ForEach(availableCategories.filter { $0.parentID == nil }) { parentCategory in
                    categoryRow(for: parentCategory)
                    ForEach(store.getSubcategories(for: parentCategory.id)) { subcategory in
                        subcategoryRow(for: subcategory)
                    }
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    private func categoryRow(for category: Category) -> some View {
        HStack {
            Text(category.emoji)
            Text(category.name)
        }
        .tag(category)
    }
    
    private func subcategoryRow(for category: Category) -> some View {
        HStack {
            Text("  ")
            Text(category.emoji)
            Text(category.name)
        }
        .tag(category)
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        Section("Details") {
            TextField("Note (optional)", text: $note)
            DatePicker("Date", selection: $date, displayedComponents: .date)
        }
    }
    
    // MARK: - Actions
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
                if let foodCategory = availableCategories.first(where: { $0.name == "Food" }) {
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
