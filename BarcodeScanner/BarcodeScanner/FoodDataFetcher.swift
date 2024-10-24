//
//  FoodDataFetcher.swift
//  BarcodeScanner
//
//  Created by Tanay Reddy Gali on 7/26/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct Product: Codable, Identifiable {
    var id: String {
        return code
    }
    let code: String
    let product_name: String?
    let image_url: String?
    let nutriments: Nutriments?
}

struct Nutriments: Codable {
    let energy_100g: Double?
    let fat_100g: Double?
    let sugars_100g: Double?
    let proteins_100g: Double?
}

struct APIResponse: Codable {
    let product: Product?
}

extension Product {
    var healthinessScore: Int {
        guard let nutriments = nutriments else { return 0 }

        var score = 100

        if let energy = nutriments.energy_100g {
            score -= min(Int(energy) / 20, 30) 
        }
        if let fat = nutriments.fat_100g {
            score -= min(Int(fat) * 2, 20)
        }
        if let sugars = nutriments.sugars_100g {
            score -= min(Int(sugars) * 2, 30) 
        }
        if let proteins = nutriments.proteins_100g {
            score += min(Int(proteins) * 2, 20) 
        }

        return max(1, min(score, 100))
    }
}





class FoodDataFetcher: ObservableObject {
    @Published var product: Product?

    func fetchProduct(by barcode: String) {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let apiResponse = try decoder.decode(APIResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.product = apiResponse.product
                    }
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            }
        }

        task.resume()
    }
}
