import SwiftUI

struct MainTabView: View {
    // Usamos @StateObject para que los datos se compartan entre pestañas
    @StateObject var store = TransactionStore()
    
    var body: some View {
        TabView {
            // Pestaña 1: Tu lista actual
            MainTabView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            // Pestaña 2: Tus nuevas gráficas
            ChartsView(store: store)
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar.pie.fill")
                }
        }
        // Esto le da color a los iconos de abajo
        .accentColor(.blue)
    }
}
