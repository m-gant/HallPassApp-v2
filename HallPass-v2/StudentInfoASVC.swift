//
//  StudentInfoASVC.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/26/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase

class StudentInfoASVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var student: Student!
    var allStudentsRef: FIRDatabaseReference!
    var studentLogs: [StudentLog] = []

    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var monthCountLabel: UILabel!
    @IBOutlet weak var weekCountLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var demeritsLabel: UILabel!
    @IBOutlet weak var studentLogsTBLV: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    var timer: Timer!
    var timerOn: Bool = false
    var endTime:Int = 0
    var curTime:Int = 0
    var counter = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let nonOptStudent = student else {
            let alert = UIAlertController(title: "Oops", message: "It appears we don't have the student you selected. Please choose again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        student = nonOptStudent
        
        guard let nonOptASR = allStudentsRef else {
            let alert = UIAlertController(title: "Oops", message: "It appears we don't know what school you are from. Please sign back in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        allStudentsRef = nonOptASR
        
        studentNameLabel.text = "\(student.lastName), \(student.firstName)"
        weekCountLabel.text = "Passes this week: \(student.weekCount)"
        monthCountLabel.text = "Passes this month: \(student.monthCount)"
        totalCountLabel.text = "Total passes given: \(student.totalCount)"
        demeritsLabel.text = "Total demerits given: \(student.demerits)"
        
        allStudentsRef.child(student.UID).child("logs").observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                let log = snapshot.value as! [String: Any]
                let description = log["description"] as! String
                let date = log["date"] as! String
                let time = log["time"] as! String
                let startTime = log["startTime"] as! Int
                let newLog = StudentLog(date: date, time: time, description: description, startTime: startTime)
                self.studentLogs.append(newLog)
            } else {
                print("all students is null")
            }
            self.studentLogs.sort(by: { (student1, student2) -> Bool in
                return student1.startTime > student2.startTime
            })
            self.studentLogsTBLV.reloadData()
        })
        
        allStudentsRef.child(student.UID).child("currentPass").child("endTime").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.endTime = snapshot.value as! Int
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(StudentInfoASVC.updateTimer), userInfo: nil, repeats: true)
                self.curTime = Int(Date().timeIntervalSince1970)
                let checker = self.endTime - self.curTime
                if checker < 0 {
                    self.timerOn = false
                    self.timerLabel.text = "00:00"
                    self.counter = 0
                } else {
                    self.timerOn = true
                    
                }

            } else {
                print("no endTime")
            }
        })
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "passLog") as! PassLog
        let currentLog = studentLogs[indexPath.row]
        cell.dateLabel.text = currentLog.date
        cell.timeLabel.text = currentLog.time
        cell.descriptionLabel.text = currentLog.description
        cell.backgroundColor = .clear
        return cell
    }
    
    func updateTimer() {
        if timerOn {
            counter += 1
            let totalTime = endTime - (curTime + counter)
            var minutes: Int
            var num_secs: Int
            if (totalTime > 0) {
                minutes = totalTime / 60
                num_secs = totalTime % 60
            } else {
                minutes = 0
                num_secs = 0
                timerOn = false
            }
            timerLabel.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", num_secs)
            

        }
    }

    
    

}
