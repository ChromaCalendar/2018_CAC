//
//  MonthView.swift
//  ChromaCalendar
//
//  Created by Gaelan Chen on 9/23/18.
//  Copyright © 2018 Gaelan Chen. All rights reserved.
//

import UIKit

class MonthView: UIView {
	
	let labelFontSize: CGFloat = 32
	
	var date: Date {
		didSet {
			setDayLabels()
		}
	}
	
	var dayLabels: [UIButton] = []
	var weekLabels: [UILabel] = []
	var monthLabel = UILabel()
	
	var firstLoad = true
	
	var begin = 0
	var end = 0
	
	var todayIndicator = 0
	var showIndicator = false
	
	required init(coder aDecoder: NSCoder) {
		date = Date()
		
		super.init(coder: aDecoder)!
		
		configureLabels()
		setDayLabels()
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		for i in 0..<42 {
			let label = dayLabels[i].frame
			let center = CGPoint(x: label.midX, y: label.midY)
			
			if showIndicator && i == todayIndicator {
				let indicator = UIBezierPath(arcCenter: center, radius: bounds.width / 16, startAngle: 0, endAngle: .pi * 2, clockwise: true)
				indicator.lineWidth = 2
				UIColor.black.setStroke()
				
				indicator.stroke()
			}
			else {
				let shade = UIBezierPath(arcCenter: center, radius: bounds.width / 16, startAngle: 0, endAngle: .pi * 2, clockwise: true)
				UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1).setFill()
				
				shade.fill()
			}
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let width = frame.width / 7
		let height = frame.height / 8
		
		monthLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: height)
		
		for i in 0..<7 {
			let label = weekLabels[i]
			
			let x = CGFloat(i) * width
			
			label.frame = CGRect(x: x, y: height, width: width, height: height)
		}
		
		for i in 0..<42 {
			let label = dayLabels[i]
			
			let x = CGFloat(i % 7) * width
			let y = CGFloat(i / 7) * height + 2 * height
			
			label.frame = CGRect(x: x, y: y, width: width, height: height)
		}
	}
	
	func configureLabels() {
		let calendar = Calendar.current
		
		addSubview(monthLabel)
		
		for i in 0..<7 {
			let label = UILabel()
			
			let text = calendar.veryShortWeekdaySymbols[i]
			let title = centeredAttributedString(text, fontSize: labelFontSize, color: UIColor.black)
			label.attributedText = title
			
			weekLabels.append(label)
			addSubview(weekLabels[i])
		}
		
		for i in 0..<42 {
			dayLabels.append(UIButton())
			addSubview(dayLabels[i])
		}
	}
	
	func setDayLabels() {
		let calendar = Calendar.current
		let formatter = DateFormatter()
		
		let first = date.first
		
		showIndicator = false
		
		let weekday = calendar.component(.weekday, from: first)
		let lastMonth = calendar.date(byAdding: .month, value: -1, to: first)!
		
		let daysLastMonth = calendar.range(of: .day, in: .month, for: lastMonth)!.count
		let daysThisMonth = calendar.range(of: .day, in: .month, for: first)!.count
		
		formatter.dateFormat = "LLLL  yyyy"
		monthLabel.attributedText = centeredAttributedString(formatter.string(from: first), fontSize: labelFontSize, color: .black)
		
		begin = weekday - 1
		end = daysThisMonth + weekday - 1
		
		for i in 1..<weekday {
			let dayLabel = dayLabels[i - 1]
			
			let text = String(daysLastMonth - weekday + i + 1)
			let title = centeredAttributedString(text, fontSize: labelFontSize, color: .gray)
			dayLabel.setAttributedTitle(title, for: .normal)
		}
		
		
		for i in 0..<daysThisMonth {
			let dayLabel = dayLabels[weekday + i - 1]
			var fontColor = UIColor.black
			
			if calendar.date(bySetting: .day, value: i + 1, of: first)!.isToday {
				fontColor = .blue
				
				todayIndicator = weekday + i - 1
				showIndicator = true
			}
			
			let title = centeredAttributedString(String(i + 1), fontSize: labelFontSize, color: fontColor)
			dayLabel.setAttributedTitle(title, for: .normal)
		}
		
		
		for i in daysThisMonth + weekday - 1..<42 {
			let dayLabel = dayLabels[i]
			
			let text = String(i - daysThisMonth - weekday + 2)
			let title = centeredAttributedString(text, fontSize: labelFontSize, color: .gray)
			dayLabel.setAttributedTitle(title, for: .normal)
		}
		
		if firstLoad {
			for i in 0..<42 {
				dayLabels[i].alpha = 0
				
				UIViewPropertyAnimator.runningPropertyAnimator(
					withDuration: 1,
					delay: Double(i) * 0.02,
					options: [.allowUserInteraction],
					animations: { self.dayLabels[i].alpha = 1 },
					completion: nil)
			}
			firstLoad = false
		}
		
		setNeedsDisplay()
	}
	
	private func centeredAttributedString(_ string: String, fontSize: CGFloat, color: UIColor) -> NSAttributedString {
		var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
		font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font, .foregroundColor: color])
	}
	
	func getDaysIn(year: Int, month: Int) -> Int? {
		let dateComponents = DateComponents(year: year, month: month)
		let calendar = Calendar.current
		let date = calendar.date(from: dateComponents)!
		
		let range = calendar.range(of: .day, in: .month, for: date)!
		return range.count
	}
}

extension Date {
	var isToday: Bool {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		
		return formatter.string(from: self) == formatter.string(from: Date())
	}
	var first: Date {
		let calendar = Calendar.current
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		
		let year = calendar.component(.year, from: self)
		let month = calendar.component(.month, from: self)
		
		return formatter.date(from: "\(year)-\(String(format: "%02d", month))-01")!
	}
}
