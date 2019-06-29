//
//  Common.swift
//  HeartRateMonitor
//
//  Created by ijaz ahmad on 2019-06-28.
//  Copyright © 2019 BodiTrak. All rights reserved.
//

import Foundation
import UIKit

class  Common {
    class func showErrorMessage(view: UIView, errorMessage: String) {
        let screenSize: CGRect = UIScreen.main.bounds
        let label = UILabel(frame: CGRect(x: 0, y: screenSize.height-100, width: screenSize.width, height: 60))
        label.backgroundColor = UIColor.red
        label.text = errorMessage
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.numberOfLines = 0
        view.addSubview(label)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            label.removeFromSuperview()
        })
    }
    
    class func showSuccessMessage(view: UIView, successMessage: String) {
        let screenSize: CGRect = UIScreen.main.bounds
        let label = UILabel(frame: CGRect(x: 0, y: screenSize.height-100, width: screenSize.width, height: 60))
        label.backgroundColor = UIColor.init(red: 0/255.0, green: 75/255.0, blue: 0/255.0, alpha: 1.0)
        label.text = successMessage
        label.textAlignment = .center
        label.textColor = UIColor.white
        view.addSubview(label)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            label.removeFromSuperview()
        })
    }
}
