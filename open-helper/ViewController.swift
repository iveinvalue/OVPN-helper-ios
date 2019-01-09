//
//  ViewController.swift
//  open-helper
//
//  Created by User on 2018. 8. 28..
//  Copyright © 2018년 jungho. All rights reserved.
//

import UIKit
//import Realm
import RealmSwift
import PKHUD
import ZAlertView
import GoogleMobileAds

class list_cell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var detail2: UILabel!
    @IBOutlet weak var detail3: UILabel!
    @IBOutlet weak var flag: UILabel!
}


class vpn_data : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var speed : Int = 0
    @objc dynamic var ping : Int = 0
    @objc dynamic var country : String = ""
    @objc dynamic var session : Int = 0
    @objc dynamic var flag : String = ""
    @objc dynamic var open : String = ""
    @objc dynamic var name : String = ""
}


class ViewController: UITableViewController, UIDocumentInteractionControllerDelegate ,GADRewardBasedVideoAdDelegate , GADInterstitialDelegate  {
    
    var ad = 0
    var docController:UIDocumentInteractionController!
    var fin : Results<vpn_data>? = nil
    var click = -1
    var rewardBasedVideo: GADRewardBasedVideoAd?
    var interstitial: GADInterstitial!
    var coin = 0
    var code = "ca-app-pub-0355430122346055/2142589367"//"ca-app-pub-3940256099942544/1712485313"
    var code2 = "ca-app-pub-0355430122346055/7989866313"
    
    @objc func go_setting(_ button:UIBarButtonItem!){
        let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingController") as! SettingController
        self.navigationController?.pushViewController(ViewController, animated: true)
    }
    @objc func sort(_ button:UIBarButtonItem!){
        let dialog = ZAlertView(title: nil, message: nil, alertType: ZAlertView.AlertType.multipleChoice)
        dialog.addButton("Speed", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            self.sort_refresh(sort: "speed")
        })
        dialog.addButton("Country", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            self.sort_refresh(sort: "country")
        })
        dialog.addButton("Ping", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            self.sort_refresh(sort: "ping")
        })
        dialog.addButton("Session", hexColor: "#EFEFEF", hexTitleColor: "#999999", touchHandler: { alertView in
            alertView.dismissAlertView()
            self.sort_refresh(sort: "session")
        })
        dialog.show()
    }
    
    func addData(title: String,speed: Int,ping: Int,country: String,session: Int,flag: String,open: String,name: String) {
        let v_data = vpn_data()
        v_data.title = title
        v_data.speed = speed
        v_data.ping = ping
        v_data.country = country
        v_data.session = session
        v_data.flag = flag
        v_data.open = open
        v_data.name = name
        let realm = try! Realm()
        try! realm.write {
            realm.add(v_data)
        }
        //print("success")
    }
    
    @IBOutlet var main_table: UITableView!
    
    func refresh(sort: String){
        
        DispatchQueue.main.async {
            HUD.show(.label("Loading..."))
        }
        
        let url2 = URL(string: "https://www.vpngate.net/api/iphone/")
        let taskk = URLSession.shared.dataTask(with: url2! as URL) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
            let text = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
            //print(text)
            print("load done")
            
            if text.contains("*vpn_servers"){
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()
                }

                var tmp = text.components(separatedBy: "\n")
                let cnt = tmp.count
                for i in 2...cnt - 3 {
                    let tmp2 = tmp[i]
                    var tmp3 = tmp2.components(separatedBy: ",")
                    if (tmp3[3].contains("-")){
                        tmp3[3] = "0"
                    }
                    self.addData(title: tmp3[1],
                                 speed: Int(self.change_mb(str: tmp2.components(separatedBy: ",")[4]))!,
                                 ping: Int(tmp3[3])!,
                                 country: tmp3[6],
                                 session: Int(tmp3[7])!,
                                 flag: self.flag(country: tmp3[6]),
                                 open: tmp3[14],
                                 name: tmp3[0])
                }
                
                let url3 = URL(string: "https://raw.githubusercontent.com/iveinvalue/open_vpn/master/set")
                let taskk2 = URLSession.shared.dataTask(with: url3! as URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    //print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
                    let text2 = NSString(data: data, encoding: String.Encoding.ascii.rawValue)! as String
                    print(text2)
                    if(text2.contains("ad")){
                        self.ad = 1
                    }
                    DispatchQueue.main.async {
                        self.sort_refresh(sort: sort)
                        HUD.flash(.success, delay: 0.5)
                    }
                }
                taskk2.resume()
            
                
            }else{
                DispatchQueue.main.async {
                    HUD.show(.label("ERROR"))
                }
            }
        }
        taskk.resume()
    }
    
    func sort_refresh(sort:String){
        let realm = try! Realm()
        self.fin = realm.objects(vpn_data.self).sorted(byKeyPath: sort, ascending: false)
        self.main_table.reloadData()
        self.main_table.dataSource = self
        self.main_table.delegate = self
    }
    
    func change_mb(str: String) -> String {
        var result = Int(str);
        result = result! / 1000000
        return result!.description;
    }
    
    func flag(country:String) -> String {
        let base = 127397
        var usv = String.UnicodeScalarView()
        for i in country.utf16 {
            usv.append(UnicodeScalar(base + Int(i))!)
        }
        return String(usv)
    }
    
    override func viewWillAppear(_ animated: Bool){
        self.title = "OVPN Files"
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
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.title = "Setting"
        
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "sort.png"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(sort), for:.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        let button2 = UIButton.init(type: .custom)
        button2.setImage(UIImage.init(named: "setting"), for: UIControlState.normal)
        button2.addTarget(self, action:#selector(go_setting), for:.touchUpInside)
        button2.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButton2 = UIBarButtonItem.init(customView: button2)
        self.navigationItem.rightBarButtonItem = barButton2

        refresh(sort: "speed")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (fin != nil){
            return fin!.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = main_table.dequeueReusableCell(withIdentifier: "list_cell", for: indexPath) as! list_cell
        if (fin != nil){
            cell.detail2.layer.cornerRadius = 2
            cell.detail2.layer.masksToBounds = true
            
            cell.title.text = fin![indexPath.row].title
            cell.detail.text = fin![indexPath.row].name
            cell.detail2.text = "  " + fin![indexPath.row].speed.description + " Mbps  "
            cell.detail3.text = "Session: " + fin![indexPath.row].session.description +
                " / Ping: " + fin![indexPath.row].ping.description
            cell.flag.text = fin![indexPath.row].flag
        }
        return cell
    }
    
    private func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    private func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController) {
        docController = nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //print("section: \(indexPath.section)")
        print("row: \(indexPath.row)")

        click = indexPath.row
        
        if(self.ad == 1){
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
                    //popup_go()
                }
            }
        }else{
            popup_go()
        }
        
        
        
        
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
        let file = fin![click].name + ".ovpn"
        //print(file)
        let myData = fin![click].open.data(using: String.Encoding.utf8)!
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
