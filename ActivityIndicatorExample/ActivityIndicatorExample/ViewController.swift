//
//  ViewController.swift
//  ActivityIndicatorExample
//
//  Created by Sarp Bozkurt on 23.11.2023.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
    }
    @IBAction func loginPressed(_ sender: UIButton) {
        if usernameTextField.text == "sarp", passwordTextField.isHidden {
            passwordTextField.isHidden = false
        } else {
            if usernameTextField.text != "sarp" {
                errorLabel.isHidden = false
                errorLabel.text = "username should be u"
            } else if !(passwordTextField.isHidden), passwordTextField.text == "1234" {
                activityIndicator.startAnimating()
                errorLabel.isHidden = true
            } else {
                errorLabel.isHidden = false
                errorLabel.text = "your pass is wrong"
            }
        }
    }
}

