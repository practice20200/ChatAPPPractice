//
//  LocationPickerViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-23.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerViewController: UIViewController {
    
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    private var coordinates: CLLocationCoordinate2D?
    
    // ============= Elements =============
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    
    //========== Views =========
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(map)
        title = "Pick Location"
        view.backgroundColor = .systemBackground
        
        map.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        map.addGestureRecognizer(gesture)
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneHandler))
        self.navigationItem.rightBarButtonItem = doneButton
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    
    
    
    //========== Functions =========
    @objc func doneHandler(){
        guard let coordinates = coordinates else { return }
        completion?(coordinates)
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer){
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
    }
    
    //override var presentingViewController: UIViewController?
}
