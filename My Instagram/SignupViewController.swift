//
//  SignupViewController.swift
//  My Instagram
//
//  Created by Ankita Satpathy on 07/02/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmpwField: UITextField!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    let picker = UIImagePickerController()
    var userStorage : FIRStorageReference!
    var ref :FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        let storage = FIRStorage.storage().reference(forURL: "gs://my-instagram-423eb.appspot.com")
       userStorage = storage.child("users")
        
        ref = FIRDatabase.database().reference()
    }
    
    
    @IBAction func selectpicPressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.imageview.image = image
            self.nextBtn.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextPressed(_ sender: Any) {
        
        guard nameLabel.text != "" ,emailField.text != "" , passwordField.text != "" , confirmpwField.text != "" else {
            return
        }
        
        if passwordField.text == confirmpwField.text {
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                if let user = user {
                    
                    let changeRequest = FIRAuth.auth()!.currentUser?.profileChangeRequest()
                    changeRequest?.displayName = self.nameLabel.text!
                    changeRequest?.commitChanges(completion: nil)
                    
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    let data = UIImageJPEGRepresentation(self.imageview.image!, 0.5)
                    let uploadTask = imageRef.put(data!, metadata: nil, completion: { (metadata, err) in
                        if err != nil{
                            print(err!.localizedDescription)
                        }
                        imageRef.downloadURL(completion: { (url, er) in
                            if er != nil{
                                print(er!.localizedDescription)
                            }
                            if let url = url{
                                let userInfo : [String :Any] = ["uid" : user.uid,
                                                                "full name" : self.nameLabel.text!,
                                                                "urltoImage" : url.absoluteString]
                                self.ref.child("users").child(user.uid).setValue(userInfo)
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                          self.present(vc, animated: true, completion: nil)
                            }
                        })
                    })
                    uploadTask.resume()
                }
            })
        }
        else {
            print("password does not match")
        }
    }

   
}
