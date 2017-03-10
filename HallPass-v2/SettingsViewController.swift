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
    
    var teacherRef: FIRDatabaseReference?
    var teacherDataSource: TeacherReferenceDataSource?
    let minutes: [Int] = [Int](1...60)
    var minutesString : [String]?
    

    @IBOutlet weak var MinutePickerFemale: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if teacherDataSource != nil
        {
            teacherRef = teacherDataSource?.getTeacherReference()
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
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return minutes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let settingsRef = teacherRef!.child("settings")
        
        
        switch pickerView.tag {
        case 0:
            settingsRef.updateChildValues(["femaleAttTime": minutesString![row]])
        case 1:
            settingsRef.updateChildValues(["Att1Time":minutesString![row]])
        case 2:
            settingsRef.updateChildValues(["Att2Time" : minutesString![row]])
        case 3:
            settingsRef.updateChildValues(["Att3Time" : minutesString![row]])
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
    
    

    
   
}
