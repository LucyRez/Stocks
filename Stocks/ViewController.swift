//
//  ViewController.swift
//  Stocks
//
//  Created by Ludmila Rezunic on 13.12.2020.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var comanyNameLabel: UILabel!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.requestQuoteUpdate()
    }
    
    private let companies: [String:String] = ["Apple":"AAPL",
                                              "Microsoft":"MSFT",
                                              "Google":"GOOG",
                                              "Amazon":"AMZN",
                                              "Facebook":"FB"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.hidesWhenStopped = true
        
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        
        self.requestQuoteUpdate()
    }
    
    private func requestQuoteUpdate(){
        self.activityIndicator.startAnimating()
        self.comanyNameLabel.text = "-"
        self.companySymbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol)
    }
    
    private func requestQuote(for symbol:String){
        let url = URL(string: "https://cloud.iexapis.com/v1/stock/\(symbol)/quote?token=pk_25e21941845c4f51a74fe798445e666c")!
        let dataTask = URLSession.shared.dataTask(with: url){
            data, response, error in guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else{
                self.createAlert(withTitle: "Network error", andMessage: "problems with network")
                return
            }
        self.parseQuote(data:data)
        }
        dataTask.resume()
    }
    
    
    private func parseQuote(data:Data){
        do{
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            guard
                let json = jsonObject as? [String:Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double
            else{
                print("Invalid JSON format")
                return
            }
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName, symbol: companySymbol, price: price, priceChange: priceChange)
                
            }
            
            print("Company name is: '\(companyName)'");
        }catch{
            self.createAlert(withTitle: "JSON parsing error", andMessage: "JSON parsing error: " + error.localizedDescription)
        }
    }
   
    private func createAlert(withTitle title: String, andMessage message: String) {
           DispatchQueue.main.async {
               let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
               
               alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
               
               self.present(alert, animated: true)
           }
       }
    
    private func displayStockInfo(companyName:String, symbol:String, price:Double, priceChange:Double){
        self.activityIndicator.stopAnimating()
        self.comanyNameLabel.text = companyName
        self.companySymbolLabel.text = symbol
        self.priceLabel.text = "\(price)"
        self.priceChangeLabel.text = "\(priceChange)"
        
        if priceChange<0 {
            priceChangeLabel.textColor = .red
        }else if priceChange>0 {
            priceChangeLabel.textColor = .green
        }else{
            priceChangeLabel.textColor = .black
        }
        
        
    }
}

