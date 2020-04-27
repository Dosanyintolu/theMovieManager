//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "c4914f7c7de8552426573766c8c7b038"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        static let authenticateToken = "/authentication/token/new"
        static let validateLogin = "/authentication/token/validate_with_login"
        static let createSession = "/authentication/session/new"
        static let webLink = "https://www.themoviedb.org/authenticate/"
        static let webQuery = "?redirect_to=themoviemanager:authenticate"
        
        case getWatchlist
        case getRequestToken
        case login
        case createSessionId
        case webAuth
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getRequestToken: return Endpoints.base + Endpoints.authenticateToken + Endpoints.apiKeyParam
            case .login: return Endpoints.base + Endpoints.validateLogin + Endpoints.apiKeyParam
            case .createSessionId: return Endpoints.base + Endpoints.createSession + Endpoints.apiKeyParam
            case .webAuth: return Endpoints.webLink + Auth.requestToken + Endpoints.webQuery
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getRequestToken(completionHandler: @escaping (Bool, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getRequestToken.url) { (data, response, error) in
            guard let data = data else {
                completionHandler(false, error)
                return
            }
            let decoder = JSONDecoder()
            
            do{
                let requestToken = try decoder.decode(RequestToken.self, from: data)
                Auth.requestToken = requestToken.requestToken
                completionHandler(true, nil)
            } catch {
                print(error.localizedDescription)
            }
            
        }
        task.resume()
    }
    
    class func login(username: String, password: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
        do {
        request.httpBody = try JSONEncoder().encode(body)
            completionHandler(true, nil)
        } catch {
            print(error.localizedDescription)
        }
        let task = URLSession.shared.dataTask(with: request) { (data, reponse, error) in
            guard let data = data else {
                return
            }
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(RequestToken.self, from: data)
                Auth.requestToken = responseObject.requestToken
                completionHandler(true, nil)
            } catch {
                completionHandler(false, error)
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    class func session(completionHandler: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.createSessionId.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        let body = PostSession(requestToken: Auth.requestToken)
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print(error.localizedDescription)
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completionHandler(false, error)
                return
            }
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(SessionResponse.self, from: data)
                Auth.sessionId = responseObject.sessionId
                completionHandler(true, nil)
            } catch {
                completionHandler(false, error)
            }
        }
        task.resume()
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getWatchlist.url) { data, response, error in
            guard let data = data else {
                completion([], error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(MovieResults.self, from: data)
                completion(responseObject.results, nil)
            } catch {
                completion([], error)
            }
        }
        task.resume()
    }
}
