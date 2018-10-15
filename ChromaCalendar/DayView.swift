//
//  DayView.swift
//  ChromaCalendar
//
//  Created by Gaelan Chen on 9/24/18.
//  Copyright © 2018 Gaelan Chen. All rights reserved.
//

import UIKit
import EventKit

class DayView: UIView {
	
	let labelFontSize: CGFloat = 24
	
	let colors: [UIColor] = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.magenta]
	
	var date: Date {
		didSet {
			loadGraph()
		}
	}
	var angle: CGFloat = 0
	var dateString: String {
		let calendar = Calendar.current
		
		let month = calendar.component(.month, from: date)
		let monthString = calendar.shortMonthSymbols[month - 1]
		
		let day = calendar.component(.day, from: date)
		
		return "\(monthString) \(day)"
	}
	
	var centerLabel = UILabel()
	var hourLabels: [UILabel] = []
	
	var events: [EKEvent] = []
	var eventLabels: [UILabel] = []
	
	required init(coder aDecoder: NSCoder) {
		date = Date()
		
		super.init(coder: aDecoder)!
		
		configureLabels()
		loadGraph()
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		let calendar = Calendar.current
		let formatter = DateFormatter()
		
		let midX = bounds.midX
		let midY = bounds.midY
		
		let radius = bounds.width / 2.4
		let rad = bounds.width / 10
		
		let outline = UIBezierPath(arcCenter: CGPoint(x: midX, y: midY), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
		
		outline.move(to: CGPoint(x: midX + rad, y: midY))
		
		outline.addArc(withCenter: CGPoint(x: midX, y: midY), radius: rad, startAngle: 0, endAngle: .pi * 2, clockwise: true)
		
		outline.lineWidth = 2
		
		
		let dayOutline = UIBezierPath()
		dayOutline.addArc(withCenter: CGPoint(x: midX, y: midY), radius: radius, startAngle: 3 * .pi / 2, endAngle: 5 * .pi / 2 + angle, clockwise: angle > 0 - .pi)
		
		dayOutline.move(to: CGPoint(x: midX, y: midY - rad))
		dayOutline.addLine(to: CGPoint(x: midX, y: midY - radius))
		dayOutline.move(to: CGPoint(x: midX, y: midY - rad))
		
		dayOutline.addArc(withCenter: CGPoint(x: midX, y: midY), radius: rad, startAngle: 3 * .pi / 2, endAngle: 5 * .pi / 2 + angle, clockwise: angle > 0 - .pi)
		
		dayOutline.lineWidth = 2
		
		
		let segments = UIBezierPath()
		
		for i in 0..<12 {
			let x = rad * cos(angle + CGFloat(i) * .pi / 6)
			let y = rad * sin(angle + CGFloat(i) * .pi / 6)
			
			segments.move(to: CGPoint(x: x + midX, y: y + midY))
			
			let x2 = radius * cos(angle + CGFloat(i) * .pi / 6)
			let y2 = radius * sin(angle + CGFloat(i) * .pi / 6)
			
			segments.addLine(to: CGPoint(x: x2 + midX, y: y2 + midY))
		}
		
		// Draw Calendar Events
		formatter.dateFormat = "yyyy-MM-dd"
		for event in events {
			let day = event.startDate!
			let end = event.endDate!
			
			if formatter.string(from: day) != formatter.string(from: end) {
				continue
			}
			
			let startHour = calendar.component(.hour, from: day)
			let startMinute = calendar.component(.minute, from: day)
			
			let endHour = calendar.component(.hour, from: end)
			let endMinute = calendar.component(.minute, from: end)
			
			let shownAngle = angle / .pi * -6 + 12
			let startTime = CGFloat(startHour) + CGFloat(startMinute) / 60
			let endTime = CGFloat(endHour) + CGFloat(endMinute) / 60
			
			if startTime < shownAngle && startTime > shownAngle - 12 || endTime < shownAngle && endTime > shownAngle -  12 {
				
				var startAngle: CGFloat = 0
				var endAngle: CGFloat = 0
				
				if startTime < shownAngle && startTime >= shownAngle - 12 && endTime < shownAngle && endTime >= shownAngle - 12 {
					
					startAngle = 3 * .pi / 2 + startTime / 6 * .pi + angle
					endAngle = 3 * .pi / 2 + endTime / 6 * .pi + angle
				}
				else if startTime < shownAngle && startTime > shownAngle - 12 {
					
					startAngle = 3 * .pi / 2 + startTime / 6 * .pi + angle
					endAngle = 3 * .pi / 2
				}
				else if endTime < shownAngle && endTime > shownAngle - 12 {
					
					startAngle = 3 * .pi / 2
					endAngle = 3 * .pi / 2 + endTime / 6 * .pi + angle
				}
				
				let path = UIBezierPath()
				
				path.move(to: trig(rad, startAngle, midX, midY))
				path.addLine(to: trig(radius, startAngle, midX, midY))
				path.addArc(withCenter: CGPoint(x: midX, y: midY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
				path.addLine(to: trig(rad, endAngle, midX, midY))
				path.addArc(withCenter: CGPoint(x: midX, y: midY), radius: rad, startAngle: endAngle, endAngle: startAngle, clockwise: false)
				
				colors[events.firstIndex(of: event)!].setFill()
				path.fill()
			}
		}
		
		
		
		
		
		UIColor.gray.setStroke()
		segments.stroke()
		
		UIColor.yellow.setStroke()
		outline.stroke()
		
		UIColor.black.setStroke()
		dayOutline.stroke()
	}
	
	func rotateBy(_ ang: CGFloat) {
		angle += ang
		
		if angle > 0 {
			angle = 0
		}
		else if angle < .pi * -2 {
			angle = .pi * -2
		}
		
		layoutLabels()
		setNeedsDisplay()
	}
	
	
	override func layoutSubviews() {
		/*
		super.layoutSubviews()
		
		print("LAYOUT")
		
		centerLabel.frame = CGRect(x: bounds.midX - 25, y: bounds.midY - 40, width: 50, height: 80)
		
		for i in 0..<12 {
			let label = hourLabels[i]
			label.frame = CGRect(x: bounds.midX - 25, y: bounds.midY - 25, width: 50, height: 50)
			
			let angle = (CGFloat(i) - 2) * CGFloat.pi / 6
			label.transform = CGAffineTransform(rotationAngle: angle)
			
			let r = UIScreen.main.bounds.width / 2.1
			let x = r * cos(angle)
			let y = r * sin(angle)
			label.transform = CGAffineTransform(translationX: x, y: y)
			
			//willRemoveSubview(label)
			//addSubview(label)
		}
		*/
	}
	
	func layoutLabels() {
		
		for i in 0..<12 {
			let label = hourLabels[i]
			
			let ang = (CGFloat(i) - 2) * CGFloat.pi / 6 + angle
			
			let r = bounds.width / 2.2
			let x = r * cos(ang)
			let y = r * sin(ang)
			
			label.frame = CGRect(x: x + bounds.midX - 20, y: y + bounds.midY - 20, width: 40, height: 40)
		}
		
		for i in 0..<eventLabels.count {
			let label = eventLabels[i]
			
			let calendar = Calendar.current
			
			let day = events[i].startDate!
			let end = events[i].endDate!
			
			let startHour = calendar.component(.hour, from: day)
			let startMinute = calendar.component(.minute, from: day)
			
			let endHour = calendar.component(.hour, from: end)
			let endMinute = calendar.component(.minute, from: end)
			
			let shownAngle = angle / .pi * -6 + 12
			let startTime = CGFloat(startHour) + CGFloat(startMinute) / 60
			let endTime = CGFloat(endHour) + CGFloat(endMinute) / 60
			
			if startTime < shownAngle && startTime >= shownAngle - 12 && endTime < shownAngle && endTime >= shownAngle - 12 {
				
				let endAngle = mod(3 * .pi / 2 + endTime / 6 * .pi + angle, 2 * .pi)
				
				let w = bounds.width / 3.84
				
				let x = w * cos(endAngle - 0.1) + bounds.midX
				let y = w * sin(endAngle - 0.1) + bounds.midY
				
				label.frame = CGRect(x: x - 50, y: y - 50, width: 100, height: 100)
				//label.bounds.origin = CGPoint(x: x, y: y)
				//label.transform = CGAffineTransform(translationX: x, y: y)
				
				if endAngle < .pi / 2 || endAngle > 3 * .pi / 2 {
					label.transform = CGAffineTransform(rotationAngle: endAngle)
				} else {
					label.transform = CGAffineTransform(rotationAngle: endAngle + .pi)
				}
				
				
				label.isHidden = false
			} else {
				label.isHidden = true
			}
		}
	}
	
	func configureLabels() {
		centerLabel.numberOfLines = 2
		centerLabel.frame = CGRect(x: bounds.midX - 25, y: bounds.midY - 40, width: 50, height: 80)
		
		addSubview(centerLabel)
		
		for i in 0..<12 {
			let label = UILabel()
			
			let title = centeredAttributedString("\(i + 1)", fontSize: labelFontSize, color: .black)
			label.attributedText = title
			
			
			hourLabels.append(label)
			addSubview(hourLabels[i])
		}
	}
	
	func setLabels() {
		
		eventLabels = []
		
		for event in events {
			let label = UILabel()
			
			let title = centeredAttributedString(event.title!, fontSize: 12, color: .black)
			label.attributedText = title
			
			eventLabels.append(label)
			addSubview(eventLabels[events.firstIndex(of: event)!])
		}
		
		layoutLabels()
	}
	
	func loadGraph() {
		let text = dateString
		let title = centeredAttributedString(text, fontSize: labelFontSize, color: .black)
		centerLabel.attributedText = title
	}
	
	private func centeredAttributedString(_ string: String, fontSize: CGFloat, color: UIColor) -> NSAttributedString {
		var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
		font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font, .foregroundColor: color])
	}
	
	func trig(_ radius: CGFloat, _ angle: CGFloat, _ xOffset: CGFloat, _ yOffset: CGFloat) -> CGPoint {
		
		let x = radius * cos(angle) + xOffset
		let y = radius * sin(angle) + yOffset
		
		return CGPoint(x: x, y: y)
	}
	
	func mod(_ a: CGFloat, _ n: CGFloat) -> CGFloat {
		precondition(n > 0, "modulus must be positive")
		let r = a.truncatingRemainder(dividingBy: n)
		return r >= 0 ? r : r + n
	}
}
