//
//  ContentView.swift
//  OnlyLonely
//
//  Created by Taishin Miyamoto on 2025/10/11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("OnlyLonely")
                    .font(.largeTitle).bold()
                NavigationLink("Go to HostView") {
                    HostView()
                }
                .buttonStyle(.borderedProminent)
                NavigationLink("Go to GuestView") {
                    GuestView()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
