//
//  UIViewController+Extension.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

extension UIViewController {
    
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        TMDBClient.logout(completionHandler: handleLogoutResponse(success:error:))
    }
    
    
    func handleLogoutResponse(success: Bool, error: Error?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            let VC = LoginViewController()
            if case VC.emailTextField = VC.emailTextField{
            VC.emailTextField.text = ""
            }
            if case VC.passwordTextField = VC.passwordTextField {
                VC.passwordTextField.text = ""
            }
        }
    }
}
