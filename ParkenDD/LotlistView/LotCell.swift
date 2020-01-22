//
//  LotCell.swift
//  ParkenDD
//
//  Created by Kilian Koeltzsch on 19/01/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import ParkKit

class LotCell: UITableViewCell {

	@IBOutlet weak var parkinglotNameLabel: UILabel?
	@IBOutlet weak var parkinglotAddressLabel: UILabel?
	@IBOutlet weak var parkinglotLoadLabel: UILabel?
	@IBOutlet weak var parkinglotTendencyLabel: UILabel?
	@IBOutlet weak var forecastIndicator: UIImageView?
	@IBOutlet weak var favTriangle: UIImageView?

	var parkinglot: Lot?
	
	var distance: Double = 0.0 {
		didSet {
			guard distance != Const.dummyDistance else {
				parkinglotAddressLabel?.text = L10n.unknownAddress.string
				return
			}
			parkinglotAddressLabel?.text = "\((round(distance/100))/10)km"
		}
	}
	
	func setParkinglot(_ lot: Lot) {
		parkinglot = lot
		
		// Quickfix for issue #103
		let sanitizedLotName = lot.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		
		if let lotType = lot.type, lotType != "" {
			parkinglotNameLabel?.text = "\(lotType) \(sanitizedLotName)"
		} else {
			parkinglotNameLabel?.text = sanitizedLotName
		}

        parkinglotLoadLabel?.text = "\(lot.free)"

		// check if location sorting is enabled, then we're displaying distance instead of address
		let sortingType = UserDefaults.standard.string(forKey: Defaults.sortingType)!
		if sortingType == Sorting.standard || sortingType == Sorting.alphabetical || sortingType == Sorting.free {
			if lot.address == "" {
				parkinglotAddressLabel?.text = L10n.unknownAddress.string
			} else {
				parkinglotAddressLabel?.text = lot.address
			}
		} else {
			parkinglotAddressLabel?.text = L10n.waitingForLocation.string
		}
		
		// Set all labels to be white, 'cause it looks awesome
		parkinglotNameLabel?.textColor = UIColor.white
		parkinglotAddressLabel?.textColor = UIColor.white
		parkinglotLoadLabel?.textColor = UIColor.white
		parkinglotTendencyLabel?.textColor = UIColor.white
		
		// Set the cell's bg color dynamically based on the load percentage.
		var percentage = lot.total > 0 ? 1 - (Double(lot.free) / Double(lot.total)) : 0.99
		if percentage < 0.1 {
			percentage = 0.1
		} else if percentage > 0.99 {
			percentage = 0.99
		}
		backgroundColor = Colors.colorBasedOnPercentage(percentage, emptyLots: lot.free)
		
		// Show the forecast indicator if that data is available
		if lot.hasForecast {
			forecastIndicator?.image = UIImage(named: "graphArrow")
		} else {
			forecastIndicator?.image = nil
		}
		forecastIndicator?.alpha = 0.6
		forecastIndicator?.tintColor = UIColor.white

        let formattedPercentage = String(format: "%.0f", percentage * 100)

		// TODO: Do all kinds of things with the cell according to the state of the lot
        switch lot.state {
        case .closed:
            parkinglotTendencyLabel?.text = L10n.closed.string
            backgroundColor = UIColor.gray
            parkinglotLoadLabel?.text = "X"
//            parkinglotLoadLabel?.attributedText = NSAttributedString(string: "\(lot.free)", attributes: [NSStrikethroughStyleAttributeName: 1])
        case .nodata:
            parkinglotLoadLabel?.text = "?"
            parkinglotTendencyLabel?.text = L10n.unknownLoad.string
            backgroundColor = UIColor.lightGray
        case .open:
            parkinglotTendencyLabel?.text = "\(formattedPercentage)% \(L10n.occupied.string)"
        case .unknown:
            parkinglotTendencyLabel?.text = "\(formattedPercentage)% \(L10n.occupied.string)"
        }
	}
}
