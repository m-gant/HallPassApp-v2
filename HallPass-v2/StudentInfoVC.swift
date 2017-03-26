//
//  StudentInfoVC.swift
//  HallPass-v2
//
//  Created by Mitchell Gant on 3/21/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class StudentInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var studentNameLabel: UILabel!
    var student: Student!
    var teacherRef : FIRDatabaseReference!
    var studentLogs: [StudentLog] = []
    var counter: Int = 0
    var defaultTime: Int = 0
    var endTime: Int = 0
    var curTime: Int = 0
    var timer : Timer!
    var timerOn: Bool = false

    @IBOutlet weak var weekPassesLabel: UILabel!
    @IBOutlet weak var monthPassesLabel: UILabel!
    @IBOutlet weak var totalPassesLabel: UILabel!
    @IBOutlet weak var demeritsLabel: UILabel!
    @IBOutlet weak var studentLogsList: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var giveHallPassBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var upTickBtn: UIButton!
    @IBOutlet weak var downTickBtn: UIButton!
    
    
    @IBOutlet weak var logsTBLV: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(StudentInfoVC.update_Timer), userInfo: nil, repeats: true)

        guard let nonOptStudent = student else {
            let alert = UIAlertController(title: "Oops", message: "There appears to be an error with the  student you selected. Please choose again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        student = nonOptStudent
        
        guard let nonOptTeacherRef = teacherRef else {
            let alert = UIAlertController(title: "Oops", message: "There appears to be an error with the  student you selected. Please choose again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        teacherRef = nonOptTeacherRef
        
        studentNameLabel.text = "\(student.lastName), \(student.firstName)"
        
        
        updateLogsTBLV()
        
        updateStudentInfoLabels()
        
        
        if !student.hasHallPass {
            setDefaultTime(student: student)
            //print("\(defaultTime) default time in vdl")
            
        } else {
            giveHallPassBtn.setTitle("Close\nHall Pass", for: .normal)
            let studentRef = teacherRef!.child("myStudents").child(student.UID)
            studentRef.child("currentPass").child("endTime").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.endTime = snapshot.value as! Int
                    self.curTime = Int(Date().timeIntervalSince1970)
                    let checker = self.endTime - self.curTime
                    if checker < 0 {
                        self.giveHallPassPressed(self)
                    } else {
                        print(self.counter)
                        self.timerOn = true
                    }

                } else {
                    print("snapshot of endTime is not here ")
                }
            })
            
            
            
        }
        

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

    
    func setDefaultTime(student: Student) {
        var times: [Int] = []
        var returnTime:Int = 0
        print(teacherRef)
        
        teacherRef!.child("settings").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let teacherSettings = snapshot.value as! [String: Int]
                times.append(teacherSettings["femaleAttTime"]!)
                times.append(teacherSettings["Att1Time"]!)
                times.append(teacherSettings["Att2Time"]!)
                times.append(teacherSettings["Att3Time"]!)
                for index in 0...3 {
                    if (self.student.attributes[index]) {
                        if (times[index] > returnTime) {
                            returnTime = times[index]
                        }
                        print(returnTime)
                    }
                }
                print(returnTime)
                self.defaultTime = (returnTime * 60)
                self.updateTimer(seconds: self.defaultTime)
                
            } else {
                print("its null bro (the teacher settings)")
                
            }
            
            
            
        })
        //print(times)
        
        
    }
    
    func updateTimer(seconds: Int) {
        //print("\(seconds) seconds in updateTimer")
        let minutes: Int = seconds / 60
        let num_secs: Int = seconds % 60
        //print(String(format: "%02d", minutes) + "minutes in updateTimer")
        //print(String(format: "%02d", num_secs) + "seconds in updateTimer")
        //print(String(format: "%02d", minutes) + ":" + String(format: "%02d", num_secs) + " uk")
        timerLabel.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", num_secs)
    }
    
    @IBAction func giveHallPassPressed(_ sender: Any) {
        //print(giveHallPassBtn.titleLabel!.text!)
        if (giveHallPassBtn.titleLabel?.text == "Give Hall Pass") {
            let alert = UIAlertController(title: "Description", message: "Please leave a Hall Pass description.", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Ex: Bathroom"
            })
            let giveHallPass = UIAlertAction(title: "Give Hall Pass", style: .default, handler: { (action) in
                let description_field = alert.textFields![0].text
                if description_field != "" {
                    let right_now = Date()
                    self.curTime = Int(right_now.timeIntervalSince1970)
                    self.endTime = self.curTime + self.defaultTime
                    self.timerOn = true
                    self.student.hasHallPass = true
                    let studentRef = self.teacherRef!.child("myStudents").child(self.student.UID)
                    studentRef.child("hasPass").setValue(true)
                    studentRef.child("currentPass").updateChildValues(["endTime": self.endTime, "startTime": self.curTime, "description": description_field!])
                    //copy student data to all students
                    studentRef.observeSingleEvent(of: .value, with: { snap in
                        if snap.exists() {
                            self.teacherRef.parent!.parent!.child("allStudents").child(self.student.UID).updateChildValues(snap.value as! [AnyHashable : Any])
                        }
                    })
                    
                    self.upTickBtn.isEnabled = false
                    self.downTickBtn.isEnabled = false
                    let notification = UNMutableNotificationContent()
                    notification.title = "Hall Pass Expiring"
                    notification.body = "\(self.student.firstName) \(self.student.lastName) should have to returned to class by this time"
                    notification.categoryIdentifier = "first_category"
                    
                    let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(self.defaultTime), repeats: false)
                    
                    let request = UNNotificationRequest(identifier: "\(self.student.UID)", content: notification, trigger: notificationTrigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                        if error != nil {
                            print(error!.localizedDescription)
                            
                        } else {
                            print("notification successful")
                        }
                    })
                    self.giveHallPassBtn.setTitle("Close\nHall Pass", for: .normal)

                } else {
                    let alert_2 = UIAlertController(title: "Invalid Entry", message: "Please submit a description.", preferredStyle: .alert)
                    alert_2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert_2, animated: true, completion: nil)
                }
                
            })
            alert.addAction(giveHallPass)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Close Hall Pass", message: "Please choose an option.", preferredStyle: .alert)
            let closeWithDemerit = UIAlertAction(title: "Close With Demerit", style: .default, handler: { (action) in
                
                let studentRef = self.teacherRef!.child("myStudents").child(self.student.UID)
                self.student.demerits += 1
                studentRef.child("demerits").setValue(self.student.demerits)
                self.defaultCloseHallPass(withDem: true)
                })
            let closeWithoutDemerit = UIAlertAction(title: "Close Without Demerit", style: .default, handler: { (action) in
                self.defaultCloseHallPass(withDem: false)
                
            })
            alert.addAction(closeWithDemerit)
            alert.addAction(closeWithoutDemerit)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        if cancelBtn.titleLabel?.text == "Cancel" {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func update_Timer() {
        if (timerOn) {
            counter += 1
            //print("\(self.counter) in upTime" )
            //print("\(endTime) endTime")
            //print("\(curTime) curTime")
            let totalTime = endTime - (curTime + counter)
            var minutes: Int
            var num_secs: Int
            if (totalTime > 0) {
                minutes = totalTime / 60
                num_secs = totalTime % 60
            } else {
                minutes = 0
                num_secs = 0
                giveHallPassPressed(self)
            }
            timerLabel.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", num_secs)
            
        }
        
    }
    
    
    @IBAction func upTickBtnPressed(_ sender: Any) {
        defaultTime += 1
        updateTimer(seconds: defaultTime)

        
    }

    @IBAction func downTickBtnPressed(_ sender: Any) {
        
        defaultTime -= 1
        updateTimer(seconds: defaultTime)
    }
    
    func defaultCloseHallPass(withDem: Bool) {
        self.student.hasHallPass = false
        let studentRef = self.teacherRef!.child("myStudents").child(self.student.UID)
        
        studentRef.child("hasPass").setValue(false)
        studentRef.child("currentPass").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let passInfo = snapshot.value as! [String: Any]
                let startTime = passInfo["startTime"] as! Int
                var description = passInfo["description"] as! String
                if withDem {
                    description = description + " ❌"
                }
                let formatter = DateFormatter()
                let date = Date(timeIntervalSince1970: TimeInterval(startTime))
                formatter.dateFormat = "dd/MM/yyyy"
                let date_string = formatter.string(from: date)
                formatter.dateFormat = "HH:mm"
                let time_string = formatter.string(from: date)
                studentRef.child("logs").childByAutoId().updateChildValues(["date": date_string, "time": time_string, "description": description, "startTime": startTime])
                
            } else {
                print("currentPass is null currently")
            }
        })
        teacherRef.parent!.parent!.child("allStudents").child(student.UID).setValue(nil)
        studentRef.child("currentPass").setValue(nil)
        student.weekCount += 1
        student.monthCount += 1
        student.totalCount += 1
        studentRef.child("weekCount").setValue(student.weekCount)
        studentRef.child("monthCount").setValue(student.monthCount)
        studentRef.child("totalCount").setValue(student.totalCount)
        updateStudentInfoLabels()
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.student.UID])
        downTickBtn.isEnabled = true
        upTickBtn.isEnabled = true
        setDefaultTime(student: student)
        timerOn = false
        counter = 0
        giveHallPassBtn.setTitle("Give Hall Pass", for: .normal)
        updateLogsTBLV()
        
        
        

    }
    
    func updateStudentInfoLabels() {
        weekPassesLabel.text = "Passes this week: \(student.weekCount)"
        monthPassesLabel.text = "Passes this month: \(student.monthCount)"
        totalPassesLabel.text = "Total passes given: \(student.totalCount)"
        demeritsLabel.text = "Total demerits given: \(student.demerits)"
    }
    
    func updateLogsTBLV() {
        studentLogs = []
        let studentRef = teacherRef!.child("myStudents").child(student.UID)
        studentRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("logs") {
                studentRef.child("logs").observeSingleEvent(of: .value, with: { (snap) in
                    if snap.exists() {
                        let logs = snap.value as! [String:[String:Any]]
                        for (_, logInfo) in logs {
                            let date = logInfo["date"] as! String
                            let time = logInfo["time"] as! String
                            let description = logInfo["description"] as! String
                            let startTime = logInfo["startTime"] as! Int
                            let newLog = StudentLog(date: date, time: time, description: description, startTime: startTime)
                            self.studentLogs.append(newLog)
                            self.studentLogs.sort(by: { (student1, student2) -> Bool in
                                return student1.startTime > student2.startTime
                            })
                        }
                        self.logsTBLV.reloadData()
                    }
                })
            }
        })
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timer.invalidate()
    }
    

}

class StudentLog {
    var date: String
    var time: String
    var description: String
    var startTime: Int
    
    init(date D: String, time T: String, description DSC: String, startTime ST: Int) {
        date = D; time = T;  description = DSC; startTime = ST
    }
    
}

