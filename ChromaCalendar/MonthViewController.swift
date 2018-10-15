//
//  MonthViewController.swift
//  ChromaCalendar
//
//  Created by Gaelan Chen on 9/23/18.
//  Copyright © 2018 Gaelan Chen. All rights reserved.
//

import UIKit

class MonthViewController: UIViewController, UIScrollViewDelegate {
	
	var date: Date
	
	@IBOutlet weak var monthView: MonthView!
	
	@IBOutlet weak var monthScrollView: MonthScrollView!
	
	var firstLoad = true
	
	func prepareContent() {
		monthView.date = date
		monthScrollView.date = date
		
		for i in monthView.begin..<monthView.end {
			let label = monthView.dayLabels[i]
			
			let tap = UITapGestureRecognizer(target: self, action: #selector(datePress(_:)))
			label.addGestureRecognizer(tap)
		}
		
		
		for i in 0..<21 {
			let label = monthScrollView.monthLabels[i]
			
			let tap = UITapGestureRecognizer(target: self, action: #selector(monthPress(_:)))
			label.addGestureRecognizer(tap)
		}
		
		monthScrollView.delegate = self
		
		if firstLoad {
			monthScrollView.alpha = 0
			UIViewPropertyAnimator.runningPropertyAnimator(
				withDuration: 1,
				delay: 0.5,
				options: [.allowUserInteraction],
				animations: { self.monthScrollView.alpha = 1},
				completion: nil)
			
			firstLoad = false
		}
	}
	
	func cleanContent() {
		for i in 0..<42 {
			let label = monthView.dayLabels[i]
			
			label.gestureRecognizers = []
		}
		
		
		for i in 0..<21 {
			let label = monthScrollView.monthLabels[i]
			
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
		
		monthSelect(Int(offset))
	}
	
	// When month view label is tapped...
	@objc func datePress(_ recognizer: UITapGestureRecognizer) {
		if recognizer.state == .ended {
			let formatter = DateFormatter()
			
			if let label = recognizer.view as? UIButton {
				let title = label.attributedTitle(for: .normal)!
				let text = Int(title.string)!
				
				formatter.dateFormat = "yyyy-MM-"
				let month = formatter.string(from: date)
				
				formatter.dateFormat = "yyyy-MM-dd"
				segueDay = formatter.date(from: "\(month)\(String(format: "%02d", text))")!
				
				performSegue(withIdentifier: "Show Day", sender: nil)
			}
		}
	}
	
	// When month scroll view label is tapped...
	@objc func monthPress(_ recognizer: UITapGestureRecognizer) {
		if recognizer.state == .ended {
			if let label = recognizer.view as? UIButton {
				let formatter = DateFormatter()
				
				formatter.dateFormat = "yyyy-MM"
				date = formatter.date(from: monthScrollView.monthLabelDates[monthScrollView.monthLabels.firstIndex(of: label)!])!
				
				cleanContent()
				prepareContent()
			}
		}
	}
	
	func monthSelect(_ index: Int) {
		let formatter = DateFormatter()
		
		formatter.dateFormat = "yyyy-MM"
		date = formatter.date(from: monthScrollView.monthLabelDates[index])!
		
		cleanContent()
		prepareContent()
	}
	
	var segueDay = Date()
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Show Day" {
			if let dayViewController = segue.destination as? DayViewController {
				dayViewController.date = segueDay
				//dayViewController.prepareContent()
			}
		}
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		prepareContent()
		
		//self.title = month!.monthName
    }
	
	required init(coder aDecoder: NSCoder) {
		date = Date()
		
		super.init(coder: aDecoder)!
	}
}
