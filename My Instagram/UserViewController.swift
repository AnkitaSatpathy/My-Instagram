//
//  UserViewController.swift
//  My Instagram
//
//  Created by Ankita Satpathy on 07/02/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit
import Firebase

class UserViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    var user = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        retriveUsers()
        
    }

    func retriveUsers(){
        
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String:AnyObject]
            for (_ , value) in users{
                
                if let uid = value["uid"] as? String{
                    if uid != FIRAuth.auth()!.currentUser!.uid{
                        let usersToShow = User()
                       if  let fullname = value["full name"] as? String , let imagepath = value["urltoImage"] as? String
                        {
                            usersToShow.fullname = fullname
                            usersToShow.imageurl = imagepath
                            usersToShow.userID = uid
                            self.user.append(usersToShow)
                            
                        }
                    }
                }
            }
            self.tableview.reloadData()
        })
        ref.removeAllObservers()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! userCell
        
        cell.nameLabel.text = self.user[indexPath.row].fullname
        cell.userID = self.user[indexPath.row].userID
        cell.imageview.layer.cornerRadius =   cell.imageview.frame.size.width / 2;
        cell.imageview.clipsToBounds = true;
        
        cell.imageview.downloadImage(from: self.user[indexPath.row].imageurl!)
        checkFollowing(indexPath: indexPath)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollwer = false
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let following = snapshot.value as? [String : AnyObject]{
                for (ke , value) in following {
                    if value as! String == self.user[indexPath.row].userID {
                        isFollwer = true
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.user[indexPath.row].userID).child("followers/\(ke)").removeValue()
                        self.tableview.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            
            if !isFollwer {
                let following = ["following/\(key)" : self.user[indexPath.row].userID]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.user[indexPath.row].userID).updateChildValues(followers)
                
                self.tableview.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        })
        ref.removeAllObservers()
    }
    
    func checkFollowing(indexPath: IndexPath) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for (_, value) in following {
                    if value as! String == self.user[indexPath.row].userID {
                        self.tableview.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
        ref.removeAllObservers()
        
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
    }
    
}

extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
            
        }
        
        task.resume()
    }

   
}
