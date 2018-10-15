//
//  EventControllers.swift
//  ChromaCalendar
//
//  Created by Gaelan Chen on 10/14/18.
//  Copyright © 2018 Gaelan Chen. All rights reserved.
//

import UIKit
import EventKit

class AddEventViewController: UIViewController {
	
	var calendar: EKCalendar!
	
	@IBOutlet weak var eventNameTextField: UITextField!
	@IBOutlet weak var eventStartDatePicker: UIDatePicker!
	@IBOutlet weak var eventEndDatePicker: UIDatePicker!
	
	var delegate: EventAddedDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.eventStartDatePicker.setDate(initialDatePickerValue(), animated: false)
		self.eventEndDatePicker.setDate(initialDatePickerValue(), animated: false)
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
		view.addGestureRecognizer(tap)
		
		calendar = EKCalendar(for: .event, eventStore: EKEventStore())
	}
	
	@objc func dismissKeyboard(_ recognizer: UITapGestureRecognizer) {
		view.endEditing(true)
	}
	
	func initialDatePickerValue() -> Date {
		
		let calendarUnitFlags: NSCalendar.Unit = [.year, .month, .day, .hour, .minute, .second]
		
		
		
		var dateComponents = (Calendar.current as NSCalendar).components(calendarUnitFlags, from: Date())
		
		
		
		dateComponents.hour = 0
		
		dateComponents.minute = 0
		
		dateComponents.second = 0
		
		
		
		return Calendar.current.date(from: dateComponents)!
		
	}
	
	@IBAction func cancelEventButtonTapped(_ sender: UIButton) {
		
		self.dismiss(animated: true, completion: nil)
		
	}
	
	
	
	@IBAction func addEventButtonTapped(_ sender: UIBarButtonItem) {
		// Create an Event Store instance
		let eventStore = EKEventStore()
		
		let calendars = eventStore.calendars(for: EKEntityType.event)
		for calendar in calendars {
			if calendar.title == "Calendar" {
				let newEvent = EKEvent(eventStore: eventStore)
				
				newEvent.calendar = calendar
				newEvent.title = self.eventNameTextField.text ?? "Unspecified Event Name"
				newEvent.startDate = self.eventStartDatePicker.date
				newEvent.endDate = self.eventEndDatePicker.date
				// Save the event using the Event Store instance
				do {
					try eventStore.save(newEvent, span: .thisEvent, commit: true)
					delegate?.eventDidAdd()
					
					self.dismiss(animated: true, completion: nil)
				} catch {
					let alert = UIAlertController(title: "Uhoh - I could not save this event", message: (error as NSError).localizedDescription, preferredStyle: .alert)
					let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
					alert.addAction(OKAction)
					
					self.present(alert, animated: true, completion: nil)
				}
			}
		}
	}
}

protocol EventAddedDelegate {
	func eventDidAdd()
}
