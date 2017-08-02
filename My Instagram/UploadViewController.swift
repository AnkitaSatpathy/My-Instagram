//
//  UploadViewController.swift
//  My Instagram
//
//  Created by Ankita Satpathy on 08/02/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit
import Firebase

class UploadViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var selectImage: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    
    let picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.previewImage.image = image
            selectImage.isHidden = true
            postBtn.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func selectPressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func postPressed(_ sender: Any) {
        
        AppDelegate.intance().showIndicator()
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage().reference(forURL: "gs://my-instagram-423eb.appspot.com")
        
        let key = ref.child("posts").childByAutoId().key
        let imageRef = storage.child("posts").child(uid).child("\(key).jpg")
        
        let data = UIImageJPEGRepresentation(self.previewImage.image!, 0.5)
        let uploadTask = imageRef.put(data!, metadata: nil, completion: { (metadata, err) in
            if err != nil{
                print(err!.localizedDescription)
                AppDelegate.intance().dismissActivityIndicator()
                return
            }
            imageRef.downloadURL(completion: { (url, er) in
                if er != nil{
                    print(er!.localizedDescription)
                }
                if let url = url{
                    let feed : [String :Any] = ["userID" : uid,
                                                    "likes" : 0,
                                                    "urltoImage" : url.absoluteString,
                                                    "Author" : FIRAuth.auth()!.currentUser!.displayName!,
                                                    "postID" : key]
                    let postfeed = ["\(key)" : feed]
                    ref.child("posts").updateChildValues(postfeed)
                    AppDelegate.intance().dismissActivityIndicator()
                    self.dismiss(animated: true, completion: nil)
                }
        
           })

       })
        uploadTask.resume()
   }
}
