//
//  CustomAlertController.swift
//  ExchangeCalc
//
//  Created by admin on 2018. 7. 4..
//  Copyright © 2018년 masteroftravel. All rights reserved.
//

import UIKit

class CustomAlertController: UIAlertController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // 알림창 backgroundColor와 cornerRadius 설정
        let bgColor = UIColor.white
        let cornerRadius: CGFloat = 0
        let alpha: CGFloat = 1.0
        for first in self.view.subviews {
            first.backgroundColor = bgColor
            first.layer.cornerRadius = cornerRadius
            first.alpha = alpha
            for second in first.subviews {
                second.backgroundColor = bgColor
                second.layer.cornerRadius = cornerRadius
                second.alpha = alpha
                for third in second.subviews {
                    third.backgroundColor = bgColor
                    third.layer.cornerRadius = cornerRadius
                    third.alpha = alpha
                    for fourth in third.subviews {
                        fourth.backgroundColor = bgColor
                        fourth.layer.cornerRadius = cornerRadius
                        fourth.alpha = alpha
                    }
                }
            }
        }
    }
}
