


import SwiftUI
import AVFoundation
import Foundation





struct ContentView: View {
    @StateObject private var dataFetcher = FoodDataFetcher()
    @State private var isScanning = false

    var body: some View {
        NavigationView {
            VStack {
                if let product = dataFetcher.product {
                    Text(product.product_name ?? "Unknown Product")
                        .font(.headline)
                    
                    if let imageUrl = product.image_url, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                            } else if phase.error != nil {
                                Text("Failed to load image")
                            } else {
                                ProgressView()
                            }
                        }
                    }
                    
                    Text("Healthiness Score: \(product.healthinessScore)/100")
                        .font(.title)
                        .padding()
                    
                    if let nutriments = product.nutriments {
                        VStack(alignment: .leading) {
                            if let energy = nutriments.energy_100g {
                                Text("Energy: \(energy) kJ")
                            }
                            if let fat = nutriments.fat_100g {
                                Text("Fat: \(fat) g")
                            }
                            if let sugars = nutriments.sugars_100g {
                                Text("Sugars: \(sugars) g")
                            }
                            if let proteins = nutriments.proteins_100g {
                                Text("Proteins: \(proteins) g")
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("Scan a product barcode")
                }

                Spacer()

                if isScanning {
                    BarcodeScannerView { code in
                        isScanning = false
                        dataFetcher.fetchProduct(by: code)
                    }
                    .edgesIgnoringSafeArea(.all)
                } else {
                    Button(action: {
                        isScanning = true
                    }) {
                        Text("Start Scanning")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationBarTitle("NutriBuddy")
            .padding()
        }
    }
}
