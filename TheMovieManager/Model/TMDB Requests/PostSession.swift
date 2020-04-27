//
//  PostSession.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct PostSession: Codable {
    var requestToken: String
    
    enum Codingkeys: String, CodingKey {
        case requestToken = "request_token"
    }
}