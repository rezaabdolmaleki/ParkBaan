//
//  MapViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 09/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import MapKit
import ParkKit

class MapViewController: UIViewController, MKMapViewDelegate {

	@IBOutlet weak var mapView: MKMapView?

	var detailParkinglot: Lot!
	var allParkinglots: [Lot]!

	override func viewDidLoad() {
		super.viewDidLoad()

		mapView?.showsUserLocation = true
		
		if #available(iOS 9, *) {
			mapView?.showsTraffic = true
		}
		
		// Add annotations for all parking lots to the map
		for singleLot in allParkinglots {
            var subtitle = L10n.mapsubtitle("\(singleLot.free)", singleLot.total).string
            switch singleLot.state {
            case .closed:
                subtitle = L10n.closed.string
            case .nodata:
                subtitle = L10n.mapsubtitle("?", singleLot.total).string
            case .open, .unknown:
                break
            }
			let lotAnnotation = ParkinglotAnnotation(title: singleLot.name, subtitle: subtitle, lot: singleLot)
			
			mapView?.addAnnotation(lotAnnotation)
			
			// Display the callout if this is the previously selected annotation
			if singleLot.name == detailParkinglot.name {
				mapView?.selectAnnotation(lotAnnotation, animated: true)
			}
		}
		
		// Set the map's region to a 1km region around the selected lot
		if let lat = detailParkinglot.coordinate?.latitude, let lng = detailParkinglot.coordinate?.longitude {
			let parkinglotRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: lat, longitude: lng), 1000, 1000)
			mapView?.setRegion(parkinglotRegion, animated: false)
		} else {
			NSLog("Came to map view with a selected lot that has no coordinates. We're now showing Germany. This is probably not ideal.")
		}
		
		// Display the forecast button if this lot has forecast data
		if detailParkinglot.hasForecast {
			navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.forecast.string, style: .plain, target: self, action: #selector(MapViewController.showForecastController))
		}
	}
	
	/**
	Transition to forecast controller
	*/
	@objc func showForecastController() {
		let forecastController = ForecastViewController()
		forecastController.lot = detailParkinglot
		show(forecastController, sender: self)
	}

	// It's nice to show custom pin colors on the map denoting the current state of the parking lot they're referencing
	// green: open, unknown (if more than 0 free, otherwise red)
	// red: closed, nodata
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		// We don't care about the MKUserLocation here
		guard annotation.isKind(of: ParkinglotAnnotation.self) else { return nil }
		
		let annotation = annotation as? ParkinglotAnnotation
		let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "parkinglotAnnotation")

		if let state = annotation?.lot.state {
			switch state {
			case .closed:
				annotationView.pinColor = .red
			case .open, .unknown:
				annotationView.pinColor = annotation?.lot.free != 0 ? .green : .red
			case .nodata:
				annotationView.pinColor = .purple
			}
		}

		annotationView.canShowCallout = true

		return annotationView
	}

}
