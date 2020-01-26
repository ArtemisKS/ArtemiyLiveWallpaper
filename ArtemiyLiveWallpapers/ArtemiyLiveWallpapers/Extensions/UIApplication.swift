//
//  UIApplication.swift
//  ArtemiyLiveWallpapers
//
//  Created by Artem Kuprijanets on 1/26/20.
//  Copyright © 2020 Artem Kuprijanets. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
  
  class func topViewController(controller: UIViewController? = shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
      return topViewController(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
      if let selected = tabController.selectedViewController {
        return topViewController(controller: selected)
      }
    }
    if let presented = controller?.presentedViewController {
      return topViewController(controller: presented)
    }
    return controller
  }
}
