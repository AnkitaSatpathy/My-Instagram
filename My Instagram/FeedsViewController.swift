//
//  FeedsViewController.swift
//  My Instagram
//
//  Created by Ankita Satpathy on 08/02/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit
import Firebase

class FeedsViewController: UIViewController , UICollectionViewDataSource , UICollectionViewDelegate {
    
    @IBOutlet weak var collectionview: UICollectionView!
    var posts = [Post]()
    var following = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPosts()
    }
    
    
    
    func fetchPosts(){
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            for (_ , value) in users {
                if let uid = value["uid"] as? String {
                    if uid == FIRAuth.auth()!.currentUser?.uid {
                        if let followingUsers = value["following"] as? [String: String]{
                            for (_ , user) in followingUsers {
                                self.following.append(user)
                            }
                        }
                        
                        self.following.append(FIRAuth.auth()!.currentUser!.uid)
                        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
                            let postSnap = snap.value as! [String : AnyObject]
                            for (_ ,post) in postSnap {
                                if let userid = post["userID"] as? String {
                                    for each in self.following {
                                        if each == userid{
                                            let pos = Post()
                                            if let author = post["Author"] as? String, let likes = post["likes"] as? Int,let pathToImage = post["urltoImage"] as? String , let postid = post["postID"] as? String{
                                                pos.author = author
                                                pos.likes = likes
                                                pos.pathToImage = pathToImage
                                                pos.postID = postid
                                                pos.UserID = userid
                                                
                                                if let people = post["peopleWhoLike"] as? [String : AnyObject] {
                                                    for (_,person) in people {
                                                        pos.peopleWhoLike.append(person as! String)
                                                    }
                                                }
                                                
                                                self.posts.append(pos)
                                            }
                                        }
                                    }
                                    self.collectionview.reloadData()
                                }
                            }
                        })
                    }
                }
            }
        })
                        ref.removeAllObservers()
                        
    }
                    
                    func numberOfSections(in collectionView: UICollectionView) -> Int {
                        return 1
                    }
                    
                    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                        return self.posts.count
                    }
                    
                    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! postCell
                        
                        cell.authorLabel.text = self.posts[indexPath.row].author
                        cell.likeLabel.text = "\(self.posts[indexPath.row].likes!) likes"
                        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
                        cell.postID = self.posts[indexPath.row].postID
                                                for person in self.posts[indexPath.row].peopleWhoLike {
                            if person == FIRAuth.auth()!.currentUser!.uid {
                                cell.likeBtn.isHidden = true
                                cell.unlikeBtn.isHidden = false
                                break
                            }
                        }
                        return cell

                    }
}
