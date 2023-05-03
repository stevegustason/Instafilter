//
//  ContentView.swift
//  Instafilter
//
//  Created by Steven Gustason on 5/1/23.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var blurAmount = 0.0
    @State private var showingConfirmation = false
    @State private var backgroundColor = Color.white
    @State private var image: Image?
    @State private var showingImagePicker = false
    
    // Property to pass into our ImagePicker so it can be updated when the user selects an image
    @State private var inputImage: UIImage?
    
    // Method that checks whether inputImage has a value, and if it does uses it to assign a new Image view to the image property. Also, save the image that got loaded to the user's photo album.
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
        // This method saves images to the user's photo albums. For its parameters: the first one is the image to save, the second one is an object that should be notified about the result of the save, the third one is the method on the object that should be run, and the fourth one will be passed back to us when our completion method is called.
        UIImageWriteToSavedPhotosAlbum(inputImage, nil, nil, nil)
    }
    
    /*
    func loadImage() {
        // Load our example image into a UIImage
        guard let inputImage = UIImage(named: "Zelda") else { return }
        // Convert our UIImage to a CIImage so we can work with Core Image
        let beginImage = CIImage(image: inputImage)

        // Create a context to handle converting our processed data into a CGImage we can work with
        let context = CIContext()
        
        /*
        // Create a sepia filter
        let currentFilter = CIFilter.sepiaTone()
        // Apply our sepia filter to our image
        currentFilter.inputImage = beginImage
        // At full intensity
        currentFilter.intensity = 1
         */
        
        /*
        // Pixelate filter to make the image look like a pixel image
        let currentFilter = CIFilter.pixellate()
        currentFilter.inputImage = beginImage
        currentFilter.scale = 100
        */
        
        /*
        // Crystallize filter to make the image look like stained glass
        let currentFilter = CIFilter.crystallize()
        currentFilter.inputImage = beginImage
        currentFilter.radius = 200
        */
        
        /*
        // Twirl filter to add a swirl in the image
        let currentFilter = CIFilter.twirlDistortion()
        currentFilter.inputImage = beginImage
        currentFilter.radius = 1000
        currentFilter.center = CGPoint(x: inputImage.size.width / 2, y: inputImage.size.height / 2)
         */
        
        // Using the older API as we do in the chunk below allows us to set values dynamically - we canliterally ask the current filter what values it supports, then send them on in. This allows us to swap in any different filter without changing our code. Generally, using the modern API is better, but this will give us some more flexibility.
        let currentFilter = CIFilter.twirlDistortion()
        currentFilter.inputImage = beginImage

        let amount = 1.0

        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(amount, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(amount * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(amount * 10, forKey: kCIInputScaleKey) }
        
        // Get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage else { return }

        // Attempt to get a CGImage from our CIImage
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            // Convert that to a UIImage
            let uiImage = UIImage(cgImage: cgimg)

            // And convert that to a SwiftUI image
            image = Image(uiImage: uiImage)
        }
    }
    */

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
            
            image?
                .resizable()
                .scaledToFit()
            
            Button("Select Image") {
                showingImagePicker = true
            }
            Button("Save Image") {
                guard let inputImage = inputImage else { return }

                let imageSaver = ImageSaver()
                imageSaver.writeToPhotoAlbum(image: inputImage)
            }
        }
        .onAppear(perform: loadImage)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { _ in loadImage() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
