//
//  UIViewController.swift
//  ArtemiyLiveWallpapers
//
//  Created by Artem Kuprijanets on 1/26/20.
//  Copyright © 2020 Artem Kuprijanets. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  
  var isModallyPresented: Bool {
    
    let presentingIsModal = presentingViewController != nil
    let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
    let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
    
    return presentingIsModal || presentingIsNavigation || presentingIsTabBar
  }
  
  func dismissCurVC(animated: Bool = true) {
    dismiss(animated: animated, completion: nil)
  }
  
  func popCurrentVC(animated: Bool = true) {
    navigationController?.popViewController(animated: animated)
  }
  
  @objc func quitCurrentVC(_ animated: Bool = true) {
    if self.isModallyPresented {
      self.navigationController?.dismiss(animated: true, completion: nil)
    } else {
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  func quitCurrentVC(
    toRoot: Bool = false,
    animated: Bool = true,
    with completion: @escaping () -> Void) {
    if isModallyPresented {
      navigationController?.dismiss(animated: true, completion: completion)
    } else {
      popCurVC(toRoot: toRoot, with: completion)
    }
  }
  
  func popCurVC(
    toRoot: Bool,
    animated: Bool = true,
    with completion: @escaping () -> Void) {
    
    execCATransaction(animation: {
      
      if toRoot {
        self.navigationController?.popToRootViewController(animated: animated)
      } else {
        self.navigationController?.popViewController(animated: animated)
      }
    }, completion: completion)
  }
  
  func execCATransaction(
    animation: @escaping ()-> Void,
    completion: @escaping ()-> Void) {
    
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    animation()
    CATransaction.commit()
  }
}
