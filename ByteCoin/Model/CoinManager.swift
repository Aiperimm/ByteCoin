//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation


protocol CoinManagerDelegate {
    
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/USD"
    let apiKey = "8CE50B21-AA26-4AF5-BC10-C6AC79A0715B"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        
        //Use String concatenation to add the selected currency at the end of the baseURL along with the API key.
        let urlString = "\(baseURL)/\(currency)?apiKey=\(apiKey)"
        
        //Use optional binding to unwrap the URL that's created from the urlString
        if let url = URL(string: urlString) {
            
            //Create a new URLSession object with default configuration.
            let session = URLSession(configuration: .default)
            //Create a new data task for the URLSession
            let task  = session.dataTask(with: url) { (data, responce, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    
                    if let bitcoinPrice = self.parseJSON(safeData) {
                        
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                        
                    }
                    
                }
                
            }
            task.resume() //Start task to fetch data from bitcoin average's servers.
            
        }
        
    }
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            print(lastPrice)
            return lastPrice
            
        } catch {
            
            print(error)
            return nil
        }
        
    }
}
