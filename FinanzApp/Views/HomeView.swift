import SwiftUI

struct HomeView: View {
    @StateObject private var store = TransactionStore()
    @State private var showingAddTransaction = false
    @State private var selectedPeriod: FilterPeriod = .all
    @State private var weeklyBudget: Double = 500.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Filtro
                    FilterView(selectedPeriod: $selectedPeriod)
                    
                    // Budget Card
                    if selectedPeriod == .week {
                        BudgetCard(
                            weeklyBudget: weeklyBudget,
                            spent: store.totalExpense(for: .week)
                        )
                        .padding(.horizontal)
                    }
                    
                    BalanceCard(
                        balance: store.totalBalance(for: selectedPeriod),
                        income: store.totalIncome(for: selectedPeriod),
                        expense: store.totalExpense(for: selectedPeriod)
                    )
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Transacciones Recientes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if store.filteredTransactions(by: selectedPeriod).isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "tray")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("No hay transacciones")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                Text("Toca el botón + para agregar una")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            ForEach(store.filteredTransactions(by: selectedPeriod).sorted(by: { $0.date > $1.date })) { transaction in
                                TransactionRow(transaction: transaction)
                                    .padding(.horizontal)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            store.deleteTransaction(transaction)
                                        } label: {
                                            Label("Eliminar", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle("💰 FinanzApp")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ChartsView(store: store)) {
                        Image(systemName: "chart.pie.fill")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(store: store)
            }
            .onAppear {
                store.loadTransactions()
            }
        }
    }
}
