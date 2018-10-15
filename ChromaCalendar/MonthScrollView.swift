//
//  MonthScrollView.swift
//  ChromaCalendar
//
//  Created by Gaelan Chen on 9/23/18.
//  Copyright © 2018 Gaelan Chen. All rights reserved.
//

import UIKit

class MonthScrollView: UIScrollView {
	
	let labelFontSize: CGFloat = 36
	
	var date: Date {
		didSet {
			setLabels()
		}
	}
	var today = Date()
	var monthLabels: [UIButton] = []
	var monthLabelDates: [String] = []
	
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
		super.draw(rect)
		
		let w = bounds.width / 7
		
		let back = UIBezierPath(roundedRect: CGRect(x: 3 * w + contentOffset.x, y: 0, width: w, height: bounds.height), cornerRadius: 0)
		UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1).setFill()
		
		back.fill()
		
		if showIndicator {
			let label = monthLabels[todayIndicator].frame
			
			let radius = label.width / 2.5
			let offset:CGFloat = 20
			
			let indicator = UIBezierPath(arcCenter: CGPoint(x: label.midX, y: label.midY - offset), radius: radius, startAngle: .pi, endAngle: 2 * .pi, clockwise: true)
			indicator.addLine(to: CGPoint(x: label.midX + radius, y: label.midY + offset))
			indicator.addArc(withCenter: CGPoint(x: label.midX, y: label.midY + offset), radius: radius, startAngle: 0, endAngle: .pi, clockwise: true)
			indicator.addLine(to: CGPoint(x: label.midX - radius, y: label.midY - offset))
			
			indicator.lineWidth = 2
			UIColor.black.setStroke()
			
			indicator.stroke()
		}
	}
	
	override func layoutSubviews() {
		contentSize = CGSize(width: bounds.width * 3, height: bounds.height)
		
		let width = CGFloat(frame.width) / 7
		
		for i in 0..<21 {
			let label = monthLabels[i]
			
			let x = CGFloat(i) * width
			
			label.frame = CGRect(x: x, y: 0, width: width, height: bounds.height)
		}
	}
	
	func configureLabels() {
		for i in 0..<21 {
			let label = UIButton()
			
			label.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -2)
			
			monthLabels.append(label)
			addSubview(monthLabels[i])
			
			monthLabelDates.append("")
		}
	}
	
	func setLabels() {
		let calendar = Calendar.current
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM"
		
		showIndicator = false
		
		for i in 0..<21 {
			let label = monthLabels[i]
			var fontColor = UIColor.black
			
			let day = monthOffset(from: date, by: i - 10)
			monthLabelDates[i] = day
			
			if day == formatter.string(from: today) {
				fontColor = .blue
				
				todayIndicator = i
				showIndicator = truedel
			}
			
			let month = calendar.component(.month, from: formatter.date(from: day)!)
			let text = calendar.shortMonthSymbols[month - 1]
			let title = centeredAttributedString(text, fontSize: labelFontSize, color: fontColor)
			label.setAttributedTitle(title, for: .normal)
		}
		
		contentOffset = CGPoint(x: UIScreen.main.bounds.width, y: 0)
		
		if firstLoad {
			for i in 0..<21 {
				monthLabels[i].alpha = 0
				
				UIViewPropertyAnimator.runningPropertyAnimator(
					withDuration: 1,
					delay: Double(i) * 0.1,
					options: [.allowUserInteraction],
					animations: { self.monthLabels[i].alpha = 1 },
					completion: nil)
			}
			firstLoad = false
		}
		
		setNeedsDisplay()
	}
	
	func monthOffset(from day: Date, by offset: Int) -> String {
		let calendar = Calendar.current
		
		var year = calendar.component(.year, from: day)
		var month = calendar.component(.month, from: day)
		
		month += offset
		
		while month < 1 {
			month += 12
			year -= 1
		}
		while month > 12 {
			month -= 12
			year += 1
		}
		
		return "\(year)-\(String(format: "%02d", month))"
	}
	
	private func centeredAttributedString(_ string: String, fontSize: CGFloat, color: UIColor) -> NSAttributedString {
		var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
		font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font, .foregroundColor: color])
	}
}
