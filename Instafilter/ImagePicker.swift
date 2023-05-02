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
    func makeUIViewController(context: Context) -> PHPickerViewController {
        // Create a new photo picker configuration
        var config = PHPickerConfiguration()
        // Ask it to provide only images
        config.filter = .images

        // Create and return a PHPickerViewController that does the actual work of selecting an image
        let picker = PHPickerViewController(configuration: config)
        return picker
    }
    
    // We won't be using this method, so this doesn't actually have any code inside
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
}
