//
//  MenuViewController.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/9/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase
import QuartzCore

class MenuViewController: UIViewController, TeacherReferenceDataSource {
    
    var schoolRef: FIRDatabaseReference = FIRDatabaseReference()
    var teacherDataSource: TeacherReferenceDataSource?
    var teacherRef: FIRDatabaseReference = FIRDatabaseReference()
    

    @IBOutlet weak var HelloConstraint: NSLayoutConstraint!
    @IBOutlet weak var TeacherNameConstraint: NSLayoutConstraint!
    @IBOutlet weak var teacherNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HelloConstraint.constant -= self.view.bounds.width
        TeacherNameConstraint.constant -= self.view.bounds.width
        if teacherDataSource != nil {
            guard let nonOptTeacherRef = teacherDataSource!.getTeacherReference() else {
                let alert = UIAlertController(title: "Oops", message: "We don't know who you are! Please log back in.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            teacherRef = nonOptTeacherRef
             schoolRef = teacherRef.parent!
            
        } else {
            let alert = UIAlertController(title: "Oops", message: "We don't know who you are! Please log back in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:  { action in
                self.dismiss(animated: true, completion: nil)
            }))
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSettings" {
            let settingsVC = segue.destination as! SettingsViewController
            settingsVC.teacherDataSource = self
        } else {
            super.prepare(for: segue, sender: self)
        }
    }
    
    
    func getTeacherReference() -> FIRDatabaseReference? {
        return teacherRef
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        teacherRef.child("name").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let value = snapshot.value as! String
                self.teacherNameLabel.text = value
                print(snapshot.value)
            } else {
                print("something happened")
            }
        })

        
        UIView.animate(withDuration: 1) {
            self.HelloConstraint.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 1, delay: 0.25, options: .curveEaseOut, animations: {
            self.TeacherNameConstraint.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
        

    }

    @IBAction func logoutBtnPressed(_ sender: Any) {
        
        do {
           try FIRAuth.auth()?.signOut()
            self.performSegue(withIdentifier: "backToLogin", sender: self)
        } catch {
            let alert = UIAlertController(title: "Sorry", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:  { action in
                self.performSegue(withIdentifier: "backToLogin", sender: self)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
   

}



extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}


