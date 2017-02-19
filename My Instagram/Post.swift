//
//  Post.swift
//  My Instagram
//
//  Created by Ankita Satpathy on 08/02/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit

class Post: NSObject {

    var author : String!
    var likes: Int!
    var pathToImage : String!
    var UserID: String!
    var postID: String!
    var peopleWhoLike: [String] = [String]()

}
