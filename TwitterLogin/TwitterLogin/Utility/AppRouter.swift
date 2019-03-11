//
//  Router.swift
//  FirebaseChatDemo
//
//  Created by Bhavneet Singh on 29/07/18.
//  Copyright © 2018 Bhavneet Singh. All rights reserved.
//

import UIKit

enum AppRouter {
    
    static func goToDetailVC() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = sb.instantiateViewController(withIdentifier: "DetailViewC")
        let nvc = UINavigationController(rootViewController: detailVC)
        UIView.transition(with: AppDelegate.shared.window!, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController = nvc
        }, completion: nil)
    }
}
