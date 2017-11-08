//
//  PredictiveTextField.swift
//  PredictiveTextField
//
//  Created by AJ Bartocci on 8/23/17.
//  Copyright © 2017 AJ Bartocci. All rights reserved.
//

import UIKit
import MapKit

/**
 Data source required for supplying predictions
 
 * predictiveTextField(_ textField: UITextField, suggestionForInput input: String) -> String?
 */
protocol PredictiveTextFieldDataSource: class {
    /// Supplies prediction that will fill the textField
    func predictiveTextField(_ textField: UITextField, suggestionForInput input: String) -> String?
}

/// UITextField that supplies a prediction as users type
@IBDesignable
class PredictiveTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var textOffset: CGFloat = 2.0
    @IBInspectable var placeHolderColor: UIColor = .lightGray
    @IBInspectable var borderColor: UIColor = .black
    @IBInspectable var borderWidth: CGFloat = 1.0
    
    fileprivate weak var userDelegate: UITextFieldDelegate?
    /** PredictiveTextField overrides and passes
     
    * textFieldShouldReturn(_ textField: UITextField) -> Bool
    * textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)
    */
    fileprivate var tapView = UIView()
    override var delegate: UITextFieldDelegate? {
        get {
            return userDelegate
        }
        set {
            userDelegate = newValue
        }
    }
    
    /// Return action dismisses keyboard
    @IBInspectable var endEditingOnReturn: Bool = true
    /// Color for prediction text
    @IBInspectable var predictionColor: UIColor = UIColor.lightGray
    /// Formats PredictiveTextField text to case of the prediction, defaults true 
    @IBInspectable var formatsCase: Bool = true
    
    /// Data source for supplying predictions
    weak var predictionDataSource: PredictiveTextFieldDataSource?
    /// The user generated text
    var userText: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate var kvoContext = UnsafeMutableRawPointer(bitPattern: 13371237)
    fileprivate func setup() {
        tapView.backgroundColor = .clear
        self.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        super.delegate = self
        
//        self.addObserver(self, forKeyPath: #keyPath(UITextField.text), options: .new, context: &kvoContext)
    }
//    override func prepareForInterfaceBuilder() {
//        
//    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
//        guard context == kvoContext else {
//            // change didn't occur from here so call super
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: &kvoContext)
//            userText = self.text ?? ""
//            return
//        }
//        
//        if (object as? PredictiveTextField) == self {
//            if keyPath == #keyPath(UITextField.text) {
//                // do logic here
//            }
//        }
    }
    
    func textDidChange() {
        
        // TODO: address this issue
        // depends on whether programmatic changes calls this
        // for command backspace edge case
//        let text = self.text ?? ""
//        if userText.hasSuffix(text) {
//            self.text = ""
//            userText = ""
//        }
    }
    
    
//    func getSuggestion(for text: String?) -> String {
//        
//        let input = text ?? ""
//        return predictionDataSource?.predictiveTextField(self, suggestionForInput: input) ?? ""
//    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        let insets = UIEdgeInsetsMake(0, textOffset, 0, textOffset)
        return UIEdgeInsetsInsetRect(rect, insets)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        let insets = UIEdgeInsetsMake(0, textOffset, 0, textOffset)
        return UIEdgeInsetsInsetRect(rect, insets)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        let place = self.placeholder ?? ""
        let placeTxt = NSAttributedString(string: place, attributes: [NSForegroundColorAttributeName: placeHolderColor])
        self.attributedPlaceholder = placeTxt
        tapView.frame = self.bounds
    }
    
    // can add check for case as well
    func textChangeFrom(_ fromString: String, toString: String) -> TextChange {
        
        if let addition = checkForAdditon(fromString: fromString, toString: toString) {
            return .added(text: addition)
        } else if let removal = checkForRemoval(fromString: fromString, toString: toString) {
            return .removed(text: removal.0, added: removal.1)
        } else {
            return .none
        }
    }
    
    private func checkForRemoval(fromString: String, toString: String) -> (String, String?)? {
        
        if let fromChange = checkForSuffixChange(fromString: fromString, toString: toString) {
            let toChange = checkForSuffixChange(fromString: toString, toString: fromString)
            return (fromChange, toChange)
        } else if let toChange = checkForSuffixChange(fromString: toString, toString: fromString) {
            return (toChange, nil)
        }
        
        return nil
    }
    
    private func checkForAdditon(fromString: String, toString: String) -> String? {
        
        if toString.characters.count > fromString.characters.count {
            // addition
            
            let change = checkForSuffixChange(fromString: fromString, toString: toString)!
            let addition = String(change)
            return addition
        } else {
            return nil
        }
    }
    
    private func checkForSuffixChange(fromString: String, toString: String) -> String? {
        
        var changes: [Character] = []
        
        // go forwards, the first string that does not match means
        // the rest of the string is the change
        
        var fromIndex = fromString.characters.startIndex
        let lastFromIndex = fromString.characters.count - 1
        for char in toString.characters.enumerated() {
            if char.offset > lastFromIndex {
                changes.append(char.element)
            } else {
                let fromChar = fromString.characters[fromIndex]
                if char.element == fromChar {
                    // move the index to next position and loop again
                    let index = fromString.characters.index(after: fromIndex)
                    fromIndex = index
                } else {
                    // doesn't match add this and rest of to string
                    // to char array
                    let chars = fromString.characters.suffix(from: fromIndex)
                    changes = Array(chars)
                    break
                }
            }
        }
        
        return changes.count != 0 ? String(changes) : nil
    }
}

