//
//  ViewController.swift
//  Robowars
//
//  Created by Deniz Karakay on 28.02.2021.
//

import UIKit
import Firebase
import MSCircularSlider

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
    var firstAngle: Double = 0.0
    var firstDirection: String = "s"
    
    let parentName: String = "robowars_deniz"
    
    
    override func viewDidLoad() {
        loadingIndicator.startAnimating()
        
        ref = Database.database().reference()
        readData()
        
        degreeSlider.isEnabled = false
        downButton.isEnabled = false
        motorButton.isEnabled = false
        upButton.isEnabled = false
        
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.loadingIndicator.isHidden = true
            
            self.degreeSlider.currentValue = self.firstAngle
            
            
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
            
            self.degreeSlider.isEnabled = true
            self.downButton.isEnabled = true
            self.motorButton.isEnabled = true
            self.upButton.isEnabled = true
            
        }
        
        
        super.viewDidLoad()
        
    }
    
    
    @IBAction func motorButtonClick(_ sender: Any) {
        if !motorStatus{
            motorStatus = updateMotorButton(state: true)
        }else{
            sendData(childName: "direction", childValue: "stop")
            sendData(childName: "angle", childValue: "0")
            motorStatusImage.tintColor = UIColor.red
            degreeSlider.currentValue = 0
            motorStatus = updateMotorButton(state: false)
        }
    }
    
    @IBAction func upButtonClick(_ sender: Any) {
        if checkMotorState(){
            motorStatusImage.tintColor = UIColor.green
            sendData(childName: "direction", childValue: "forward")
        }
    }
    
    @IBAction func downButtonClick(_ sender: Any) {
        if checkMotorState(){
            motorStatusImage.tintColor = UIColor.yellow
            sendData(childName: "direction", childValue: "backward")
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        if firstTime || checkMotorState(){
            let current = String(degreeSlider.currentValue)
            degreeLabel.text = current
            
            sendData(childName: "angle", childValue: current)
        }
    }
    
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
    
    func showMotorAlert(){
        let alert = UIAlertController(title: "Did you turn on motor?", message: "Please click motor button to turn on.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        
        self.present(alert, animated: true)
    }
    
    
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
    
    func sendData(childName: String, childValue:String){
        
        ref.child(parentName).child(childName).setValue(childValue)
        
        
    }
    
    
    func readData(){
        var angle: Double = -1.1
        var direction: String = "stop"
        
        ref.child(parentName).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                angle = (value["angle"] as! String).toDouble()!
                direction = value["direction"] as! String
                
                print(angle)
                print(direction)
                self.firstAngle = angle
                self.firstDirection = direction
                
                
            }
        })
        
    }
    
}

