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

class Login_RegistrationViewController: UIViewController, UITextFieldDelegate, TeacherReferenceDataSource {
    
    var loginSelected: Bool = true
    var registrationSelected = false
    var schoolRef: FIRDatabaseReference = FIRDatabaseReference()
    var welcomeVC: SchoolReferenceDataSource?
    let rootRef = FIRDatabase.database().reference()
    var teacherRef: FIRDatabaseReference? = nil
    var originalEffect: UIVisualEffect!

    @IBOutlet weak var login_registrationContainer: UIView!
    @IBOutlet weak var Blur: UIVisualEffectView!
    @IBOutlet weak var Login_RegistrationBtn: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var registrationFormBtn: UIButton!
    @IBOutlet weak var loginFormBtn: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var distanceFromLogRegFormBtns: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        originalEffect = Blur.effect
        Blur.effect = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        

        emailTextField.isSecureTextEntry = true
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        if welcomeVC != nil {
            guard let nonOptSchoolRef = welcomeVC!.getSchoolReference() else {
                let alert = UIAlertController(title: "Oops", message: "We dont know what school you are from! Please re-enter valid school identifier.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.schoolRef = nonOptSchoolRef

        } else {
            let alert = UIAlertController(title: "Oops", message: "You are not current connected to any school", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                self.dismiss(animated: true, completion: nil)
            }))
        }
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            self.dismiss(animated: true, completion: nil)
        }
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toMenu") {
            let menuVC = segue.destination as! MenuViewController
            menuVC.teacherDataSource = self
        }
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
            //Registration
            
            
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
                        
                        
                        self.teacherRef = self.schoolRef.child("teachers").child(userID)
                        let values = ["name": self.nameTextField.text!, "email": self.emailTextField.text!, "settings": "default", "myStudents":"none"]
                        self.teacherRef!.updateChildValues(values, withCompletionBlock: { (err, ref) in
                            
                            if err != nil {
                                alert.title = "Problem with Database Entry"
                                alert.message = err!.localizedDescription
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                            let defaultSettings = ["femaleAttTime": 5, "Att2Time": 5, "Att3Time": 5, "Att4Time": 5]
                            self.teacherRef!.child("settings").updateChildValues(defaultSettings, withCompletionBlock: { (error, ref) in
                                
                                if (error != nil) {
                                    alert.title = "Problem with Database Entry"
                                    alert.message = error!.localizedDescription
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                            })
                            self.performSegue(withIdentifier: "toMenu", sender: self)
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
            //Login
            
            
            if (nameTextField.text != "" && emailTextField.text != "") {
                FIRAuth.auth()?.signIn(withEmail: self.nameTextField.text!, password: self.emailTextField.text!, completion: { (user, err) in
                    
                    if err != nil {
                        alert.message = err!.localizedDescription
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    guard let nonOptUser = user else {
                        alert.title = "Database Error"
                        alert.message = "The user you are trying to sign-in is not in the system."
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    let userId = nonOptUser.uid
                    
                    
                    self.schoolRef.child("teachers").observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.hasChild(userId) {
                            self.teacherRef = self.schoolRef.child("teachers").child(userId)
                            self.performSegue(withIdentifier: "toMenu", sender: self)

                        } else {
                            alert.title = "Invalid Login"
                            alert.message = "The login information inputted does not match the school identifier in the system. Please log in with the correct School Identifier."
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                    
                    
                })
                
            } else {
                alert.title = "Invalid Entry"
                alert.message = "Please fill in all fields."
                present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    func getTeacherReference() -> FIRDatabaseReference? {
        return teacherRef
    }
    
    @IBAction func backToWelcomeBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.bringSubview(toFront: Blur)
        self.view.bringSubview(toFront: login_registrationContainer)
        
        UIView.animate(withDuration: 1, animations: { 
            self.distanceFromLogRegFormBtns.constant = -10
            self.Blur.effect = self.originalEffect
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func keyboardWillHide (notification: NSNotification) {
        UIView.animate(withDuration: 1, animations: {
            self.distanceFromLogRegFormBtns.constant = 20
            self.view.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 0.25, animations: { 
                self.Blur.effect = nil
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.view.sendSubview(toBack: self.Blur)
            })
        }
    }

}

protocol SchoolReferenceDataSource {
    func getSchoolReference() -> FIRDatabaseReference?
}


