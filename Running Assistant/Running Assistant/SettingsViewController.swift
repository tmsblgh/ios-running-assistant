//
//  SettingsViewController.swift
//  Running Assistant
//
//  Created by Balogh Tamás on 2018. 04. 17..
//  Copyright © 2018. Balogh Tamás. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var speedToggle: UISwitch!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var speedSliderValueLabel: UILabel!
    
    private var defaultValues = UserDefaults.standard
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        defaultValues.set(speedToggle.isOn, forKey: "SPEED_TOGGLE")
        defaultValues.set(speedSlider.value, forKey: "SPEED_SLIDER")
        
        let alertController = UIAlertController(title: "Beállítások", message: "Sikeres mentés!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Bezár", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func speedToggleSwitched(_ sender: UISwitch) {
        if speedToggle.isOn {
            speedSlider.isEnabled = true
            speedSliderValueLabel.isHidden = false
        } else {
            speedSlider.isEnabled = false
            speedSliderValueLabel.isHidden = true
        }
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        speedSliderValueLabel.text = String(format:"%.1f km/h", speedSlider.value)
    }
    
    private func loadSettings() {
        speedToggle.isOn = defaultValues.bool(forKey: "SPEED_TOGGLE")
        speedSlider.value = Float(defaultValues.double(forKey: "SPEED_SLIDER"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

