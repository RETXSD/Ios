//
//  ContentView.swift
//  Fitnessapp
//
//  Created by 11 on 2026/5/8.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        FitnessAppTabView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
