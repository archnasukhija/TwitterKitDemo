//
//  ViewController.swift
//  TwitterLogin
//
//  Created by Admin on 10/03/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import TwitterKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func tapLoginTwitter(_ sender: UIButton) {
        self.loginToTwitter()
    }
    
    private func loginToTwitter() {
        TWTRTwitter.sharedInstance().logIn { [weak self] (session, error) in
            guard let self = self  else { return }
            if error != nil {
                self.showAlertWith(message: error!.localizedDescription)
                return
            }
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let detailVC = sb.instantiateViewController(withIdentifier: "DetailViewC")
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    private func showAlertWith(message: String) {
        let alertController = UIAlertController(title: nil, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
}

