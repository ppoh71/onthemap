//
//  tableViewVC.swift
//  OnTheMap
//
//  Created by Peter Pohlmann on 05.12.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class tableViewVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var locations = [Location]()
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        print("Logout Button")
        LoginClient.logout(completion: completionHandlerLogout(success:error:))
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        loadLocations()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
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
        print("Location Count \(self.locations.count)")
    }
    
    func completionHandlerLogout(success: Bool, error: Error?){
        if success{
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
       ParseClient.getLocation(limit: 20, completion: completionHandlerLocations(locations:error:))
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
        print("location count")
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("table cells")
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
            
            if !Utilities.verifyUrl(urlString: location.mediaURL){
                showAlert(title: "Website Check", message: CustomError.urlNotValid.errorDescription!)
                return
            }
            
            if let urlHttp = Utilities.addHttp(urlString: location.mediaURL){
                UIApplication.shared.open(urlHttp, options: [:], completionHandler: nil)
            } else{
                showAlert(title: "Website Check", message: CustomError.urlNotValid.errorDescription!)
            }
        }
    }
}
