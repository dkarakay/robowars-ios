//
//  ViewController.swift
//  Robowars
//
//  Created by Deniz Karakay on 28.02.2021.
//

import UIKit
import Firebase
import MSCircularSlider

// Converting String to Double
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

class ViewController: UIViewController {
    
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var motorButton: UIButton!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet var motorStatusImage: UIImageView!
    @IBOutlet var degreeSlider: MSCircularSlider!
    @IBOutlet var upButton: UIButton!
    @IBOutlet var downButton: UIButton!
    
    var ref: Firebase.DatabaseReference!
    var motorStatus: Bool = false
    
    var firstTime: Bool = true
    var firstAngle: Int = 0
    var firstDirection: String = "s"
    var firstMotorState: Bool = false
    
    let parentName: String = "robowars_deniz"
    
    
    override func viewDidLoad() {
        loadingIndicator.startAnimating()
        
        ref = Database.database().reference()
        readData()
        
        // Disable buttons and slider
        degreeSlider.isEnabled = false
        downButton.isEnabled = false
        motorButton.isEnabled = false
        upButton.isEnabled = false
        
        // Wait 2 seconds to fetch data from Firebase
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.loadingIndicator.isHidden = true
            
            // Update angle value
            self.degreeSlider.currentValue = Double(self.firstAngle)
            
            // Update motor state
            self.motorStatus = self.firstMotorState
            
            // Update motor status
            if self.firstDirection == "forward"{
                self.motorStatus = self.updateMotorButton(state: true)
                self.motorStatusImage.tintColor = UIColor.green
            }else if self.firstDirection == "backward"{
                self.motorStatus = self.updateMotorButton(state: true)
                self.motorStatusImage.tintColor = UIColor.yellow
            }else{
                self.motorStatus = self.updateMotorButton(state: false)
                self.motorStatusImage.tintColor = UIColor.red
                
            }
            
            self.firstTime = false
            
            // Enable buttons and slider
            self.degreeSlider.isEnabled = true
            self.downButton.isEnabled = true
            self.motorButton.isEnabled = true
            self.upButton.isEnabled = true
            
            // Long press gesture
            self.addLongPressGesture()
        }
        
        super.viewDidLoad()
        
    }
    
    // Adding long press
    func addLongPressGesture(){
        let longPressUpButton = UILongPressGestureRecognizer(target: self, action: #selector(longPressUpButton(gesture:)))
        longPressUpButton.minimumPressDuration = 0
        self.upButton.addGestureRecognizer(longPressUpButton)
        
        
        let longPressDownButton = UILongPressGestureRecognizer(target: self, action: #selector(longPressDownButton(gesture:)))
        longPressDownButton.minimumPressDuration = 0
        self.downButton.addGestureRecognizer(longPressDownButton)
    }
    
    // Long press up button
    @objc func longPressUpButton(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began && checkMotorState()  {
            motorStatusImage.tintColor = UIColor.green
            sendData(childName: "direction", childValue: "forward")
            
        }else {
            motorStatusImage.tintColor = UIColor.red
            sendData(childName: "direction", childValue: "none")
            
        }
    }
    
    // Long press down button
    @objc func longPressDownButton(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began && checkMotorState() {
            motorStatusImage.tintColor = UIColor.yellow
            sendData(childName: "direction", childValue: "backward")
            
        }else {
            motorStatusImage.tintColor = UIColor.red
            sendData(childName: "direction", childValue: "none")
            
        }
        
    }
    
    // If you click motor button
    @IBAction func motorButtonClick(_ sender: Any) {
        if !motorStatus{
            sendData(childName: "motor_state", childValue: "running")
            motorStatus = updateMotorButton(state: true)
        }else{
            sendData(childName: "direction", childValue: "none")
            sendData(childName: "motor_state", childValue: "stopping")
            sendData(childName: "angle", childValue: "0")
            motorStatusImage.tintColor = UIColor.red
            degreeSlider.currentValue = 0
            motorStatus = updateMotorButton(state: false)
        }
    }
    
    
    // If slider value changed
    @IBAction func sliderValueChanged(_ sender: Any) {
        if firstTime || checkMotorState(){
            let current = String(degreeSlider.currentValue)
            degreeLabel.text = current
            
            sendData(childName: "angle", childValue: current, isFloat: true)
        }
    }
    
    // Update Motor Button UI
    func updateMotorButton(state:Bool)->Bool{
        if state{
            motorButton.setTitle("ON", for: .normal)
            motorButton.setTitleColor(UIColor.systemGreen, for: .normal)
        }else{
            motorButton.setTitle("OFF", for: .normal)
            motorButton.setTitleColor(UIColor.systemRed, for: .normal)
        }
        return state
    }
    
    // Show Alert Dialog
    func showMotorAlert(){
        let alert = UIAlertController(title: "Did you turn on motor?", message: "Please click motor button to turn on.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // Checking Motor State
    func checkMotorState()-> Bool{
        if motorStatus {
            
        }else{
            showMotorAlert()
            if degreeSlider.currentValue != 0{
                degreeSlider.currentValue = 0
            }
        }
        return motorStatus
    }
    
    // Sending data to Firebase
    func sendData(childName: String, childValue:String, isFloat:Bool = false){
        if isFloat {
            let childInt:Float = Float(childValue) ?? 0
            ref.child(parentName).child(childName).setValue(childInt)
        }else{
            ref.child(parentName).child(childName).setValue(childValue)
        }
    }
    
    // Reading data from Firebase
    func readData(){
        var angle: Int = 0
        var direction: String = "none"
        var motorState: String = "running"
        
        ref.child(parentName).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                
                // Getting angle & direction from Firebase
                angle = value["angle"] as! Int
                direction = value["direction"] as! String
                motorState = value["motor_state"] as! String
                
                self.firstAngle = angle
                self.firstDirection = direction
                
                if motorState == "running"{
                    self.firstMotorState = true
                }else{
                    self.firstMotorState = false
                    
                }
                
            }
        })
        
    }
    
}

