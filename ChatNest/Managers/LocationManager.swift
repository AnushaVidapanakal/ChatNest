 import Foundation
 import CoreLocation
 
 class LocationManager: CLLocationManager, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    private(set) var coord: CLLocationCoordinate2D?
    
    private(set) var lastLocation: CLLocation?
    private(set) var myLocation: CLLocation?
   
    
    func start() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        
       //   loc = locationManager.location!
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    // to get user's current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let userLocation = locations.first else {
            return
        }
        
        lastLocation = locations.last! as CLLocation
        print("lastLocation")
        NSLog("\(lastLocation)")
        
        let latValue = userLocation.coordinate.latitude
        let longValue = userLocation.coordinate.longitude
        
        print("location values in LocMgr:")
        print("user latitude = \(latValue)")
        print("user longitude = \(longValue)")
        
        let currentLat = self.locationManager.location!.coordinate.latitude
        let currentLong = self.locationManager.location!.coordinate.longitude
        myLocation = CLLocation(latitude: currentLat, longitude: currentLong) 
        print("myLocation")
        NSLog("\(myLocation)")
        
        coord = userLocation.coordinate
        
     /*   let c1 = CLLocation(latitude: 5.0, longitude: 5.0)
        let c2 = CLLocation(latitude: 5.0, longitude: 3.0)
        let distInMetres = c1.distance(from: c2)
        print("distance in metres")
        NSLog("\(distInMetres)")
        */
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        
    }
    
    
    
    
    
 }
