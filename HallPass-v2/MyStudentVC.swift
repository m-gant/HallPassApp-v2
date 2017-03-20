//
//  MyStudentVC.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/18/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class MyStudentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var studentList:[Student] = []
    var teacherRef: FIRDatabaseReference?

    @IBOutlet weak var myStudentsTBLV: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        myStudentsTBLV.dataSource = self
        myStudentsTBLV.delegate = self
        
        guard let nonOptionalTeacherRef = teacherRef else {
            let alert = UIAlertController(title: "Oops", message: "It appears we don't know who you are. Please sign back in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            return
        }
        self.teacherRef = nonOptionalTeacherRef
        
        teacherRef!.child("myStudents").observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                print(snapshot.value!)
                let studentInfo = snapshot.value! as! NSDictionary
                let studentFN = studentInfo["firstName"] as! String
                let studentLN = studentInfo["lastName"] as! String
                let studentWC = studentInfo["weekCount"] as! Int
                let studentMC = studentInfo["monthCount"] as! Int
                let studentTC = studentInfo["totalCount"] as! Int
                let studentHP = studentInfo["hasPass"] as! Bool
                let studentsAtts = studentInfo["attributes"] as! [String: Bool]
                var studentAttArr: [Bool] = [false, false, false, false]
                studentAttArr[0] = studentsAtts["femaleAtt"]!
                studentAttArr[1] = studentsAtts["Att1"]!
                studentAttArr[2] = studentsAtts["Att2"]!
                studentAttArr[3] = studentsAtts["Att3"]!
                let newStudent = Student(firstName: studentFN, lastName: studentLN, weekCount: studentWC, monthCount: studentMC, totalCount: studentTC, attributes: studentAttArr, hasPass: studentHP)
                self.studentList.append(newStudent)

            }
            self.myStudentsTBLV.reloadData()
            
        })
        
        

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewStudent" {
            let newStudentVC = segue.destination as! NewStudentVC
            newStudentVC.teacherRef = self.teacherRef
        } else {
            super.prepare(for: segue, sender: self)
        }
    }

   
    @IBAction func backToMenuBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell") as! StudentCell
        cell.student = studentList[indexPath.row]
        let studentName = "\(cell.student.firstName) \(cell.student.lastName)"
        cell.studentNameLabel.text = studentName
        let attributes = cell.student.attributes
        cell.attsLabel.text = ""
        if attributes[0] {
            cell.attsLabel.text = "👱‍♀️ \(cell.attsLabel.text!)"
        }
        if attributes[1] {
            cell.attsLabel.text = "1️⃣ \(cell.attsLabel.text!)"
        }
        if attributes[2] {
            cell.attsLabel.text = "2️⃣ \(cell.attsLabel.text!)"
        }
        if attributes[3] {
            cell.attsLabel.text = "3️⃣ \(cell.attsLabel.text!)"
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func createViewTag(color: UIColor) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        view.layer.backgroundColor = color.cgColor
        view.layer.cornerRadius = 2
        return view
    }
    

}


class Student {
    
    var hasHallPass: Bool
    var attributes: [Bool]
    var firstName: String
    var lastName: String
    var weekCount: Int
    var monthCount: Int
    var totalCount: Int
    
    init(firstName FN: String, lastName LN: String, weekCount WC: Int, monthCount MC: Int, totalCount TC: Int, attributes Atts: [Bool], hasPass HP: Bool) {
        firstName = FN; lastName = LN; weekCount = WC; monthCount = MC; totalCount = TC; attributes = Atts; hasHallPass = HP
        
        
    }
    
}
