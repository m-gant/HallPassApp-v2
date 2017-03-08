//
//  ViewController.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/7/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import QuartzCore
import Firebase

class Login_RegistrationViewController: UIViewController, UITextFieldDelegate {
    
    var loginSelected: Bool = true
    var registrationSelected = false
    let rootRef = FIRDatabase.database().reference(fromURL: "https://hallpass-v2.firebaseio.com/")

    @IBOutlet weak var Login_RegistrationBtn: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var registrationFormBtn: UIButton!
    @IBOutlet weak var loginFormBtn: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.isSecureTextEntry = true
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            //TODO: Logout
        }
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    @IBAction func loginFormBtnPressed(_ sender: Any) {
        
        if (!loginSelected) {
            loginSelected = true
            registrationSelected = false
            nameTextField.placeholder = "Email"
            emailTextField.isSecureTextEntry = true
            emailTextField.placeholder = "Password"
            loginFormBtn.backgroundColor = UIColor.white
            loginFormBtn.alpha = 1
            registrationFormBtn.alpha = 0.75
            Login_RegistrationBtn.setTitle("Login", for: .normal)
            
            
            UIView.animate(withDuration: 1, animations: {
                self.containerViewHeight.constant = 90
                self.view.layoutIfNeeded()
            })

            
            
        }
    }

    
    @IBAction func registrationFormBtnPressed(_ sender: Any) {
        if (!registrationSelected) {
            registrationSelected = true
            loginSelected = false
            nameTextField.placeholder = "Name"
            emailTextField.placeholder = "Email"
            emailTextField.isSecureTextEntry = false
            passwordTextField.isSecureTextEntry = true
            confirmPasswordTextField.isSecureTextEntry = true
            registrationFormBtn.backgroundColor = UIColor.white
            registrationFormBtn.alpha = 1
            loginFormBtn.alpha = 0.75
            
            Login_RegistrationBtn.setTitle("Register", for: .normal)
            UIView.animate(withDuration: 1, animations: {
                self.containerViewHeight.constant = 180
                self.view.layoutIfNeeded()
            })
            
        }
    }
    
    @IBAction func Login_RegistrationBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Invalid Entry", message: "something is wrong", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        if registrationSelected {
            if(nameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != "") {
                
                
                if (confirmPasswordTextField.text == passwordTextField.text) {
                    
                    
                    FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user: FIRUser?, error) in
                        
                        
                        if error != nil {
                            alert.message = error!.localizedDescription
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        
                        guard let userID = user?.uid else {
                            return
                        }
                        
                        let teacherRef = self.rootRef.child("teachers").child(userID)
                        let values = ["name": self.nameTextField.text!, "email": self.emailTextField.text!, "settings": "default", "myStudents":"none"]
                        teacherRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                            
                            if err != nil {
                                alert.title = "Problem with Database Entry"
                                alert.message = err!.localizedDescription
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                            let defaultSettings = ["femaleAttTime": 5, "Att2Time": 5, "Att3Time": 5, "Att4Time": 5]
                            teacherRef.child("settings").updateChildValues(defaultSettings, withCompletionBlock: { (error, ref) in
                                
                                if (error != nil) {
                                    alert.title = "Problem with Database Entry"
                                    alert.message = error!.localizedDescription
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                            })
                            self.performSegue(withIdentifier: "toNext", sender: self)
                        })
                        
                    })
                    
                } else {
                    
                    alert.message = "Ensure that Password and Confirm Password fields are the same."
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else {
                
                alert.message = "Please fill in all fields."
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            if (nameTextField.text != "" && emailTextField.text != "") {
                FIRAuth.auth()?.signIn(withEmail: self.nameTextField.text!, password: self.emailTextField.text!, completion: { (user, err) in
                    
                    if err != nil {
                        alert.message = err!.localizedDescription
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    self.performSegue(withIdentifier: "toNext", sender: self)
                    
                })
                
            } else {
                alert.title = "Invalid Entry"
                alert.message = "Please fill in all fields."
                present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    

}
