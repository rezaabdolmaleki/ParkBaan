//
//  NSDateFormatter.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 28/10/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

extension DateFormatter {
	convenience init(dateFormat: String, timezone: TimeZone?) {
		self.init()
		self.dateFormat = dateFormat
		if let timezone = timezone {
			self.timeZone = timezone
		}
	}
}
