//
//  NewStudentVC.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/19/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class NewStudentVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var femaleAttBtn: UIButton!
    @IBOutlet weak var Att1Btn: UIButton!
    @IBOutlet weak var Att2Btn: UIButton!
    @IBOutlet weak var Att3Btn: UIButton!
    var attributes:[Bool] = [false, false, false, false]
    var teacherRef: FIRDatabaseReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTF.delegate = self
        lastNameTF.delegate = self

        guard let nonOptTeacherRef = self.teacherRef else {
            let alert = UIAlertController(title: "Oops", message: "It appears we don't know you are. Please sign back in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            self.present(alert, animated: true, completion: nil)
            }))
            return 
        }
        self.teacherRef = nonOptTeacherRef
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    
    @IBAction func femaleAttBtnPressed(_ sender: Any) {
        if !attributes[0] {
            femaleAttBtn.setTitleColor(UIColor.white, for: .normal)
            femaleAttBtn.backgroundColor = UIColor.blue
            attributes[0] = true
        } else {
            femaleAttBtn.setTitleColor(UIColor.blue, for: .normal)
            femaleAttBtn.backgroundColor = UIColor.clear
            attributes[0] = false
        }
    }
    

    @IBAction func Att1BtnPressed(_ sender: Any) {
        if !attributes[1] {
            Att1Btn.setTitleColor(UIColor.white, for: .normal)
            Att1Btn.backgroundColor = UIColor.blue
            attributes[1] = true
        } else {
            Att1Btn.setTitleColor(UIColor.blue, for: .normal)
            Att1Btn.backgroundColor = UIColor.clear
            attributes[1] = false
        }
        
    }
    
    
    @IBAction func Att2BtnPressed(_ sender: Any) {
        if !attributes[2] {
            Att2Btn.setTitleColor(UIColor.white, for: .normal)
            Att2Btn.backgroundColor = UIColor.blue
            attributes[2] = true
        } else {
            Att2Btn.setTitleColor(UIColor.blue, for: .normal)
            Att2Btn.backgroundColor = UIColor.clear
            attributes[2] = false
        }

    }
    
    
    @IBAction func Att3BtnPressed(_ sender: Any) {
        if !attributes[3] {
            Att3Btn.setTitleColor(UIColor.white, for: .normal)
            Att3Btn.backgroundColor = UIColor.blue
            attributes[3] = true
        } else {
            Att3Btn.setTitleColor(UIColor.blue, for: .normal)
            Att3Btn.backgroundColor = UIColor.clear
            attributes[3] = false
        }
    }
    
    @IBAction func addStudentBtnPressed(_ sender: Any) {
        
        if (firstNameTF.text != "" && lastNameTF.text != "") {
            let studentRef = teacherRef!.child("myStudents").childByAutoId()
            let attHash = ["femaleAtt": attributes[0], "Att1": attributes[1], "Att2": attributes[2], "Att3": attributes[3]]
            studentRef.updateChildValues(["firstName": firstNameTF.text!, "lastName": lastNameTF.text!, "weekCount": 0, "monthCount": 0, "totalCount": 0, "demerits": 0, "attributes" : attHash, "hasPass": false])
            self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Invalid Entry", message: "Please fill in all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
