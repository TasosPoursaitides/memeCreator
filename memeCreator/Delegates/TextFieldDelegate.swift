//
//  TextFieldDelegate.swift
//  memeCreator
//
//  Created by Anastasios Poursaitedes on 18/8/20.
//  Copyright © 2020 Anastasios Poursaitedes. All rights reserved.
//

import Foundation
import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        /*
         This little conditional determines which text field did we press into.
         The top text field has a tag of zero. I change the tag to 2 so that when the view
         controller hears the notification and sees that the top text field has the tag 2
         it will prevent the view from sliding up because we don't need that for the top
         text field
         */
        textField.tag = textField.tag == 0 ? 2 : 1;
        
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}
