//
//  SettingsViewController.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/10/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var teacherRef: FIRDatabaseReference = FIRDatabaseReference()
    var teacherDataSource: TeacherReferenceDataSource?
    let minutes: [Int] = [Int](1...60)
    var minutesString : [String]?
    

    @IBOutlet weak var MinutePickerFemale: UIPickerView!
    @IBOutlet weak var MinutePickerAtt1: UIPickerView!
    @IBOutlet weak var MinutePickerAtt2: UIPickerView!
    @IBOutlet weak var MinutePickerAtt3: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if teacherDataSource != nil {
            
            
            guard let nonOptTeacherRef =  teacherDataSource!.getTeacherReference() else {
                let alert = UIAlertController(title: "Oops", message: "We don't know who you are! Please log back in.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            teacherRef = nonOptTeacherRef
            
        } else {
            let alert = UIAlertController(title: "Oops", message: "It appears we don't know who you are. Please log back in. ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                do {
                    try FIRAuth.auth()?.signOut()
                } catch {
                    alert.message = error.localizedDescription
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        
        minutesString = minutes.map {
            String($0)
        }
        MinutePickerFemale.tag  = 0
        MinutePickerAtt1.tag = 1
        MinutePickerAtt2.tag = 2
        MinutePickerAtt3.tag = 3
        
        teacherRef.child("settings").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let settingsData = snapshot.value as! [String: Int]
                self.MinutePickerFemale.selectRow(settingsData["femaleAttTime"]! - 1, inComponent: 0, animated: false)
                self.MinutePickerAtt1.selectRow(settingsData["Att1Time"]! - 1, inComponent: 0, animated: false)
                self.MinutePickerAtt2.selectRow(settingsData["Att2Time"]! - 1, inComponent: 0, animated: false)
                self.MinutePickerAtt3.selectRow(settingsData["Att3Time"]! - 1, inComponent: 0, animated: false)
                
            }
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return minutes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        print(teacherRef)
        
        let settingsRef = teacherRef.child("settings")
        
        
        switch pickerView.tag {
        case 0:
            settingsRef.child("femaleAttTime").setValue(minutes[row])
        case 1:
            settingsRef.updateChildValues(["Att1Time":minutes[row]])
        case 2:
            settingsRef.updateChildValues(["Att2Time" : minutes[row]])
        case 3:
            settingsRef.updateChildValues(["Att3Time" : minutes[row]])
        default: break
            //do nothing
            
        }
        
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return minutesString![row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = minutesString![row]
        let theFinalTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName: UIColor.white])
        return theFinalTitle
    }
    
    @IBAction func backToMenuBtnPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    

    
   
}
