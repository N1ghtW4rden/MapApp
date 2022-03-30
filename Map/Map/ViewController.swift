//
//  ViewController.swift
//  Map
//
//  Created by Горохов Никита Исип20 on 28.03.2022.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var itemMapFirst: MKMapItem!
    var itemMapSecond: MKMapItem!
    
    let manager: CLLocationManager = {
    
        let locationManager = CLLocationManager()
        
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = true
        
        return locationManager
    
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        manager.delegate = self
        
        authorization()
        pinPosition()
        
        let touch = UILongPressGestureRecognizer(target: self, action: #selector(addPin(recogn:)))
        mapView.addGestureRecognizer(touch)
            manager.startUpdatingLocation()

    }
    
    func pinPosition() {
        
        let arrayLet = [62.03, 50.45]
        let arrayLon = [129.73, 30.52]
        
        for number in 0..<arrayLet.count {
            
            let point = MKPointAnnotation()
            point.title = "My Point"
            point.coordinate = CLLocationCoordinate2D(latitude: arrayLet[number], longitude: arrayLon[number])
            mapView.addAnnotation(point)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
            itemMapFirst = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
            
        }
    }
    
    func authorization() {
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            mapView.showsUserLocation = true
            
        }
        else {
        
            manager.requestWhenInUseAuthorization()
            
        }
        
    }
    
    func calculateRoute() {
        let request = MKDirections.Request()
        request.source = itemMapFirst
        request.destination = itemMapSecond
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            guard let directionResponse = response else
            { return }
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.lineWidth = 5
        render.strokeColor = .red
        return render
    }
    
    @objc func addPin (recogn: UIGestureRecognizer) {
        let newLocation = recogn.location(in: mapView)
        let newCoordinate = mapView.convert(newLocation, toCoordinateFrom: mapView)
        itemMapSecond = MKMapItem(placemark: MKPlacemark(coordinate: newCoordinate))
        let point = MKPointAnnotation()
        point.title = "Конечная точка"
        point.coordinate = newCoordinate
        mapView.addAnnotation(point)
        calculateRoute()
    }

}

