//
//  ContentView.swift
//  WordScramble
//
//  Created by Elenes Praget, Emilio on 06.09.25.
//

import SwiftUI

struct ContentView: View {
    let people = ["Finn", "Leia", "Luke", "Rey"]
    
    var body: some View {
        List {
            Text("Static Row")
            
            ForEach(people, id: \.self) {
                Text($0)
            }
            
            Text("Static Row")
        }
    }
    
    func testBundles() {
        if let fileURL = Bundle.main.url(forResource: "somefile", withExtension: "txt") {
            if let fileContents = try? String(contentsOf: fileURL) {
                // then we do something with the fileURL
            }
        }
    }
}

#Preview {
    ContentView()
}
