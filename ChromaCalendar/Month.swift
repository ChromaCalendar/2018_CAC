//
//  Month.swift
//  ChromaCalendar
//
//  Created by Gaelan Chen on 9/23/18.
//  Copyright © 2018 Gaelan Chen. All rights reserved.
//

import Foundation

class Month {
	
	var date: Date {
		didSet {
			let calendar = Calendar.current
			month = calendar.component(.month, from: date)
			
			let formatter = DateFormatter()
			formatter.dateFormat = "LLLL"
			monthName = formatter.string(from: date)
		}
	}
	
	var month: Int
	var monthName: String
	
	init(_ day: String) {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		
		if let today = formatter.date(from: day) {
			date = today
		} else {
			date = formatter.date(from: "2000-01-01")!
		}
		
		let calendar = Calendar.current
		month = calendar.component(.month, from: date)
		
		formatter.dateFormat = "LLLL"
		monthName = formatter.string(from: date)
	}
}
