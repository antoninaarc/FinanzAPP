import SwiftUI

struct AddCategoryView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var selectedEmoji: String = "📦"
    @State private var isSubcategory = false
    @State private var selectedParent: Category?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Preview
                    VStack(spacing: 8) {
                        Text(selectedEmoji)
                            .font(.system(size: 60))
                        Text(name.isEmpty ? "Preview" : name)
                            .font(.headline)
                            .foregroundColor(name.isEmpty ? .secondary : .primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NAME")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("E.g., Business Travel", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Icons
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ICON (\(Category.availableEmojis.count) AVAILABLE)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 60))
                        ], spacing: 12) {
                            ForEach(Category.availableEmojis, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 40))
                                    .frame(width: 60, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedEmoji == emoji ? Color.blue.opacity(0.2) : Color(uiColor: .secondarySystemBackground))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedEmoji == emoji ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedEmoji = emoji
                                    }
                            }
                        }
                    }
                    
                    // Subcategory
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Is subcategory", isOn: $isSubcategory)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                        
                        if isSubcategory {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PARENT CATEGORY")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Menu {
                                    Button("Select...") {
                                        selectedParent = nil
                                    }
                                    ForEach(store.allCategories.filter { $0.parentID == nil }) { category in
                                        Button {
                                            selectedParent = category
                                        } label: {
                                            HStack {
                                                Text(category.emoji)
                                                Text(category.name)
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        if let parent = selectedParent {
                                            Text(parent.emoji)
                                            Text(parent.name)
                                        } else {
                                            Text("Select a category")
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(uiColor: .secondarySystemBackground))
                                    .cornerRadius(12)
                                }
                            }
                            
                            if selectedParent != nil {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("PREVIEW")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 8) {
                                            Text(selectedParent?.emoji ?? "")
                                                .font(.title2)
                                            Text(selectedParent?.name ?? "")
                                                .font(.headline)
                                        }
                                        
                                        HStack(spacing: 8) {
                                            Text("  →")
                                                .foregroundColor(.secondary)
                                            Text(selectedEmoji)
                                                .font(.title3)
                                            Text(name.isEmpty ? "New subcategory" : name)
                                                .font(.subheadline)
                                                .foregroundColor(name.isEmpty ? .secondary : .primary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(uiColor: .secondarySystemBackground))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(name.isEmpty || (isSubcategory && selectedParent == nil))
                }
            }
        }
    }
    
    private func saveCategory() {
        let category = Category(
            name: name,
            emoji: selectedEmoji,
            parentID: isSubcategory ? selectedParent?.id : nil
        )
        store.addCategory(category)
        dismiss()
    }
}

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoryView(store: TransactionStore())
    }
}
