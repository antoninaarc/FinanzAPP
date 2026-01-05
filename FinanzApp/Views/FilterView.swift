import SwiftUI

enum FilterPeriod: String, CaseIterable {
    case all = "Todo"
    case week = "Esta semana"
    case month = "Este mes"
    case last30 = "Últimos 30 días"
}

struct FilterView: View {
    @Binding var selectedPeriod: FilterPeriod
    
    var body: some View {
        Picker("Período", selection: $selectedPeriod) {
            ForEach(FilterPeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}
