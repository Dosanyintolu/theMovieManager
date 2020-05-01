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
        static let logoutLink = "/authentication/session"
        
        case getWatchlist
        case getRequestToken
        case login
        case createSessionId
        case webAuth
        case logout
        case getFavorites
        case search(String)
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getRequestToken: return Endpoints.base + Endpoints.authenticateToken + Endpoints.apiKeyParam
            case .login: return Endpoints.base + Endpoints.validateLogin + Endpoints.apiKeyParam
            case .createSessionId: return Endpoints.base + "/authentication/session/new" + "?api_key=\(TMDBClient.apiKey)"
            case .webAuth: return Endpoints.webLink + Auth.requestToken + Endpoints.webQuery
            case .logout: return Endpoints.base + Endpoints.logoutLink + Endpoints.apiKeyParam
            case .getFavorites: return Endpoints.base + "/account/\(Auth.accountId)/favorite/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .search(let query): return Endpoints.base + "/search/movies" + Endpoints.apiKeyParam + "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
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
        
        taskPOSTRequest(url: Endpoints.login.url, body: LoginRequest(username: username, password: password, requestToken: Auth.requestToken), repsonse: RequestToken.self) { (response, error) in
            
            if let response = response {
                Auth.requestToken = response.requestToken
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    class func session(completionHandler: @escaping (Bool, Error?) -> Void) {
        
        taskPOSTRequest(url: Endpoints.createSessionId.url, body: PostSession(requestToken: Auth.requestToken), repsonse: SessionResponse.self) { (response, error) in
            
            if let response = response {
                Auth.sessionId = response.sessionId
                completionHandler(true, nil)
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    class func logout(completionHandler: @escaping (Bool, Error?) -> Void) {
        
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = LogoutRequest(session: Auth.sessionId)
        do {
            request.httpBody = try JSONEncoder().encode(body)
            completionHandler(true,nil)
            Auth.requestToken = ""
            Auth.sessionId = ""
        } catch {
            print(error.localizedDescription)
            completionHandler(false, error)
        }
    }
    
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        
        taskGETRequest(url: Endpoints.getWatchlist.url, response: MovieResults.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            }else {
                completion([], error)
            }
        }
    }
    
    class func getFavorite(completionHandler: @escaping ([Movie], Error?) -> Void) {
        taskGETRequest(url: Endpoints.getFavorites.url, response: MovieResults.self) { (response, error) in
            if let response = response {
                completionHandler(response.results, nil)
            } else {
                completionHandler([], error)
            }
        }
    }
    
    class func search(query: String, completionHandler: @escaping([Movie], Error?) -> Void) {
        taskGETRequest(url: Endpoints.search(query).url, response: MovieResults.self) { (response, error) in
            if let response = response {
                completionHandler(response.results, nil)
            } else {
                completionHandler([], error)
            }
        }
    }
    
class func taskGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void ){
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                completionHandler(nil, error)
            }
            return
        }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                    print(responseObject)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, repsonse: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        
        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            DispatchQueue.main.async {
                completionHandler(nil, error)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
                return
            }
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
}
