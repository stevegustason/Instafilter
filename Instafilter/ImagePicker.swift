//
//  ImagePicker.swift
//  Instafilter
//
//  Created by Steven Gustason on 5/2/23.
//

import PhotosUI
import SwiftUI
import Foundation

// Struct to wrap our UIKit view controller. To conform to UIViewControllerRepresentable, we need a makeUIViewController and updateUIViewController method.
struct ImagePicker: UIViewControllerRepresentable {
    // Binding to report back the selected image to ContentView
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        // Create a new photo picker configuration
        var config = PHPickerConfiguration()
        // Ask it to provide only images
        config.filter = .images

        // Create and return a PHPickerViewController that does the actual work of selecting an image
        let picker = PHPickerViewController(configuration: config)
        // When something happens, tell our coordinator
        picker.delegate = context.coordinator
        return picker
    }
    
    // We won't be using this method, so this doesn't actually have any code inside
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    // Our class inherits from NSObject, which allows Objective-C to ask the object what functionality it supports at runtime, which means the photo picker can say things like “hey, the user selected an image, what do you want to do?”. Our class also conforms to the PHPickerViewControllerDelegate protocol, which is what adds functionality for detecting when the user selects an image.
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        // Here we do three things: 1. Tell the picker to dismiss itself. 2. Exit if the user made no selection – if they tapped Cancel. 3. Otherwise, see if the user’s results includes a UIImage we can actually load, and if so place it into the parent.image property.
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Tell the picker to go away
            picker.dismiss(animated: true)

            // Exit if no selection was made
            guard let provider = results.first?.itemProvider else { return }

            // If this has an image we can use, use it
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image = image as? UIImage
                }
            }
        }
        
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
    }
    
    // Make it so our ImagePicker uses our coordinator class for its coordinator. SwiftUI calls this method automatically when an instance of ImagePicker is created
    func makeCoordinator() -> Coordinator {
        // Here we pass our current ImagePicker struct into the coordinator
        Coordinator(self)
    }
}
