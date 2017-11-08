//
//  ViewController.swift
//  PredictiveTextField
//
//  Created by AJ Bartocci on 8/23/17.
//  Copyright © 2017 AJ Bartocci. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: PredictiveTextField! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textField.predictionDataSource = self
        textField.delegate = self 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func resetText() {
        textField.text = ""
    }

}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
}

extension ViewController: PredictiveTextFieldDataSource {
    
    func predictiveTextField(_ textField: UITextField, suggestionForInput input: String) -> String? {
        
        guard let text = textField.text, text.characters.count > 0 else {
            return nil 
        }
        
        let prediction = "this is a test"
        
        if prediction.lowercased().hasPrefix(input.lowercased()) {
            return prediction
        }
        return nil
    }
}

