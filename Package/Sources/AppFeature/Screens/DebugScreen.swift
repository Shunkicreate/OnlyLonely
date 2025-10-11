import SwiftUI

struct DebugScreen: View {
    var body: some View {
        NavigationStack {
            List {
                Section("P2P") {
                    NavigationLink("Host View") { HostView() }
                    NavigationLink("Guest View") { GuestView() }
                }
            }
            .navigationTitle("Debug")
        }
    }
}

#Preview {
    DebugScreen()
}

