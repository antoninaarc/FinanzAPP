import SwiftUI
import PhotosUI

struct AddTransactionView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    
    @State private var amount = ""
    @State private var selectedCategory = "Groceries"
    @State private var transactionType: TransactionType = .expense
    @State private var note = ""
    @State private var date = Date()
    @State private var selectedBTWRate: Double? = nil
    @State private var showingImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            formContent
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
                .photosPicker(
                    isPresented: $showingImagePicker,
                    selection: $selectedPhotoItem,
                    matching: .images
                )
                .task(id: selectedPhotoItem) {
                    if let item = selectedPhotoItem {
                        loadImage(from: item)
                    }
                }
                .task(id: selectedImage) {
                    if let image = selectedImage {
                        processReceipt(image: image)
                    }
                }
        }
    }
    
    private var formContent: some View {
        Form {
            scanOptionsSection
            typeSection
            amountSection
            if store.userMode == .zzp {
                btwSection
            }
            categorySection
            detailsSection
        }
    }
    
    private var scanOptionsSection: some View {
        Section {
            Button(action: {
                print("Camera functionality - requires VisionKit")
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                    Text("Scan with Camera")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo.fill")
                        .foregroundColor(.white)
                    Text("Select from Gallery")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .listRowBackground(Color.clear)
    }
    
    private var typeSection: some View {
        Section("TYPE") {
            Picker("Type", selection: $transactionType) {
                Text("Expense").tag(TransactionType.expense)
                Text("Income").tag(TransactionType.income)
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var amountSection: some View {
        Section("AMOUNT") {
            HStack {
                Text("€")
                    .foregroundColor(.secondary)
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 24, weight: .medium))
            }
        }
    }
    
    private var btwSection: some View {
        Section("VAT (BTW)") {
            HStack(spacing: 12) {
                BTWButton(rate: 0.21, selected: selectedBTWRate == 0.21) {
                    selectedBTWRate = 0.21
                }
                BTWButton(rate: 0.09, selected: selectedBTWRate == 0.09) {
                    selectedBTWRate = 0.09
                }
                BTWButton(rate: 0.0, selected: selectedBTWRate == 0.0) {
                    selectedBTWRate = 0.0
                }
            }
        }
    }
    
    private var categorySection: some View {
        Section("CATEGORY") {
            Picker("Category", selection: $selectedCategory) {
                ForEach(store.allCategories) { category in
                    HStack {
                        Text(category.emoji)
                        Text(category.name)
                    }
                    .tag(category.name)
                }
            }
        }
    }
    
    private var detailsSection: some View {
        Section("DETAILS") {
            TextField("Note (optional)", text: $note)
            DatePicker("Date", selection: $date, displayedComponents: .date)
        }
    }
    
    func loadImage(from item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = image
                }
            }
        }
    }
    
    func processReceipt(image: UIImage) {
        ReceiptParser.extractText(from: image) { result in
            DispatchQueue.main.async {
                if let extractedAmount = result.amount {
                    self.amount = String(format: "%.2f", extractedAmount)
                }
                if let merchant = result.merchant {
                    self.note = merchant
                }
                if let category = result.suggestedCategory {
                    self.selectedCategory = category
                }
            }
        }
    }
    
    func saveTransaction() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else { return }
        
        let transaction = Transaction(
            amount: amountValue,
            category: selectedCategory,
            type: transactionType,
            note: note,
            date: date,
            btwRate: store.userMode == .zzp ? selectedBTWRate : nil
        )
        
        store.addTransaction(transaction)
        dismiss()
    }
}

struct BTWButton: View {
    let rate: Double
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(Int(rate * 100))%")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selected ? Color.blue : Color(.systemGray5))
                .foregroundColor(selected ? .white : .primary)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
