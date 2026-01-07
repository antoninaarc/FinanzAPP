import SwiftUI

enum FilterPeriod: String, CaseIterable {
    case all = "All"
    case week = "This week"
    case month = "This month"
    case last30 = "Last 30 days"
}

struct FilterView: View {
    @Binding var selectedPeriod: FilterPeriod
    
    var body: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(FilterPeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(selectedPeriod: .constant(.all))
    }
}
