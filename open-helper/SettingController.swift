//
//  SettingController.swift
//  open-helper
//
//  Created by User on 2018. 8. 30..
//  Copyright © 2018년 jungho. All rights reserved.
//

import UIKit
import Foundation
import ZAlertView

class SettingController: UITableViewController {
    
    @IBOutlet var tableview: UITableView!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    override func viewWillAppear(_ animated: Bool){
        self.title = "Setting"
        self.navigationController?.navigationBar.topItem?.title = " "
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section) row: \(indexPath.row)")

        if indexPath.section == 0 && indexPath.row == 0 {
            let dialog = ZAlertView(title: "OpenSource", message: "https://github.com/zelic91/ZAlertView\nhttps://github.com/pkluz/PKHUD\nhttps://github.com/realm/realm-cocoa", closeButtonText: "OK", closeButtonHandler: { alertView in alertView.dismissAlertView()
            })
            dialog.show()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            let dialog = ZAlertView(title: "Version", message: "1.0.1(2)", closeButtonText: "OK", closeButtonHandler: { alertView in alertView.dismissAlertView()
            })
            dialog.show()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.dataSource = self
        tableview.delegate = self
    }

    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}



