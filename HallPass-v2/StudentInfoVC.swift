//
//  StudentInfoVC.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/21/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class StudentInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var studentNameLabel: UILabel!
    var student: Student!
    var teacherRef: FIRDatabaseReference!
    var studentLogs: [StudentLog] = []

    @IBOutlet weak var weekPassesLabel: UILabel!
    @IBOutlet weak var monthPassesLabel: UILabel!
    @IBOutlet weak var totalPassesLabel: UILabel!
    @IBOutlet weak var demeritsLabel: UILabel!
    @IBOutlet weak var studentLogsList: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        guard let nonOptStudent = student else {
            let alert = UIAlertController(title: "Oops", message: "There appears to be an error with the  student you selected. Please choose again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        student = nonOptStudent
        weekPassesLabel.text = "Passes this week: \(student.weekCount)"
        monthPassesLabel.text = "Passes this month: \(student.monthCount)"
        totalPassesLabel.text = "Total passes given: \(student.totalCount)"
        demeritsLabel.text = "Total demerits given: \(student.demerits)"
        
        guard let nonOptTeacherRef = teacherRef else {
            let alert = UIAlertController(title: "Oops", message: "There appears to be an error with the  student you selected. Please choose again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        teacherRef = nonOptTeacherRef
        let studentRef = teacherRef.child("myStudents").child(student.UID)
        studentRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("logs") {
                studentRef.child("logs").observe(.childAdded, with: { (snap) in
                    let log  = snap.value as! [String: String]
                    let date = log["date"]
                    let time = log["time"]
                    let description = log["description"]
                    let this_log = StudentLog(date: date!, time: time!, description: description!)
                    self.studentLogs.append(this_log)
                })
            }
        })
        studentNameLabel.text = " \(student.lastName), \(student.firstName)"
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passLog") as! PassLog
        cell.dateLabel.text = studentLogs[indexPath.row].date
        cell.timeLabel.text = studentLogs[indexPath.row].time
        cell.descriptionLabel.text = studentLogs[indexPath.row].description
        cell.backgroundColor = .clear
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class StudentLog {
    var date: String
    var time: String
    var description: String
    
    init(date D: String, time T: String, description DSC: String) {
        date = D; time = T;  description = DSC
    }
    
}

