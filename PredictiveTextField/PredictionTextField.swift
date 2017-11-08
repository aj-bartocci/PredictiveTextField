//
//  PredictionTextField.swift
//  PredictiveTextField
//
//  Created by Albert Bartocci on 10/16/17.
//  Copyright © 2017 AJ Bartocci. All rights reserved.
//

import UIKit

@IBDesignable class PredictionTextField: UITextField {
    
    @IBInspectable var textOffset: CGFloat = 2.0
    @IBInspectable var placeHolderColor: UIColor = .lightGray
    @IBInspectable var borderColor: UIColor = .black
    @IBInspectable var borderWidth: CGFloat = 1.0
    
    @IBInspectable var backupFont: UIFont?
    
    fileprivate var predictLabel = UILabel()
    fileprivate weak var _delegate: UITextFieldDelegate?
    override weak var delegate: UITextFieldDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
//            delegateHandler.setPassThroughDelegate(_delegate)
        }
    }
    
    fileprivate lazy var delegateHandler: PredictionTextFieldDelegateHandler = {
       let handler = PredictionTextFieldDelegateHandler(passThroughDelegate: self._delegate)
        return handler
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
    }
    
}

extension PredictionTextField {
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        let insets = UIEdgeInsetsMake(0, textOffset, 0, textOffset)
        let editingRect = UIEdgeInsetsInsetRect(rect, insets)
        return editingRect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        let insets = UIEdgeInsetsMake(0, textOffset, 0, textOffset)
        let textRect = UIEdgeInsetsInsetRect(rect, insets)
        predictLabel.frame = textRect
        return textRect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        let place = self.placeholder ?? ""
        let placeTxt = NSAttributedString(string: place, attributes: [NSForegroundColorAttributeName: placeHolderColor])
        self.attributedPlaceholder = placeTxt
    }
}

extension PredictionTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        predictLabel.text = "Some really long text"
        
        return _delegate?.textFieldShouldReturn?(textField) ?? true
    }
}

class PredictionTextFieldDelegateHandler: NSObject, UITextFieldDelegate {
    
    fileprivate weak var passDelegate: UITextFieldDelegate?
    init(passThroughDelegate: UITextFieldDelegate?) {
        self.passDelegate = passThroughDelegate
    }
    
    func setPassThroughDelegate(_ delegate: UITextFieldDelegate?) {
        passDelegate = delegate
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        return passDelegate?.textFieldShouldReturn?(textField) ?? true
    }
}

class PredictionTextFieldDelegateProxy: NSObject, UITextFieldDelegate {
    
}

protocol PredictionTextFieldInterface {
    weak var delegate: PredictionTextFieldDelegate? { get set }
}

protocol PredictionTextFieldDelegate: UITextFieldDelegate {

}

extension PredictionTextFieldDelegate where Self: PredictionTextFieldInterface {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // defaults to true
        return delegate?.textFieldShouldClear?(textField) ?? true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // defaults to true
        return delegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        delegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
}

//    textFieldDidBeginEditing
//    textFieldShouldReturn
//    textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool

class blah: NSObject, UITextFieldDelegate {
    
    weak var delegate: PredictionTextFieldDelegate?
    
    
}

extension blah {
    // overrides
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // do whatever
        
        delegate?.textFieldDidBeginEditing?(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // do override here
        return delegate?.textFieldShouldReturn?(textField) ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // do override here
        return true
    }
}
