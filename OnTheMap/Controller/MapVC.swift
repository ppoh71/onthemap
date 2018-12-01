//
//  MapVC.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 29.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var locations = [Location]()
    var annotations = [MKPointAnnotation]()
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        print("refresh buttun")
        ParseClient.getLocation(amount: 20, completion: requestHandlerLocations(locations:error:))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //centerMapOnLocation()
    }
    
    func centerMapOnLocation() {
        let regionRadius: CLLocationDistance = 3000000
        let initialLocation = CLLocation(latitude: 36.778259, longitude: -119.417931)
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func requestHandlerLocations(locations: LocationResponse?, error: Error?){
        guard let locations = locations else{
            print("guard failed")
            print(error?.localizedDescription as Any)
            return
        }
        createAnnotaions(locations: locations.results)
    }
    
    func createAnnotaions(locations: [Location]){
        print("create annotaions")
        for location in locations{
            //create location cordinate from lat, long
            
            //create Anootation
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            print("\(location.firstName) \(location.lastName)")
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            
            //self.mapView.addAnnotation(annotation)
            
            //add annotation to array for adding to maap in delegate func
            annotations.append(annotation)
        }
        
         //print(annotations)
        //add annotations to map
        self.mapView.addAnnotations(annotations)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapVC: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        print("add annotaions")
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            //pinView!.pinColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
