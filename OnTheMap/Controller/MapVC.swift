//
//  MapVC.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 29.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController{
    // MARK: - Outlets, Vars, Enum
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityText: UITextView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    //var locations = [Location]()
    var annotations = [MKPointAnnotation]()
    var seagueFromAddLocationSuccess = false
    var addedLocation: CLLocationCoordinate2D?
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    // MARK: - IBActions
    @IBAction func refreshButtonTapped(_ sender: Any) {
        showActivity(activityText: "updating map locations")
        ParseClient.getLocation(limit: 20, completion: completionHandlerLocations(locations:error:))
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        showActivity(activityText: "logging out")
        LoginClient.logout(completion: completionHandlerLogout(success:error:))
    }
    
    // MARK: Completion Handler Functions
    func completionHandlerLocations(locations: LocationResponse?, error: Error?){
        guard let locations = locations else{
            showAlert(title: "Location Error", message: error?.localizedDescription ?? "Locations couldn't be loaded")
            hideActivity()
            return
        }
        createAnnotaions(locations: locations.results)
        hideActivity()
        checkIfSeagueFromAddedLocation(success: seagueFromAddLocationSuccess)
    }
    
    func completionHandlerLogout(success: Bool, error: Error?){
        if success{
            hideActivity()
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }else{
            self.showAlert(title: "Logout Failed", message: error.debugDescription)
        }
    }
    
    // MARK: Maps Helper Functions
    func centerMapOnLocation(distance: Double, latitude: Double, longitude: Double) {
        let regionRadius: CLLocationDistance = distance
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func createAnnotaions(locations: [Location]){
        for location in locations{
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    // MARK: Basic Functions
    func setup(){
        //ui
        activityView.layer.cornerRadius = 10
        self.tabBarController?.tabBar.isHidden = false
        
        //get locations on start
        hideActivity()
        showActivity(activityText: "updating map locations")
        ParseClient.getLocation(limit: 100, completion: completionHandlerLocations(locations:error:))
        
        //center to europe on start, has the most pins, good for testing
        let coordinateRegion = Utilities.centerMapOnLocation(distance: 3000000, latitude: 41.89193, longitude: 12.51133)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showAlert(title: String, message: String){
        let alert = Alerts.defineAlert(title: title, message: message)
        self.present(alert, animated: true)
    }

    func checkIfSeagueFromAddedLocation(success: Bool){
        if success{ //center map to added location
            if let latitude = addedLocation?.latitude, let longitude = addedLocation?.longitude{
                let coordinateRegion = Utilities.centerMapOnLocation(distance: 3000000, latitude: latitude, longitude: longitude)
                self.mapView.setRegion(coordinateRegion, animated: true)
            }
            seagueFromAddLocationSuccess = false //reset
        }
    }
    
    func showActivity(activityText: String){
        self.activityText.text = activityText
        activitySpinner.startAnimating()
        self.activityView.alpha = 1
        
        UIView.animate(withDuration: 0.3, animations: {
            self.mapView.alpha = 0.5
            self.view.layoutIfNeeded()
        })
    }
    
    func hideActivity(){
        activitySpinner.stopAnimating()
        self.activityView.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.mapView.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
}

extension MapVC: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }

        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = UIColor(red: 0.3, green: 0.6, blue: 0.8, alpha: 1.0)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                Utilities.openUrl(urlString: toOpen, completion: {(success) in
                    if !success{
                        self.showAlert(title: "Website Check", message: CustomError.urlNotValid.errorDescription!)
                    }
                })
            } else {
                showAlert(title: "Website Check", message: CustomError.urlNotValid.errorDescription!)
            }
        }
    }
}
