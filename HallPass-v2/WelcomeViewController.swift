//
//  WelcomeViewController.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/8/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController, SchoolReferenceDataSource, UITextFieldDelegate {
    
    let rootRef = FIRDatabase.database().reference()

    @IBOutlet weak var schoolLoginView: UIView!
    
    @IBOutlet weak var HallPassLabel: UILabel!
    @IBOutlet weak var Blur: UIVisualEffectView!
    
    @IBOutlet weak var HallPassLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewFormHeight: NSLayoutConstraint!
    
    @IBOutlet weak var distanceFromSignInFormBtn: NSLayoutConstraint!
    
    @IBOutlet weak var schoolNameTextField: UITextField!
    
    @IBOutlet weak var schoolIdentifierTextField: UITextField!
    
    @IBOutlet weak var Register_SignInBtn: UIButton!
    
    var originalEffect : UIVisualEffect!
    
    var registerNewSchool: Bool = true
    
    var schoolRef: FIRDatabaseReference? = nil
    let food = ["hello" : "there"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        originalEffect = Blur.effect
        Blur.effect = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWasLaunched(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        schoolNameTextField.delegate = self
        schoolIdentifierTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear(true)
        self.HallPassLabel.frame.origin.x -= self.view.bounds.width
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            
            self.HallPassLabel.frame.origin.x =  0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTeacherLogin" {
            let destinationController = segue.destination as! Login_RegistrationViewController
            destinationController.welcomeVC = self
        } else {
            super.prepare(for: segue, sender: self)
        }
    }
    
    func getSchoolReference() -> FIRDatabaseReference? {
        return schoolRef
    }
    

    @IBAction func registerNewSchoolFormBtn(_ sender: Any) {
        if !registerNewSchool {
            registerNewSchool = true
            schoolNameTextField.placeholder = "School Name"
            schoolIdentifierTextField.placeholder = "School Identifier"
            Register_SignInBtn.setTitle("Register", for: .normal)
            UIView.animate(withDuration: 1, animations: { 
                self.containerViewFormHeight.constant = 90
                self.view.layoutIfNeeded()
            })
            
        }
        
        
        
    }
    
    @IBAction func signInFormBtn(_ sender: Any) {
        if (registerNewSchool) {
            registerNewSchool = false
            schoolNameTextField.placeholder = "School Identifier"
            Register_SignInBtn.setTitle("Sign In", for: .normal)
            UIView.animate(withDuration: 1, animations: { 
                self.containerViewFormHeight.constant = 45
                self.view.layoutIfNeeded()
            })
        }
        
        
    }
    
    @IBAction func register_signInBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Invalid Entry", message: "Something", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        if registerNewSchool {
            if (schoolNameTextField.text != "" && schoolIdentifierTextField.text != "") {
                let schoolName = schoolNameTextField.text!
                let schoolIdentifier = schoolIdentifierTextField.text!
                let schoolRef = rootRef.child("Schools").child(schoolIdentifier)
                self.schoolRef = schoolRef
                schoolRef.updateChildValues(["schoolName": schoolName, "allStudents": "none"], withCompletionBlock: { (error, ref) in
                    
                    if error != nil {
                        alert.title = "Database Entry Error"
                        alert.message = error!.localizedDescription
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                })
                self.performSegue(withIdentifier: "toTeacherLogin", sender: self)
                
            } else {
                alert.message = "Please fill in all fields."
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            if (schoolNameTextField.text != "") {
                let schoolIdentifier = schoolNameTextField.text!
                let schoolsRef = rootRef.child("Schools")
                schoolsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChild(schoolIdentifier) {
                        self.schoolRef = self.rootRef.child("Schools").child(schoolIdentifier)
                        self.performSegue(withIdentifier: "toTeacherLogin", sender: self)
                    } else {
                        alert.title = "Oops"
                        alert.message = "The School identifier you have entered is not in the system"
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                
                
            } else {
                alert.message = "Please fill in all fields"
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.5, animations: {
            self.distanceFromSignInFormBtn.constant = 20
            self.view.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 0.25, animations: {
                self.Blur.effect = nil
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.view.sendSubview(toBack: self.Blur)
            })
        }
        
        return false
    }
    
    func animateUp() {
        UIView.animate(withDuration: 3) {
            self.distanceFromSignInFormBtn.constant = -70
            self.Blur.effect = self.originalEffect
            //self.view.layoutSubviews()
            self.view.layoutIfNeeded()
        }

    }
    
    func keyBoardWasLaunched(notification: NSNotification) {
        self.view.bringSubview(toFront: Blur)
        //self.view.bringSubview(toFront: Register_SignInBtn)
        self.view.bringSubview(toFront: self.schoolLoginView)
        animateUp()
    }
    
}
