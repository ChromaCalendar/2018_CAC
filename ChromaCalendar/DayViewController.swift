//
//  DayViewController.swift
//  ChromaCalendar
//
//  Created by Gaelan Chen on 9/24/18.
//  Copyright © 2018 Gaelan Chen. All rights reserved.
//

import UIKit
import EventKit

class DayViewController: UIViewController, UIScrollViewDelegate {
	
	var calendars: [EKCalendar]?
	
	var date: Date {
		didSet {
			//prepareContent()
		}
	}
	
	@IBOutlet weak var dayView: DayView!
	
	@IBOutlet weak var dayScrollView: DayScrollView!
	
	var firstLoad = true
	let eventStore = EKEventStore()
	var events: [EKEvent] = []
	
	func prepareContent() {
		
		fetchEvents(on: date)
		dayView.events = events
		dayView.setLabels()
		
		dayView.date = date
		dayScrollView.date = date
		
		for i in 0..<21 {
			let label = dayScrollView.dayLabels[i]
			let dateLabel = dayScrollView.weekdayLabels[i]
			
			let tap = UITapGestureRecognizer(target: self, action: #selector(dayPress(_:)))
			label.addGestureRecognizer(tap)
			
			let tap2 = UITapGestureRecognizer(target: self, action: #selector(dayPress(_:)))
			dateLabel.addGestureRecognizer(tap2)
		}
		
		let rotate = UIPanGestureRecognizer(target: self, action: #selector(dayRotate(_:)))
		rotate.maximumNumberOfTouches = 1
		rotate.minimumNumberOfTouches = 1
		dayView.addGestureRecognizer(rotate)
		
		
		dayScrollView.delegate = self
		
		if firstLoad {
			dayScrollView.alpha = 0
			UIViewPropertyAnimator.runningPropertyAnimator(
				withDuration: 1,
				delay: 0.5,
				options: [.allowUserInteraction],
				animations: { self.dayScrollView.alpha = 1},
				completion: nil)
			
			firstLoad = false
		}
		
		dayView.setNeedsDisplay()
	}
	
	func cleanContent() {
		for i in 0..<21 {
			let label = dayScrollView.dayLabels[i]
			
			label.gestureRecognizers = []
		}
	}
	
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollView.setNeedsDisplay()
	}
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>){
		var offset = scrollView.contentOffset.x
		
		let width = UIScreen.main.bounds.width / 7
		offset = round(offset / width + 2 * velocity.x)
		
		offset *= width
		targetContentOffset.pointee.x = offset
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let width = UIScreen.main.bounds.width / 7
		let offset = round(scrollView.contentOffset.x / width) + 3
		
		daySelect(Int(offset))
	}
	
	
	var previousAngle: CGFloat = 0
	
	@objc func dayRotate(_ recognizer: UIPanGestureRecognizer) {
		if recognizer.state == .began {
			let pos = recognizer.location(in: dayView)
			
			previousAngle = atan2(pos.x - dayView.bounds.midX, pos.y - dayView.bounds.midY)
		}
		
		if recognizer.state == .changed {
			let pos = recognizer.location(in: dayView)
			
			let angle = atan2(pos.x - dayView.bounds.midX, pos.y - dayView.bounds.midY)
			
			var rotation = previousAngle - angle
			
			if rotation > .pi {
				rotation -= 2 * .pi
			}
			else if rotation < 0 - .pi {
				rotation += 2 * .pi
			}
			
			dayView.rotateBy(rotation)
			
			previousAngle = angle
		}
	}
	
	@objc func dayPress(_ recognizer: UITapGestureRecognizer) {
		if recognizer.state == .ended {
			if let label = recognizer.view as? UIButton {
				let formatter = DateFormatter()
				
				formatter.dateFormat = "yyyy-MM-dd"
				
				let day = dayScrollView.dayLabels.firstIndex(of: label) ?? dayScrollView.weekdayLabels.firstIndex(of: label)!
				
                date = formatter.date(from: dayScrollView.dayLabelDates[day])!
				
				cleanContent()
				prepareContent()
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		checkCalendarAuthorizationStatus()
	}
	
	func checkCalendarAuthorizationStatus() {
		let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
		
		switch (status) {
			case EKAuthorizationStatus.notDetermined:
				// This happens on first-run
				requestAccessToCalendar()
			case EKAuthorizationStatus.authorized:
				// Things are in line with being able to show the calendars in the table view
				//loadCalendars()
				refreshDayView()
			case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
				// We need to help them give us permission
				performSegue(withIdentifier: "Show Permission", sender: nil)
		}
	}
	
	func requestAccessToCalendar() {
		eventStore.requestAccess(to: EKEntityType.event, completion: {
			(accessGranted: Bool, error: Error?) in
			
			if accessGranted == true {
				DispatchQueue.main.async(execute: {
					self.loadCalendars()
					self.refreshDayView()
				})
			} else {
				DispatchQueue.main.async(execute: {
					self.performSegue(withIdentifier: "Show Permission", sender: nil)
				})
			}
		})
	}
	
	func loadCalendars() {
		self.calendars = eventStore.calendars(for: EKEntityType.event)
	}
	
	func refreshDayView() {
		
	}
	
	func fetchEvents(on day: Date){
		let calendar = Calendar.current
		var dateComponents = DateComponents.init()
		dateComponents.day = 1
		let futureDate = calendar.date(byAdding: dateComponents, to: day) // 1
		
		let eventsPredicate = self.eventStore.predicateForEvents(withStart: day, end: futureDate!, calendars: nil) // 2
		
		events = self.eventStore.events(matching: eventsPredicate)
	}
	
	
	func daySelect(_ index: Int) {
		let formatter = DateFormatter()
		
		formatter.dateFormat = "yyyy-MM-dd"
		date = formatter.date(from: dayScrollView.dayLabelDates[index])!
		
		cleanContent()
		prepareContent()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		prepareContent()
		
		//self.title = day!.dayName
	}
	
	required init(coder aDecoder: NSCoder) {
		date = Date()
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		
		//day = Day(formatter.string(from: date))
		
		super.init(coder: aDecoder)!
	}
}
