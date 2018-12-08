//
//  tableViewVC.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 05.12.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class tableViewVC: UIViewController {
    // MARK: - Outlets, Vars, Enum
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var locations = [Location]()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    // MARK: - IBActions
    @IBAction func logoutButtonTapped(_ sender: Any) {
        print("Logout Button")
        showIndicator(true)
        LoginClient.logout(completion: completionHandlerLogout(success:error:))
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        loadLocations()
    }
    
    // MARK: Completion Handler Functions
    func completionHandlerLocations(locations: LocationResponse?, error: Error?){
        guard let locations = locations else{
            showAlert(title: "Location Error", message: error?.localizedDescription ?? "Locations couldn't be loaded")
            return
        }
        
        self.locations = locations.results
        self.tableView.reloadData()
        self.showIndicator(false)
    }
    
    func completionHandlerLogout(success: Bool, error: Error?){
        if success{
            showIndicator(false)
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }else{
            self.showAlert(title: "Logout Failed", message: error.debugDescription)
        }
    }
    
    // MARK: Basic Functions
    func setup(){
        self.tabBarController?.tabBar.isHidden = false
        loadLocations()
    }
    
    func loadLocations(){
       showIndicator(true)
       ParseClient.getLocation(limit: 1000, completion: completionHandlerLocations(locations:error:))
    }
    
    func showIndicator(_ show: Bool){
        if show{
            spinner.startAnimating()
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.alpha = 0.2
                self.view.layoutIfNeeded()
            })
        }else{
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.alpha = 1
                self.view.layoutIfNeeded()
            })
            spinner.stopAnimating()
        }
    }
    
    func showAlert(title: String, message: String){
        let alert = Alerts.defineAlert(title: title, message: message)
        self.present(alert, animated: true)
    }
}

extension tableViewVC:  UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell")!
        if let location = locations[(indexPath as IndexPath).row] as Location? {
            cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
            cell.detailTextLabel?.text = "\(location.mapString) (\(location.mediaURL))"
            cell.imageView?.image = UIImage(named: "pin")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let location = locations[(indexPath as IndexPath).row] as Location? {
            Utilities.openUrl(urlString: location.mediaURL, completion: {(success) in
                if !success{
                    self.showAlert(title: "Website Check", message: CustomError.urlNotValid.errorDescription!)
                }
            })
        }
    }
}
