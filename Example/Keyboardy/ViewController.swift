//
//  ViewController.swift
//  Keyboardy
//
//  Created by Andrew Podkovyrin on 07/25/2015.
//  Copyright (c) 2015 Andrew Podkovyrin. All rights reserved.
//

import UIKit


// 1. Import Keyboardy module

import Keyboardy


class ViewController: UIViewController {

    @IBOutlet weak var textFieldContainerBottomConstraint: NSLayoutConstraint!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 2. Register for keyboard notifications
        
        registerForKeyboardNotifications(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 3. Unregister from keyboard notifications
        
        unregisterFromKeyboardNotifications()
    }
}


// 4. Implement KeyboardStateDelegate protocol

extension ViewController: KeyboardStateDelegate {
    
    func keyboardWillTransition(_ state: KeyboardState) {
        // keyboard will show or hide
    }
    
    func keyboardTransitionAnimation(_ state: KeyboardState) {
        switch state {
        case .activeWithHeight(let height):
            textFieldContainerBottomConstraint.constant = height
        case .hidden:
            textFieldContainerBottomConstraint.constant = 0.0
        }
        
        view.layoutIfNeeded()
    }
    
    func keyboardDidTransition(_ state: KeyboardState) {
        // keyboard animation finished
    }
}


extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
