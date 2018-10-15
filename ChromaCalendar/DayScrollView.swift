//
//  DayScrollView.swift
//  ChromaCalendar
//
//  Created by Gaelan Chen on 9/24/18.
//  Copyright © 2018 Gaelan Chen. All rights reserved.
//

import UIKit

class DayScrollView: UIScrollView {
	let labelFontSize: CGFloat = 32
	
	var date: Date {
		didSet {
			setLabels()
		}
	}
	var today = Date()
	var dayLabels: [UIButton] = []
	var weekdayLabels: [UIButton] = []
	var dayLabelDates: [String] = []
	
	var firstLoad = true
	
	var scrollOffset: Int = 0
	
	var todayIndicator = 0
	var showIndicator = false
	
	required init(coder aDecoder: NSCoder) {
		date = Date()
		
		super.init(coder: aDecoder)!
		
		showsHorizontalScrollIndicator = false
		
		configureLabels()
		setLabels()
	}
	
	override func draw(_ rect: CGRect) {
		
		let w = bounds.width / 7
		
		
		let clip = UIBezierPath(rect: CGRect(x: contentOffset.x, y: 0, width: w * 7, height: bounds.height))
		clip.addClip()
		UIColor.white.setFill()
		clip.fill()
		
		
		let back = UIBezierPath(rect: CGRect(x: 3 * w + contentOffset.x, y: 0, width: w, height: bounds.height))
		UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1).setFill()
		
		back.fill()
		
		if showIndicator {
			let label = dayLabels[todayIndicator].frame
			
			let indicator = UIBezierPath(arcCenter: CGPoint(x: label.midX, y: label.midY), radius: label.width / 2.5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
			indicator.lineWidth = 2
			
			UIColor.black.setStroke()
			indicator.stroke()
		}
		
		
		super.draw(rect)
	}
	
	override func layoutSubviews() {
		contentSize = CGSize(width: bounds.width * 3, height: bounds.height)
		
		let width = CGFloat(frame.width) / 7
		
		for i in 0..<21 {
			let label = dayLabels[i]
			
			let x = CGFloat(i) * width
			let height = bounds.height / 2
			
			label.frame = CGRect(x: x, y: height, width: width, height: height)
			
			
			let weekdayLabel = weekdayLabels[i]
			weekdayLabel.frame = CGRect(x: x, y: 0, width: width, height: height)
		}
	}
	
	func configureLabels() {
		for i in 0..<21 {
			let label = UIButton()
			
			dayLabels.append(label)
			addSubview(dayLabels[i])
			
			
			
			let label2 = UIButton()
			
			weekdayLabels.append(label2)
			addSubview(weekdayLabels[i])
			
			dayLabelDates.append("")
		}
	}
	
	func setLabels() {
		let calendar = Calendar.current
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		
		showIndicator = false
		
		for i in 0..<21 {
			let label = dayLabels[i]
			var fontColor = UIColor.black
			
			
			let day = dayOffset(from: date, by: i - 10)
			dayLabelDates[i] = formatter.string(from: day)
			
			if formatter.string(from: day) == formatter.string(from: today) {
				fontColor = .blue
				
				todayIndicator = i
				showIndicator = true
			}
			
			
			let text = calendar.component(.day, from: day)
			
			let title = centeredAttributedString(String(text), fontSize: labelFontSize, color: fontColor)
			label.setAttributedTitle(title, for: .normal)
			
			
			
			let weekdayLabel = weekdayLabels[i]
			
			let weekday = calendar.component(.weekday, from: date)
			
			let text2 = calendar.veryShortWeekdaySymbols[(i + weekday + 3) % 7]
			let title2 = centeredAttributedString(text2, fontSize: labelFontSize, color: .black)
			weekdayLabel.setAttributedTitle(title2, for: .normal)
			
			setNeedsDisplay()
		}
		
		contentOffset = CGPoint(x: bounds.width, y: 0)
		
		if firstLoad {
			for i in 0..<21 {
				dayLabels[i].alpha = 0
				weekdayLabels[i].alpha = 0
				
				UIViewPropertyAnimator.runningPropertyAnimator(
					withDuration: 1,
					delay: Double(i) * 0.05,
					options: [.allowUserInteraction],
					animations: { self.dayLabels[i].alpha = 1; self.weekdayLabels[i].alpha = 1},
					completion: nil)
			}
			firstLoad = false
		}
		
		setNeedsDisplay()
	}
	
	func dayOffset(from day: Date, by offset: Int) -> Date {
		let calendar = Calendar.current
		
		var year = calendar.component(.year, from: day)
		var month = calendar.component(.month, from: day)
		var myday = calendar.component(.day, from: day) + offset
		
		let daysThisMonth = calendar.range(of: .day, in: .month, for: day)!.count
		
		if myday > daysThisMonth {
			myday -= daysThisMonth
			
			let first = day.first
			let nextMonth = calendar.date(byAdding: .month, value: 1, to: first)!
			
			year = calendar.component(.year, from: nextMonth)
			month = calendar.component(.month, from: nextMonth)
		}
		
		if myday < 1 {
			let first = day.first
			let lastMonth = calendar.date(byAdding: .month, value: -1, to: first)!
			
			year = calendar.component(.year, from: lastMonth)
			month = calendar.component(.month, from: lastMonth)
			
			let daysLastMonth = calendar.range(of: .day, in: .month, for: lastMonth)!.count
			
			myday += daysLastMonth
		}
		
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		
		return formatter.date(from: "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", myday))")!
	}
	
	func dateAwayFrom(_ date: Date, by inc: Int) -> String {
		let calendar = Calendar.current
		let formatter = DateFormatter()
		
		let day = calendar.component(.day, from: date)
		
		if day + inc > 0 && day + inc <= (calendar.range(of: .day, in: .month, for: date)?.count)! {
			
			return String(day + inc)
		} else if day + inc <= 0 {
			var year = calendar.component(.year, from: date)
			
			let thisMonth = calendar.component(.month, from: date)
			var month = thisMonth - 1
			
			if month == 0 {
				year -= 1
				month = 12
			}
			
			formatter.dateFormat = "yyyy-MM-dd"
			let lastMonth = formatter.date(
				from: "\(year)-\(String(format: "%02d", month))-01")!
			
			return String((calendar.range(of: .day, in: .month, for: lastMonth)?.count)! + day + inc)
		}
		
		return String(day + inc - (calendar.range(of: .day, in: .month, for: date)?.count)!)
	}
	
	private func centeredAttributedString(_ string: String, fontSize: CGFloat, color: UIColor) -> NSAttributedString {
		var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
		font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font, .foregroundColor: color])
	}
}
