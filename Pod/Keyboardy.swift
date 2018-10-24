//
//  Keyboardy.swift
//
//  Created by Andrew Podkovyrin on 25/07/15.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit
import ObjectiveC


/**
    Keyboard state

    - ActiveWithHeight: Keyboard is visible with provided height
    - Hidden: Keyboard is hidden
*/
public enum KeyboardState {
    case activeWithHeight(CGFloat)
    case hidden
}


/**
    Keyboard delegate
*/
public protocol KeyboardStateDelegate: class {
    
    /**
        Notifies the receiver that the keyboard will show or hide with specified parameters. This method is called before keyboard animation.
    
        - parameter state: Keyboard state
    */
    func keyboardWillTransition(_ state: KeyboardState)
    
    /**
        Keyboard animation. This method is called inside `UIView` animation block with the same animation parameters as keyboard animation.
    
        - parameter state: Keyboard state
    */
    func keyboardTransitionAnimation(_ state: KeyboardState)
    
    
    /**
        Notifies the receiver that the keyboard animation finished. This method is called after keyboard animation.
        
        - parameter state: Keyboard state
    */
    func keyboardDidTransition(_ state: KeyboardState)
}


// MARK: - Keyboardy

public extension UIViewController {
    
    // MARK: Public
    
    /// Current keyboard state
    public var keyboardState: KeyboardState {
        return keyboardHeight > 0 ? .activeWithHeight(keyboardHeight) : .hidden
    }
    
    /**
        Register for `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification` notifications.
    
        - parameter keyboardStateDelegate: Keyboard state delegate

        :discussion: It is recommended to call this method in `viewWillAppear:`
    */
    public func registerForKeyboardNotifications(_ keyboardStateDelegate: KeyboardStateDelegate) {
        self.keyboardStateDelegate = keyboardStateDelegate
        
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector:#selector(UIViewController._keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object:nil)
        defaultCenter.addObserver(self, selector:#selector(UIViewController._keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object:nil)
    }
    
    /**
        Unregister from `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification` notifications.
    
        :discussion: It is recommended to call this method in `viewWillDisappear:`
    */
    public func unregisterFromKeyboardNotifications() {
        self.keyboardStateDelegate = nil
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.removeObserver(self, name:UIResponder.keyboardWillShowNotification, object:nil)
        defaultCenter.removeObserver(self, name:UIResponder.keyboardWillHideNotification, object:nil)
    }
    
    // MARK: Private
    
    /// Handler for `UIKeyboardWillShowNotification`
    @objc fileprivate dynamic func _keyboardWillShow(_ n: Notification) {
        if let userInfo = n.userInfo,
            let rect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue {
            
                let convertedRect = view.convert(rect, from: nil)
                let height = convertedRect.height

                keyboardHeight = height
                keyboardAnimationToState(.activeWithHeight(keyboardHeight), duration:duration, curve:UIView.AnimationCurve(rawValue: curve)!)
            
        }
    }
    
    /// Handler for `UIKeyboardWillHideNotification`
    @objc fileprivate dynamic func _keyboardWillHide(_ n: Notification) {
        if let userInfo = n.userInfo,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue {
            
                keyboardHeight = 0.0
                keyboardAnimationToState(.hidden, duration:duration, curve:UIView.AnimationCurve(rawValue: curve)!)
        }
    }
    
    /// Keyboard animation
    fileprivate func keyboardAnimationToState(_ state: KeyboardState, duration: TimeInterval, curve: UIView.AnimationCurve) {
        keyboardStateDelegate?.keyboardWillTransition(state)
        
        UIView.beginAnimations(nil, context:nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(UIViewController.keyboardAnimationDidStop(_:finished:context:)))
        
        keyboardStateDelegate?.keyboardTransitionAnimation(state)
        
        UIView.commitAnimations()
    }
    
    /// Keyboard animation did stop selector
    @objc fileprivate dynamic func keyboardAnimationDidStop(_ animationID: String?, finished: Bool, context: UnsafeMutableRawPointer) {
        keyboardStateDelegate?.keyboardDidTransition(keyboardState)
    }
    
    // MARK: Private Variables
    
    /**
    Associated keys for private properties
    */
    fileprivate struct AssociatedKeys {
        static var KeyboardHeight: UInt8 = 0
        static var KeyboardDelegate: UInt8 = 0
    }
    
    /// Class-container to provide weak semantics for associated properties
    fileprivate class WeakObjectContainer {
        weak var delegate: KeyboardStateDelegate?
        
        init(_ delegate: KeyboardStateDelegate?) {
            self.delegate = delegate
        }
    }
    
    /// Keyboard state delegate container
    fileprivate var keyboardStateDelegate: KeyboardStateDelegate? {
        get {
            if let delegateContainer = objc_getAssociatedObject(self, &AssociatedKeys.KeyboardDelegate) as? WeakObjectContainer {
                return delegateContainer.delegate
            } else {
                return nil
            }
        }
        set {
            let value: WeakObjectContainer? = newValue != nil ? WeakObjectContainer(newValue!) : nil
            
            objc_setAssociatedObject(self,
                &AssociatedKeys.KeyboardDelegate,
                value,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    /// Keyboard height container
    fileprivate var keyboardHeight: CGFloat {
        get {
            if let keyboardHeight = objc_getAssociatedObject(self, &AssociatedKeys.KeyboardHeight) as? NSNumber {
                return CGFloat(keyboardHeight.floatValue)
            }
            return 0.0
        }
        set {
            objc_setAssociatedObject(self,
                &AssociatedKeys.KeyboardHeight,
                NSNumber(value: Float(newValue) as Float),
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
