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

    
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var slider: MSCircularSlider!
    
    var ref: Firebase.DatabaseReference!

    override func viewDidLoad() {
        
        ref = Database.database().reference()
        
        super.viewDidLoad()
        
       
        // Do any additional setup after loading the view.
    }

    @IBAction func stopButtonClick(_ sender: Any) {
        ref.child("robowars_deniz").child("direction").setValue("stop")
    }
    @IBAction func upButtonClick(_ sender: Any) {
        ref.child("robowars_deniz").child("direction").setValue("forward")

    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let current = String(slider.currentValue)
        degreeLabel.text = current
        ref.child("robowars_deniz").child("angle").setValue(current)
    }
    
    @IBAction func downButtonClick(_ sender: Any) {
        ref.child("robowars_deniz").child("direction").setValue("back")

    }
}

