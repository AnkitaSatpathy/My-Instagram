//
//  LoginViewController.swift
//  My Instagram
//
//  Created by Ankita Satpathy on 07/02/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }

    @IBAction func loginPressed(_ sender: Any) {
        AppDelegate.intance().showIndicator()
        guard emailField.text != "" , passwordField.text != "" else {
            return
        }
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            
            if user != nil{
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                self.present(vc, animated: true, completion: nil)
                AppDelegate.intance().dismissActivityIndicator()
            }
        })
        
        
    }
    

    
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
