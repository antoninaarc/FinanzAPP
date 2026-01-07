import SwiftUI

struct EditCategoryView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    
    let category: Category
    
    @State private var name: String = ""
    @State private var selectedEmoji: String = ""
    @State private var isSubcategory = false
    @State private var selectedParent: Category?
    @State private var showingDeleteAlert = false
    
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
                        TextField("Category name", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Icons
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ICON")
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
                                    ForEach(store.allCategories.filter { $0.parentID == nil && $0.id != category.id }) { cat in
                                        Button {
                                            selectedParent = cat
                                        } label: {
                                            HStack {
                                                Text(cat.emoji)
                                                Text(cat.name)
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
                        }
                    }
                    
                    // Delete button
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Category")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty || (isSubcategory && selectedParent == nil))
                }
            }
            .alert("Delete Category", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteCategory()
                }
            } message: {
                Text("Are you sure you want to delete this category? This action cannot be undone.")
            }
            .onAppear {
                name = category.name
                selectedEmoji = category.emoji
                isSubcategory = category.parentID != nil
                if let parentID = category.parentID {
                    selectedParent = store.allCategories.first { $0.id == parentID }
                }
            }
        }
    }
    
    private func saveChanges() {
        let updatedCategory = Category(
            id: category.id,
            name: name,
            emoji: selectedEmoji,
            parentID: isSubcategory ? selectedParent?.id : nil
        )
        store.updateCategory(updatedCategory)
        dismiss()
    }
    
    private func deleteCategory() {
        store.deleteCategory(category)
        dismiss()
    }
}

struct EditCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        EditCategoryView(
            store: TransactionStore(),
            category: Category(name: "Food", emoji: "🍔")
        )
    }
}
