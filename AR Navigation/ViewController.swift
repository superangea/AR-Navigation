//
//  ViewController.swift
//  AR Navigation
//
//  Created by Angela Cheng on 12/2/17.
//  Copyright © 2017 Angela Cheng. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, UISearchDisplayDelegate {
    private let googleString = "https://maps.googleapis.com/maps/api/directions/json?mode=walking&"
    private let apiKey = "AIzaSyDWW1vTVngQtcM1Drt--N6g6xixCAoFmhE"
    let locationManager = CLLocationManager()
    var steps = [(Double, Double, String)]()
    var htmlInstructions = [String]()
    
    
    @IBOutlet weak var destinationTextField: UITextField!
    
    // UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        destinationTextField.text = textField.text
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.distanceFilter = 0.5
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func getUserLocation() -> (lat: Double, long: Double) {
        return (41.313844, -72.932478)
    }
    
    // Actions
    @IBAction func submitButton(_ sender: UIButton) {
        
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ARViewController = segue.destination as? ARViewController {
            let startLoc:CLLocationCoordinate2D = locationManager.location!.coordinate
            let startLat:Double = 41.3136254
            let startLong:Double = -72.9305611
            let endLat:Double = 41.311177
            let endLong:Double = -72.931307
            let reqString = "\(googleString)origin=\(startLoc.latitude),\(startLoc.longitude)&destination=\(endLat),\(endLong)&key=\(apiKey)"
            ARViewController.req = reqString
        }
    }
    
}



