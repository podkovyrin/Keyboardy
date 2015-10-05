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
    case ActiveWithHeight(CGFloat)
    case Hidden
}


/**
    Keyboard delegate
*/
public protocol KeyboardStateDelegate: class {
    
    /**
        Notifies the receiver that the keyboard will show or hide with specified parameters. This method is called before keyboard animation.
    
        - parameter state: Keyboard state
    */
    func keyboardWillTransition(state: KeyboardState)
    
    /**
        Keyboard animation. This method is called inside `UIView` animation block with the same animation parameters as keyboard animation.
    
        - parameter state: Keyboard state
    */
    func keyboardTransitionAnimation(state: KeyboardState)
    
    
    /**
        Notifies the receiver that the keyboard animation finished. This method is called after keyboard animation.
        
        - parameter state: Keyboard state
    */
    func keyboardDidTransition(state: KeyboardState)
}


// MARK: - Keyboardy

public extension UIViewController {
    
    // MARK: Public
    
    /// Current keyboard state
    public var keyboardState: KeyboardState {
        return keyboardHeight > 0 ? .ActiveWithHeight(keyboardHeight) : .Hidden
    }
    
    /**
        Register for `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification` notifications.
    
        - parameter keyboardStateDelegate: Keyboard state delegate

        :discussion: It is recommended to call this method in `viewWillAppear:`
    */
    public func registerForKeyboardNotifications(keyboardStateDelegate: KeyboardStateDelegate) {
        self.keyboardStateDelegate = keyboardStateDelegate
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector:"keyboardWillShow:", name:UIKeyboardWillShowNotification, object:nil)
        defaultCenter.addObserver(self, selector:"keyboardWillHide:", name:UIKeyboardWillHideNotification, object:nil)
    }
    
    /**
        Unregister from `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification` notifications.
    
        :discussion: It is recommended to call this method in `viewWillDisappear:`
    */
    public func unregisterFromKeyboardNotifications() {
        self.keyboardStateDelegate = nil
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.removeObserver(self, name:UIKeyboardWillShowNotification, object:nil)
        defaultCenter.removeObserver(self, name:UIKeyboardWillHideNotification, object:nil)
    }
    
    // MARK: Private
    
    /// Handler for `UIKeyboardWillShowNotification`
    private dynamic func keyboardWillShow(n: NSNotification) {
        if let userInfo = n.userInfo,
            rect = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue,
            duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue,
            curve = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.integerValue {
                let convertedRect = view.convertRect(rect, fromView: nil)
                let height = max(0, view.bounds.size.height - convertedRect.origin.y)
                
                keyboardHeight = height
                keyboardAnimationToState(.ActiveWithHeight(keyboardHeight), duration:duration, curve:UIViewAnimationCurve(rawValue: curve)!)
        }
    }
    
    /// Handler for `UIKeyboardWillHideNotification`
    private dynamic func keyboardWillHide(n: NSNotification) {
        if let userInfo = n.userInfo,
            duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue,
            curve = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.integerValue {
                
                keyboardHeight = 0.0
                keyboardAnimationToState(.Hidden, duration:duration, curve:UIViewAnimationCurve(rawValue: curve)!)
        }
    }
    
    /// Keyboard animation
    private func keyboardAnimationToState(state: KeyboardState, duration: NSTimeInterval, curve: UIViewAnimationCurve) {
        keyboardStateDelegate?.keyboardWillTransition(state)
        
        UIView.beginAnimations(nil, context:nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStopSelector("keyboardAnimationDidStop:finished:context:")
        
        keyboardStateDelegate?.keyboardTransitionAnimation(state)
        
        UIView.commitAnimations()
    }
    
    /// Keyboard animation did stop selector
    private dynamic func keyboardAnimationDidStop(animationID: String?, finished: Bool, context: UnsafeMutablePointer<Void>) {
        keyboardStateDelegate?.keyboardDidTransition(keyboardState)
    }
    
    // MARK: Private Variables
    
    /**
    Associated keys for private properties
    */
    private struct AssociatedKeys {
        static var KeyboardHeight: UInt8 = 0
        static var KeyboardDelegate: UInt8 = 0
    }
    
    /// Class-container to provide weak semantics for associated properties
    private class WeakObjectContainer {
        weak var delegate: KeyboardStateDelegate?
        
        init(_ delegate: KeyboardStateDelegate?) {
            self.delegate = delegate
        }
    }
    
    /// Keyboard state delegate container
    private var keyboardStateDelegate: KeyboardStateDelegate? {
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
    private var keyboardHeight: CGFloat {
        get {
            if let keyboardHeight = objc_getAssociatedObject(self, &AssociatedKeys.KeyboardHeight) as? NSNumber {
                return CGFloat(keyboardHeight.floatValue)
            }
            return 0.0
        }
        set {
            objc_setAssociatedObject(self,
                &AssociatedKeys.KeyboardHeight,
                NSNumber(float: Float(newValue)),
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
