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
    public var isPickable = true
    private var coordinates: CLLocationCoordinate2D?
    
    // ============= Elements =============
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    init(coordinates: CLLocationCoordinate2D?){
        self.coordinates = coordinates
        self.isPickable = coordinates == nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    //========== Views =========
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(map)
        view.backgroundColor = .systemBackground
        if isPickable{
            print("Tapped")
            map.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap(_ :)))
            gesture.numberOfTapsRequired = 1
            gesture.numberOfTouchesRequired = 1
            map.addGestureRecognizer(gesture)
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneHandler))
            self.navigationItem.rightBarButtonItem = doneButton
        }else{
            print("unTapped")
            guard let coordinates = self.coordinates else { return }
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    
    
    
    //========== Functions =========
    @objc func doneHandler(){
        guard let coordinates = coordinates else { return }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer){
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
    }
    
    
    
}
