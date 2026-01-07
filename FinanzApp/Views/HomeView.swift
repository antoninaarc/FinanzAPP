import SwiftUI

struct HomeView: View {
    @StateObject private var store = TransactionStore()
    @State private var showingAddTransaction = false
    @State private var selectedPeriod: FilterPeriod = .all
    @State private var weeklyBudget: Double = 500.0
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Filter
                    FilterView(selectedPeriod: $selectedPeriod)
                    
                    // BTW Vault Card (ZZP mode only)
                    if store.userMode == .zzp {
                        BTWVaultCard(
                            collected: store.totalBTWCollected,
                            expected: store.totalBTWCollected * 1.2,
                            daysUntil: store.daysUntilBTWDeadline(),
                            deadline: store.nextBTWDeadline()
                        )
                        .padding(.horizontal)
                    }
                    
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
                        Text("Recent Transactions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if store.filteredTransactions(by: selectedPeriod).isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "tray")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("No transactions")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                Text("Tap the + button to add one")
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
                                            Label("Delete", systemImage: "trash")
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
                    HStack(spacing: 12) {
                        NavigationLink(destination: ChartsView(store: store)) {
                            Image(systemName: "chart.pie.fill")
                                .font(.title2)
                        }
                        
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                        }
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
            .sheet(isPresented: $showingSettings) {
                SettingsView(store: store)
            }
            .onAppear {
                store.loadTransactions()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
