//
//  WelcomeViewController.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/8/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController, SchoolReferenceDataSource {
    
    let rootRef = FIRDatabase.database().reference()

    
    
    @IBOutlet weak var HallPassLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewFormHeight: NSLayoutConstraint!
    
    @IBOutlet weak var schoolNameTextField: UITextField!
    
    @IBOutlet weak var schoolIdentifierTextField: UITextField!
    
    @IBOutlet weak var Register_SignInBtn: UIButton!
    
    var registerNewSchool: Bool = true
    
    var schoolRef: FIRDatabaseReference? = nil
    let food = ["hello" : "there"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HallPassLabelConstraint.constant -= view.bounds.width
        self.rootRef.child("Schools")
        //for branch
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.HallPassLabelConstraint.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTeacherLogin" {
            let destinationController = segue.destination as! Login_RegistrationViewController
            destinationController.dataSource = self
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
    
}
