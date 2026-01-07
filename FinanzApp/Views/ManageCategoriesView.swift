import SwiftUI

struct ManageCategoriesView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    @State private var showingAddCategory = false
    @State private var editingCategory: Category?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.allCategories.filter { $0.parentID == nil }) { category in
                    CategoryRowView(
                        category: category,
                        subcategories: store.getSubcategories(for: category.id),
                        onEdit: {
                            editingCategory = category
                        },
                        onDelete: {
                            store.deleteCategory(category)
                        }
                    )
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(store: store)
            }
            .sheet(item: $editingCategory) { category in
                EditCategoryView(store: store, category: category)
            }
        }
    }
}

struct CategoryRowView: View {
    let category: Category
    let subcategories: [Category]
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Text(category.emoji)
                        .font(.title2)
                    Text(category.name)
                        .font(.headline)
                }
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if !subcategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(subcategories) { sub in
                            HStack(spacing: 4) {
                                Text(sub.emoji)
                                Text(sub.name)
                            }
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct ManageCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        ManageCategoriesView(store: TransactionStore())
    }
}
