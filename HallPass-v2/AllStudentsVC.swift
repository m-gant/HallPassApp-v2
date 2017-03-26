//
//  AllStudentsVC.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/25/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class AllStudentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var studentList: [Student] = []
    var teacherRef: FIRDatabaseReference!
    var allStudentsRef: FIRDatabaseReference!
    var currentStudent: Student?
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var allStudentsTBLV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        guard let nonOptTeacherRef = teacherRef else {
            let alert = UIAlertController(title: "Oops", message: "It appears we don't know who you are. ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.teacherRef = nonOptTeacherRef
        self.allStudentsRef = teacherRef.parent!.parent!.child("allStudents")
        allStudentsRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                let studentInfo = snapshot.value! as! NSDictionary
                let studentFN = studentInfo["firstName"] as! String
                let studentLN = studentInfo["lastName"] as! String
                let studentWC = studentInfo["weekCount"] as! Int
                let studentMC = studentInfo["monthCount"] as! Int
                let studentTC = studentInfo["totalCount"] as! Int
                let studentHP = studentInfo["hasPass"] as! Bool
                let studentDM = studentInfo["demerits"] as! Int
                let studentsAtts = studentInfo["attributes"] as! [String: Bool]
                var studentAttArr: [Bool] = [false, false, false, false]
                studentAttArr[0] = studentsAtts["femaleAtt"]!
                studentAttArr[1] = studentsAtts["Att1"]!
                studentAttArr[2] = studentsAtts["Att2"]!
                studentAttArr[3] = studentsAtts["Att3"]!
                let newStudent = Student(firstName: studentFN, lastName: studentLN, weekCount: studentWC, monthCount: studentMC, totalCount: studentTC, attributes: studentAttArr, hasPass: studentHP, uid: snapshot.key, demerits: studentDM)
                self.studentList.append(newStudent)

            } else {
                print("allStudents is null")
            }
            self.allStudentsTBLV.reloadData()
        })
        
        allStudentsRef.parent!.child("schoolName").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.navBar.title = "\(snapshot.value as! String) Students"
            } else {
                print("schoolName not there bro")
            }
        })
        
        
        
        
        
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStudentInfoAS" {
            let studentInfoAS = segue.destination as! StudentInfoASVC
            studentInfoAS.student = currentStudent!
            studentInfoAS.allStudentsRef = allStudentsRef
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell") as! StudentCell
        let student = studentList[indexPath.row]
        cell.studentNameLabel.text = "\(student.firstName) \(student.lastName)"
        cell.attsLabel.text = ""
        let attributes = student.attributes
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

        
        
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentStudent = studentList[indexPath.row]
        performSegue(withIdentifier: "toStudentInfoAS", sender: self)
    }

    

}
