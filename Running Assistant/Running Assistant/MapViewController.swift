//
//  MapViewController.swift
//  Running Assistant
//
//  Created by Balogh Tamás on 2018. 04. 07.
//  Copyright © 2018. Balogh Tamás. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    private var defaultValues = UserDefaults.standard
    private var goalSpeed: Float?
    private var run: Run?
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var deltaDistance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    
    private func startRun() {
        startButton.isHidden = true
        stopButton.isHidden = false
        
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        startLocationUpdates()
    }
    
    private func stopRun() {
        startButton.isHidden = false
        stopButton.isHidden = true
        
        locationManager.stopUpdatingLocation()
    }
    
    private func loadSettings() {
        goalSpeed = Float(defaultValues.double(forKey: "SPEED_SLIDER"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.isHidden = true
        loadSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    private func updateDisplay() {
        let formattedCurrentSpeed = FormatDisplay.speed(distance: deltaDistance,
                                                        goalSpeed: goalSpeed!,
                                                        seconds: 3, // TODO Add deltaTime
            outputUnit: UnitSpeed.kilometersPerHour)
        let formattedAverageSpeed = FormatDisplay.speed(distance: distance, goalSpeed: goalSpeed!,
                                                        seconds: seconds,
                                                        outputUnit: UnitSpeed.kilometersPerHour)
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        
        currentSpeedLabel.text = "  Jelenlegi sebesség  \(formattedCurrentSpeed)"
        averageSpeedLabel.text = "  Átlagsebesség  \(formattedAverageSpeed)"
        distanceLabel.text = "  Megtett távolság  \(formattedDistance)"
        timeLabel.text = "  Eltelt idõ  \(formattedTime)"
    }
    
    @IBAction func startTapped(_ sender: UIBarButtonItem) {
        startRun()
    }
    
    @IBAction func stopTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Biztosan megállítod?",
                                                message: "Szeretnéd menteni a futást?",
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Mégse", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Mentés", style: .default) { _ in
            self.stopRun()
            self.saveRun()
            self.performSegue(withIdentifier: .details, sender: nil)
        })
        alertController.addAction(UIAlertAction(title: "Nem szeretném menteni", style: .destructive) { _ in
            self.stopRun()
            _ = self.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alertController, animated: true)
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    
    private func saveRun() {
        let newRun = Run(context: CoreDataStack.context)
        newRun.averageSpeed = distance.value / Double(seconds)
        newRun.distance = distance.value
        newRun.duration = Int16(seconds)
        newRun.date = Date()
        
        for location in locationList {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRun.addToLocations(locationObject)
        }
        
        CoreDataStack.saveContext()
        
        run = newRun
    }
}

extension MapViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        case details = "RunDetailsViewController"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .details:
            let destination = segue.destination as! RunDetailsViewController
            destination.run = run
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                deltaDistance = Measurement(value: newLocation.distance(from: lastLocation), unit: UnitLength.meters)
                distance = distance + deltaDistance
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                mapView.add(MKPolyline(coordinates: coordinates, count: 2))
                let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500)
                mapView.setRegion(region, animated: true)
            }
            
            locationList.append(newLocation)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .black
        renderer.lineWidth = 3
        return renderer
    }
}

