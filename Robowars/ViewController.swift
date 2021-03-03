//
//  ViewController.swift
//  Robowars
//
//  Created by Deniz Karakay on 28.02.2021.
//

import UIKit
import Firebase
import MSCircularSlider

class ViewController: UIViewController {
    
    
    @IBOutlet weak var motorButton: UIButton!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet var motorStatusImage: UIImageView!
    @IBOutlet var degreeSlider: MSCircularSlider!
    
    var ref: Firebase.DatabaseReference!
    var motorStatus: Bool = false
    let parentName: String = "robowars_deniz"
    
    override func viewDidLoad() {
        ref = Database.database().reference()
        readData()
        //motorStatus = updateMotorButton(state: motorStatus)
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
        if checkMotorState(){
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
        ref.child(parentName).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            if let userDict = snapshot.value as? [String:Any] {
                //Do not cast print it directly may be score is Int not string
                print(userDict)
            }
        })
        
    }
    
}

