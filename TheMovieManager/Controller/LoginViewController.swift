//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        TMDBClient.getRequestToken(completionHandler: handleRequestTokenResponse(success:error:))
        
    }
    
    @IBAction func loginViaWebsiteTapped() {
        TMDBClient.getRequestToken { (success, error) in
            if success {
                DispatchQueue.main.async {
                UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
            }
        }
    }
        
}
    
    func handleRequestTokenResponse(success: Bool, error: Error?) {
        if success {
        DispatchQueue.main.async {
            TMDBClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completionHandler: self.handleLoginRequestResponse(success:error:))
            }
        }
    }
    
    func handleLoginRequestResponse(success: Bool, error: Error?) {
        print(TMDBClient.Auth.requestToken)
        if success {
            TMDBClient.session(completionHandler: handleSessionResponse(success:error:))
        }
    }
    
    func handleSessionResponse(success: Bool, error: Error?) {
        if success {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            }
        }
    }
}
