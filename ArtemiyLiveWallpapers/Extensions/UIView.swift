//
//  UIView.swift
//  ArtemiyLiveWallpapers
//
//  Created by Artem Kuprijanets on 1/27/20.
//  Copyright © 2020 Artem Kuprijanets. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  
  var mainColor: UIColor {
    return hexStringToUIColor(hex: "#27164d")
  }
  
  private func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if cString.hasPrefix("#") {
      cString.remove(at: cString.startIndex)
    }
    
    if cString.count != 6 { return .gray }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
  
  func applyMainAppTheme( ){
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [
      hexStringToUIColor(hex: "#27164d").cgColor,
      hexStringToUIColor(hex: "#ed2282").cgColor]
    gradientLayer.frame = bounds
    layer.insertSublayer(gradientLayer, at: 0)
  }
}
