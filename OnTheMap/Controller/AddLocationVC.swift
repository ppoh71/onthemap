//
//  AddLocationVC.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 02.12.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit
import MapKit

class AddLocationVC: UIViewController {
    // MARK: - Outlets, Vars, Enum
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findLocationWarpperView: UIView!
    @IBOutlet weak var addLocationWrapperView: UIView!
    @IBOutlet weak var foundLocationLabel: UILabel!
    @IBOutlet weak var websiteTextfield: UITextField!
    @IBOutlet weak var findLocationTextfield: UITextField!
    @IBOutlet weak var findLocationTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var findLocationButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityText: UITextView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    let animationSpeed = 0.6
    var addLatitude: Double?
    var addLongitude: Double?
    
    enum ActionState: Int{
        case findLocationAction = 0
        case addLocationAction = 1
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    // MARK: IBActions
    @IBAction func findLocationButtonTapped(_ sender: Any) {
        switch findLocationButton.tag{
            case 0: //find loaction
                if let address = findLocationTextfield.text, !address.isEmpty {
                    showActivity(activityText: "searching location", mapAlpha: false)
                    getGeoCoordinates(forAddress: address, completion: requestHandlerGeoLocation(location:error:))
                } else {
                   showAlert(title: "No Location Text", message: CustomError.findAddressTextEmpty.errorDescription!)
            }
            case 1: //back to find location action
                setActionState(state: .findLocationAction)
            default:
                print("do nothing")
        }
        self.view.endEditing(true)
    }
    
    @IBAction func addLocationButtonTapped(_ sender: Any) {
        if !Utilities.verifyUrl(urlString: websiteTextfield.text){
            showAlert(title: "Website Check", message: CustomError.noWebsite.errorDescription!)
            return
        }
        
        if let latitude = addLatitude, let longitude = addLongitude, let mapString = findLocationTextfield.text {
            showActivity(activityText: "Posting Location", mapAlpha: true)
            
            let mediaURL = websiteTextfield.text ?? ""
            let postLocation = PostLocationRequest(uniqueKey: NSUUID().uuidString, firstName: LoginClient.Auth.firstName, lastName: LoginClient.Auth.lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude )
            
            ParseClient.postLocation(postLocation: postLocation, completion: requestHandlerPostLocation(postLocation:error:))
            view.endEditing(true) // close Keyboard
        }
    }

    // MARK: RequestHandler
    func requestHandlerPostLocation(postLocation: PostLocationResponse?, error: Error?){
        guard postLocation != nil else{
            showAlert(title: "Location Post Failed", message: CustomError.postLocationFailed.errorDescription!)
            return
        }
        
        self.activityText.text = "Post Location Successful"
        self.activitySpinner.stopAnimating()
        
        //go back to mapview & center map with coords from added location
        segueBackAfterAddLocationSuccess()

    }
    
    func requestHandlerGeoLocation(location: CLLocationCoordinate2D?, error: Error?){
        guard let location = location else{
            self.showAlert(title: "GeoLocation Error", message: "\(CustomError.locationNotFound.errorDescription!)" )
            return
        }
        
        //set for adding later via post
        self.addLatitude = location.latitude
        self.addLongitude = location.longitude
        
        //create marker on map
        createAnnotaion(location: location)
        
        //center map to marker
        let coordinateRegion = Utilities.centerMapOnLocation(distance: 250000, latitude: location.latitude, longitude: location.longitude)
        self.mapView.setRegion(coordinateRegion, animated: true)
        hideActivity()
        setActionState(state: .addLocationAction)
    }
    
    // MARK: Map Functions
    func getGeoCoordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                completion(nil, error)
                return
            }
            completion(placemarks?.first?.location?.coordinate, nil)
        }
    }
    
    func createAnnotaion(location: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        annotation.title = ""
        annotation.subtitle = ""
        
        self.mapView.addAnnotation(annotation)
    }
    
    // MARK: Basic Functions
    func setup(){
        hideActivity()
        findLocationButton.tag = 0
        self.tabBarController?.tabBar.isHidden = true
        
        //ui
        findLocationTextfield.layer.cornerRadius = Utilities.cornerRadius
        websiteTextfield.layer.cornerRadius = Utilities.cornerRadius
        findLocationButton.layer.cornerRadius = Utilities.cornerRadius
        addLocationButton.layer.cornerRadius = Utilities.cornerRadius
        foundLocationLabel.text = ""
        activityView.layer.cornerRadius = 10
    }
    
    func segueBackAfterAddLocationSuccess(){
        guard let navigationCount = self.navigationController?.viewControllers.count else { return }
        
        //back to where we are coming from
        if let mapVC = self.navigationController!.viewControllers[navigationCount-2] as? MapVC{
            mapVC.addedLocation = CLLocationCoordinate2D(latitude: addLatitude ?? 0, longitude: addLongitude ?? 0)
            mapVC.seagueFromAddLocationSuccess = true
            self.navigationController?.popToViewController(mapVC, animated: true)
        }
        
        if let tableViewVC = self.navigationController!.viewControllers[navigationCount-2] as? tableViewVC{
            self.navigationController?.popToViewController(tableViewVC, animated: true)
        }
    }
    
    func setActionState(state: ActionState){
        switch state{
        case .findLocationAction:
            findLocationButton.tag = ActionState.findLocationAction.rawValue
            animate(state: ActionState.findLocationAction)
        case .addLocationAction:
            findLocationButton.tag = ActionState.addLocationAction.rawValue
            foundLocationLabel.text = "Location found: \(findLocationTextfield.text!)"
            animate(state: ActionState.addLocationAction)
        }
    }
    
    func animate(state: ActionState){
        switch state{
        case .addLocationAction:
            self.findLocationTopConstraint.constant = -155
            self.findLocationButtonTopConstraint.constant = 25
            UIView.animate(withDuration: 0.5, animations: {
                self.findLocationButton.alpha = 0
                self.findLocationTextfield.alpha = 0
                self.addLocationWrapperView.alpha = 1
                self.view.layoutIfNeeded() //animate uiview rather with constrains
            },  completion: { (finish) in
                UIView.animate(withDuration: 0.8, animations: {
                    self.findLocationButton.setTitle("Find New Location", for: .normal)
                    self.findLocationButton.alpha = 0.5
                })
            })
        case .findLocationAction:
            self.findLocationTopConstraint.constant = 5
            self.findLocationButtonTopConstraint.constant = 10
            UIView.animate(withDuration: 0.5, animations: {
                self.findLocationTextfield.alpha = 1
                self.findLocationButton.alpha = 1
                self.addLocationWrapperView.alpha = 0
                self.view.layoutIfNeeded() //animate uiview rather with constrains
            })
        }
    }
   
    func showAlert(title: String, message: String){
        let alert = Alerts.defineAlert(title: title, message: message)
        self.present(alert, animated: true)
    }
    
    func showActivity(activityText: String, mapAlpha: Bool){
        self.activityText.text = activityText
        activitySpinner.startAnimating()
        self.activityView.alpha = 1

        if mapAlpha{
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
                self.mapView.alpha = 0.5
            })
        }
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


extension AddLocationVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.black
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        }
        else {
            print("annotation view")
            pinView!.annotation = annotation
        }
        return pinView
    }
}

extension AddLocationVC:  UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
}