extension PredictiveTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        textField.isUserInteractionEnabled = false
        self.addSubview(tapView)
        let cursorPos = userText.characters.count
        moveCursorToLocation(cursorPos)
        userDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        textField.isUserInteractionEnabled = true
        tapView.removeFromSuperview()
        userDelegate?.textFieldDidEndEditing?(textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // blank string "" means backspace
        
        // separate usertext from text 
        
        // edge case for selections 
        
        let text = textField.text ?? ""
        let nsText = text as NSString
        let newText: String
        if string == "" {
            let user = userText.lowercased().characters.dropLast()
            if String(user) == text.lowercased() {
                newText = nsText.replacingCharacters(in: range, with: string) as String
            } else {
                if range.location < userText.characters.count {
                    let length = userText.characters.count - range.location
                    let rng = NSRange(location: range.location, length: length)
                    let txt = userText as NSString
                    newText = txt.replacingCharacters(in: rng, with: string) as String
                } else {
                    newText = String(userText.characters.dropLast())
                }
            }
        } else {
            newText = userText.appending(string)
        }
        
        let textChange = textChangeFrom(userText, toString: newText)
        switch textChange {
        case .added(text: let add):
            let newUser = userText.appending(add)
            userText = newUser
            break
        case .removed(text: let remove, added: let add):
            let prefixLength = userText.characters.count - remove.characters.count
            var newUser = userText.characters.prefix(prefixLength)
            if let add = add {
                newUser.append(contentsOf: add.characters)
            }
            userText = String(newUser)
            break
        case .none:
            break
        }
        
        if userText.characters.count == 0 {
            forceUserInput(string: "")
            return userDelegate?.textField?(self, shouldChangeCharactersIn: range, replacementString: string) ?? false
        }
        
        let finalText: String
        
        if let prediction = predictionDataSource?.predictiveTextField(self, suggestionForInput: userText) {
            finalText = prediction
            let prefixLength = userText.characters.count
            let matchedCase = finalText.characters.prefix(prefixLength)
            // TODO: add a matching case check if user wants?
            if formatsCase {
                userText = String(matchedCase)
            }
        } else {
            finalText = userText
        }
        
        formatText(fullText: finalText, userInput: userText)
        
        let cursorPos = userText.characters.count
        moveCursorToLocation(cursorPos)

        return userDelegate?.textField?(self, shouldChangeCharactersIn: range, replacementString: string) ?? false
    }
    
    /// Styles fullText to the textColor and userInput to predictionColor
    func formatText(fullText: String, userInput: String) {
        
        // TODO: check if all caps etc
        
//        let full = fullText.uppercased()
        let full = fullText
        
        let userCol = textColor ?? UIColor.black
        let attrString = NSMutableAttributedString(string: full, attributes: [NSForegroundColorAttributeName: predictionColor])
        let userRange = NSRange(location: 0, length: userInput.characters.count)
        attrString.addAttribute(NSForegroundColorAttributeName, value: userCol, range: userRange)
        
        self.attributedText = attrString
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // if a match set to prediction
        if let prediction = predictionDataSource?.predictiveTextField(self, suggestionForInput: userText) {
            formatText(fullText: prediction, userInput: prediction)
            userText = prediction
        }
        
        let shouldReturn = userDelegate?.textFieldShouldReturn?(self) ?? true
        
        if endEditingOnReturn && shouldReturn {
            self.endEditing(true)
        }
        return shouldReturn
    }
    
    func forceUserInput(string: String) {
        self.text = string
        userText = string
        formatText(fullText: string, userInput: string)
    }
}

// perform kvo on delegate for the two calls we need
// that way the user can still set the delegate

extension PredictiveTextField {
    func moveCursorToLocation(_ loc: Int) {
        let range = NSRange(location: loc, length: 0)
        let start = self.position(from: self.beginningOfDocument, offset: loc)!
        let end = self.position(from: start, offset: range.length)!
        self.selectedTextRange = self.textRange(from: start, to: end)
    }
}


