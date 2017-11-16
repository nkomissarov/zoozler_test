//
//  ViewController.swift
//  zoozler_test
//
//  Created by Nick Komissarov on 11/16/17.
//  Copyright © 2017 Nick Komissarov. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GoogleMapsDirections

class ViewController: UIViewController, SearchPointViewDelegate, GMSMapViewDelegate {
    var point1: SearchPointView?
    var point2: SearchPointView?
    var mapView: GMSMapView?
    var marker1: GMSMarker = GMSMarker()
    var marker2: GMSMarker = GMSMarker()
    var route: GMSPolyline?
    override func viewDidLoad() {
        super.viewDidLoad()
        

        point1 = SearchPointView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: view.frame.width, height: 40), text: "From");
        point1!.delegate = self;
        view.addSubview(point1!)
        point2 = SearchPointView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height+56, width: view.frame.width, height: 40), text: "To");
        point2!.delegate = self;
        view.addSubview(point2!)

        
        definesPresentationContext = true


    }

    override func loadView() {
        super.loadView()
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapTop = UIApplication.shared.statusBarFrame.height + 56 + 56
        
       mapView = GMSMapView.map(withFrame: CGRect(
            x: 0,
            y: mapTop,
            width: view.frame.size.width,
            height: view.frame.size.height - mapTop), camera: camera)
        mapView!.delegate = self
        mapView!.setMinZoom(4, maxZoom: 13)
        mapView!.isMyLocationEnabled = true
        mapView!.settings.compassButton = true
        mapView!.settings.myLocationButton = true
        mapView!.settings.zoomGestures = true
        view.addSubview(mapView!)
    }
    
    func didPointChanged(view: SearchPointView, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        if (view == point1){
            marker1.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            marker1.isDraggable = true;
            marker1.map = mapView!
        } else {
            marker2.isDraggable = true;
            marker2.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            marker2.map = mapView!
        }
        
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(marker1.position)
        bounds = bounds.includingCoordinate(marker2.position)
        mapView!.animate(with: GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(100.0 , 50.0 ,50.0 ,50.0)))

        if (point1!.latitude > 0 && point2!.latitude > 0){
            
            GoogleMapsDirections.direction(
                fromOriginCoordinate: GoogleMapsService.LocationCoordinate2D(
                    latitude: point1!.latitude, longitude: point1!.longitude),
                toDestinationCoordinate: GoogleMapsService.LocationCoordinate2D(
                    latitude: point2!.latitude,longitude: point2!.longitude)
            ){ (response, error) -> Void in
                guard response?.status == GoogleMapsDirections.StatusCode.ok  else {
                    return
                }
                let path = GMSPath(fromEncodedPath: response!.routes[0].overviewPolylinePoints!);
                if (self.route != nil){
                    self.route!.map = nil
                }
                self.route = GMSPolyline(path: path)
                self.route!.strokeWidth = 2.0
                self.route!.map = self.mapView!
            }
        }
    }

    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        if (marker == marker1){
            point1!.setCoordinates(position: marker.position)
        }
        if (marker == marker2){
            point2!.setCoordinates(position: marker.position)
        }
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if (point1!.latitude == 0){
            point1!.setCoordinates(position: coordinate)
        }else if (point2!.latitude == 0){
            point2!.setCoordinates(position: coordinate)
        }
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            let offset = UIApplication.shared.isStatusBarHidden ? 0 : UIApplication.shared.statusBarFrame.height
            self.mapView!.frame = CGRect(
                x: 0,
                y: offset + 56 + 56,
                width: self.view.frame.size.width,
                height: self.view.frame.size.height - offset)
            
            self.point1!.frame = CGRect(x: 0, y: offset, width: self.view.frame.size.width, height: 40);
            self.point2!.frame = CGRect(x: 0, y: offset + 56, width: self.view.frame.size.width, height: 40);

        })
        
        super.willTransition(to: newCollection, with: coordinator)
    }

}
