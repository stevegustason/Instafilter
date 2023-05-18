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
    // Optional image property since the user won't have initially selected an image
    @State private var image: Image?
    // Controls the intensity of the filter applied to the user's image, and binds to the intensity slider
    @State private var filterIntensity = 0.5
    // Controls whether the image picker is displayed
    @State private var showingImagePicker = false
    // Property that will store the image the user selected
    @State private var inputImage: UIImage?
    // Set our current core image filter
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    // Create our context
    let context = CIContext()
    // Controls whether filter confirmation dialgoue is displayed
    @State private var showingFilterSheet = false
    // Store our temporary processed image that the user may want to save
    @State private var processedImage: UIImage?
    
    // Method that is called when the user clicks the save button. It will save the photo in its current state to the user's image library using our ImageSaver class method
    func save() {
        guard let processedImage = processedImage else { return }

        // Create an instance of ImageSaver
        let imageSaver = ImageSaver()

        // Define our success message
        imageSaver.successHandler = {
            print("Success!")
        }

        // Define our error message
        imageSaver.errorHandler = {
            print("Oops: \($0.localizedDescription)")
        }

        // Call our writeToPhotoAlbum method
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    // Method that is called when the ImagePicker is dismissed.
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        // Send the chosen image into our sepia filter, then use applyProcessing to apply it
        let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
    }
    
    func applyProcessing() {
        // Set our filter's settings based on the filterIntensity slider value - because we have multiple different filter options, we need to use setValue(:_forKey:). Also, not all filters have an intensity option, so we first check which settings are available and if they exist for that filter, then we will set them
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }

        // Read the output image back from the filter
        guard let outputImage = currentFilter.outputImage else { return }

        // Ask our CIContext to render it, then place the result into our image property so it’s visible on-screen. we'll also store the image in our processedImage property
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    // Method to set our filter to the selected filter, then re-load our image using that new filter
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    // Furthest back, we show a gray rectangle
                    Rectangle()
                        .fill(.secondary)
                    
                    // Then on top of that we have white foreground text
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    // However, once a user selects an image, the gray background and white text will be hidden by the image that is scaled to fit the whole space
                    image?
                        .resizable()
                        .scaledToFit()
                }
                // When the user clicks in this area, we'll display our image picker
                .onTapGesture {
                    showingImagePicker = true
                }
                
                // A slider for the user to adjust the intensity of the filter on their selected image
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                    // When we change the filterIntesity using the silder, we want to re-call applyProcessing to update the image's filter
                        .onChange(of: filterIntensity) { _ in
                                applyProcessing()
                            }
                }
                .padding(.vertical)
                
                // And finally two buttons - one to change which core filter is applied, and the other to save the photo to the user's image library
                HStack {
                    Button("Change Filter") {
                        showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save", action: save)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            // When inputImage changes, call loadImage to place our image in the UI
            .onChange(of: inputImage) { _ in loadImage() }
            // When the onTapGesture is triggered to update our showingImagePicker variable, we'll show an ImagePicker bound to inputImage
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            // Confirmation dialog works identically to alert - provide a title and condition to monitor, and as soon as the condition becomes true the confirmation dialog will be shown
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                // Here we  have a bunch of buttons to set the filter to different options, and a cancel button
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                Button("Edges") { setFilter(CIFilter.edges()) }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                Button("Vignette") { setFilter(CIFilter.vignette()) }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
