//
//  view_info.swift
//  open-helper
//
//  Created by USER on 22/02/2019.
//  Copyright © 2019 jungho. All rights reserved.
//

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
import GoogleMobileAds

class InfoController: UITableViewController , UIDocumentInteractionControllerDelegate ,GADRewardBasedVideoAdDelegate , GADInterstitialDelegate  {
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet var _1: UILabel!
    @IBOutlet var _2: UILabel!
    @IBOutlet var _3: UILabel!
    @IBOutlet var _4: UILabel!
    @IBOutlet var _5: UILabel!
    @IBOutlet var _6: UILabel!
    
    var click = -1
    var rewardBasedVideo: GADRewardBasedVideoAd?
    var interstitial: GADInterstitial!
    var coin = 0
    var code = "ca-app-pub-0355430122346055/2142589367"//"ca-app-pub-3940256099942544/1712485313"
    var code2 = "ca-app-pub-0355430122346055/7989866313"
    var docController:UIDocumentInteractionController!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    override func viewWillAppear(_ animated: Bool){
        self.title = "INFO"
        self.navigationController?.navigationBar.topItem?.title = " "
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section) row: \(indexPath.row)")
        if indexPath.section == 0 && indexPath.row == 0 {
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideo?.delegate = self
        rewardBasedVideo?.load(GADRequest(),
                               withAdUnitID: code)
        
        interstitial = GADInterstitial(adUnitID: code2)
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        
        tableview.dataSource = self
        tableview.delegate = self
        
        _1.text = info_data[0]
        _2.text = info_data[1]
        _3.text = info_data[2]
        _4.text = info_data[3]
        _5.text = info_data[4]
        _6.text = info_data[5]
        
        let button2 = UIButton.init(type: .custom)
        button2.setImage(UIImage.init(named: "share"), for: UIControlState.normal)
        button2.addTarget(self, action:#selector(go_popup), for:.touchUpInside)
        button2.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButton2 = UIBarButtonItem.init(customView: button2)
        self.navigationItem.rightBarButtonItem = barButton2
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
    
    @objc func go_popup(_ button:UIBarButtonItem!){
        if(ad == 1){
            if rewardBasedVideo?.isReady == true {
                rewardBasedVideo?.present(fromRootViewController: self)
            }else{
                print("video fail")
                if (coin == 2){
                    if interstitial.isReady {
                        interstitial.present(fromRootViewController: self)
                    }else{
                        popup_go()
                    }
                }
                else if (coin == 3){
                    popup_go()
                }else{
                    popup_go()
                }
            }
        }else{
            popup_go()
        }
    }
    
    private func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    private func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController) {
        docController = nil
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        
        coin = 1
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
        
        
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
        
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad has completed.")
        coin = 0
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        rewardBasedVideo?.load(GADRequest(),withAdUnitID: code)
        if (coin == 1){
            coin = 0
            popup_go()
        }
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
        coin = 2
    }
    
    func popup_go(){
        let file = info_data[1] + ".ovpn"
        //print(file)
        let myData = info_data[6].data(using: String.Encoding.utf8)!
        let resultData = NSData(base64Encoded: myData, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
        
        let resultNSString = NSString(data: resultData as Data, encoding: String.Encoding.utf8.rawValue)!
        let resultString = resultNSString as String
        
        let text = resultString
        //print(resultString)
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            //writing
            do {
                try text.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            catch {}
            
            let fileManager2 = FileManager.default
            let docsurl = try! fileManager2.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destinationFileUrl = docsurl.appendingPathComponent(file)
            if fileManager2.fileExists(atPath: destinationFileUrl.path){
                docController = UIDocumentInteractionController(url: destinationFileUrl)
                docController.name = NSURL(fileURLWithPath: destinationFileUrl.path).lastPathComponent
                docController.delegate = self as? UIDocumentInteractionControllerDelegate
                docController.presentPreview(animated: true)
                docController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
            }
            else {
                print("document was not found")
            }
            /*
             //reading
             do {
             let text2 = try String(contentsOf: fileURL, encoding: .utf8)
             print(text2)
             }
             catch {/* error handling here */}*/
        }
    }
    
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        coin = 3
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        interstitial = GADInterstitial(adUnitID: code2)
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        popup_go()
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}



