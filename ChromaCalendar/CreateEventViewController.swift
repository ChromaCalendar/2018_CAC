//
//  CreateEventViewController.swift
//  ChromaCalendar
//
//  Created by Gaelan Chen on 10/12/18.
//  Copyright © 2018 Gaelan Chen. All rights reserved.
//

import UIKit

class CreateEventViewController: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
	}
	
}



class titleCell: UITableViewCell {
	@IBOutlet weak var title: UITextField!
	
}
class startTimeCell: UITableViewCell {
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	
}
class endTimeCell: UITableViewCell {
	@IBOutlet weak var timeLabel: UILabel!
	
}
class timePickerCell: UITableViewCell {
	@IBOutlet weak var timePicker: UIDatePicker!
	
}
