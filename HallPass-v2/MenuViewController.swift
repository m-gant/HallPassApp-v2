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
    
    @IBOutlet weak var HelloLabel: UILabel!

    @IBOutlet weak var HelloConstraint: NSLayoutConstraint!
    @IBOutlet weak var TeacherNameConstraint: NSLayoutConstraint!
    @IBOutlet weak var teacherNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
            teacherRef.child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.teacherNameLabel.text = snapshot.value as! String
                }
            })
            
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
            print("prepare for segue occurs")
        } else if segue.identifier == "toMyStudents" {
            let myStudentsVC = segue.destination as! MyStudentVC
            myStudentsVC.teacherRef = self.teacherRef
        } else {
            super.prepare(for: segue, sender: self)
        }
    }
    
    
    func getTeacherReference() -> FIRDatabaseReference? {
        return teacherRef
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        HelloLabel.frame.origin.x -= self.view.bounds.width
        teacherNameLabel.frame.origin.x -= self.view.bounds.width
        
        UIView.animate(withDuration: 1, animations: { 
            self.HelloLabel.frame.origin.x += self.view.bounds.width
        }, completion: nil)
        UIView.animate(withDuration: 1, delay: 0.25, options: .curveLinear, animations: { 
            self.teacherNameLabel.frame.origin.x += self.view.bounds.width
        }, completion: nil)

    }

    @IBAction func logoutBtnPressed(_ sender: Any) {
        
        do {
           try FIRAuth.auth()?.signOut()
            //self.performSegue(withIdentifier: "backToLogin", sender: self)
            for viewController in self.navigationController!.viewControllers {
                if let vc = viewController as? WelcomeViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
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


