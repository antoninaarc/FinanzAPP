import SwiftUI

struct ManageCategoriesView: View {
    @ObservedObject var store: TransactionStore
    @State private var showingAddCategory = false
    
    var body: some View {
        List {
            ForEach(store.allCategories) { category in
                HStack {
                    Text(category.emoji)
                        .font(.title2)
                    Text(category.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    if category.parentID == nil {
                        let subcategories = store.getSubcategories(for: category.id)
                        if !subcategories.isEmpty {
                            Text("\(subcategories.count)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        store.deleteCategory(category)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddCategory = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView(store: store)
        }
    }
}
