//
//  ContentView.swift
//  Instafilter
//
//  Created by Steven Gustason on 5/1/23.
//

import SwiftUI

struct ContentView: View {
    @State private var blurAmount = 0.0
    @State private var showingConfirmation = false
        @State private var backgroundColor = Color.white

    var body: some View {
        VStack {
            Text("Hello, World!")
                .blur(radius: blurAmount)
            
            Slider(value: $blurAmount, in: 0...20)
            // Because of the way SwiftUI sends binding updates to property wrappers, assigning property observers used with property wrappers often won’t work. To fix this we need to use the onChange() modifier, which tells SwiftUI to run a function of our choosing when a particular value changes. SwiftUI will automatically pass in the new value to whatever function you attach, or you can just read the original property if you prefer.
                .onChange(of: blurAmount) { newValue in
                    print("New value is \(newValue)")
                }
            
            Text("Hello, World!")
                .frame(width: 300, height: 300)
                .background(backgroundColor)
                .onTapGesture {
                    showingConfirmation = true
                }
            // Confirmation dialog is very similar to alert in the way it's implemented. The main difference is that confirmationDialog allows for multiple buttons instead of just one or two in an alert. It also works differently in the way it looks - it slides up from the bottom of the screen and you can click outside of it to dismiss it.
                .confirmationDialog("Change background", isPresented: $showingConfirmation) {
                    Button("Red") { backgroundColor = .red }
                    Button("Green") { backgroundColor = .green }
                    Button("Blue") { backgroundColor = .blue }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Select a new color")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
