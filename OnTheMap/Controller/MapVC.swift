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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityText: UITextView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    var locations = [Location]()
    var annotations = [MKPointAnnotation]()
    var seagueFromAddLocationSuccess = false
    var addedLocation: CLLocationCoordinate2D?
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        print("refresh buttun")
        showActivity(activityText: "updating map locations")
        ParseClient.getLocation(limit: 20, completion: completionHandlerLocations(locations:error:))
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        print("Logout Button")
        LoginClient.logout(completion: completionHandlerLogout(success:error:))

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
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
        print("create annotaions")
        for location in locations{
            
            //create Anootation
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            
            //add annotation to array for adding to maap in delegate func
            annotations.append(annotation)
        }
        
        //add annotations to map
        self.mapView.addAnnotations(annotations)
    }
    
    // MARK: Basic Functions
    func showAlert(title: String, message: String){
        let alert = Alerts.defineAlert(title: title, message: message)
        self.present(alert, animated: true)
    }

    func setup(){
        activityView.layer.cornerRadius = 10
        mapView.delegate = self
        self.tabBarController?.tabBar.isHidden = false
        
        //get locations
        hideActivity()
        showActivity(activityText: "updating map locations")
        ParseClient.getLocation(limit: 100, completion: completionHandlerLocations(locations:error:))
    }
    
    func checkIfSeagueFromAddedLocation(success: Bool){
        if success{
            print("seagued from added location & center to coords")
            print(addedLocation as Any)
            if let latitude = addedLocation?.latitude, let longitude = addedLocation?.longitude{
                let coordinateRegion = Utilities.centerMapOnLocation(distance: 3000000, latitude: latitude, longitude: longitude)
                self.mapView.setRegion(coordinateRegion, animated: true)
            }
            seagueFromAddLocationSuccess = false //reset
        }else{
            print("standard center map")
            let coordinateRegion = Utilities.centerMapOnLocation(distance: 3000000, latitude: 41.89193, longitude: 12.51133)
            self.mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    func isUpdateingAnnotations(isUpdating: Bool){
       
    }
    
    func showActivity(activityText: String){
        self.activityText.text = activityText
        activitySpinner.startAnimating()
        self.activityView.alpha = 1
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.mapView.alpha = 0.5
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
            pinView!.pinColor = .purple
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        }
        else {
            print("annotation view")
            pinView!.annotation = annotation
        }
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("click on annotations")
        if !Utilities.verifyUrl(urlString: view.annotation?.subtitle!){
            showAlert(title: "Website Check", message: CustomError.urlNotValid.errorDescription!)
            return
        }
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}
