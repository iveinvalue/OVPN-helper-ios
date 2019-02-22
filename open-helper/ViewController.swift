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

var info_data = ["", "", "", "", "", "", ""]
var ad = 0

class ViewController: UITableViewController {

    var fin : Results<vpn_data>? = nil
    var bannerView: GADBannerView!
    
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
                        ad = 1
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

        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-0355430122346055/2046107822"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
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
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //print("section: \(indexPath.section)")
        print("row: \(indexPath.row)")

        //click = indexPath.row

        info_data[0] = fin![indexPath.row].title
        info_data[1] = fin![indexPath.row].name
        info_data[2] = fin![indexPath.row].speed.description
        info_data[3] = fin![indexPath.row].session.description
        info_data[4] = fin![indexPath.row].ping.description
        info_data[5] = fin![indexPath.row].flag
        info_data[6] = fin![indexPath.row].open
        
        let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "InfoController") as! InfoController
        self.navigationController?.pushViewController(ViewController, animated: true)
        
    }
    
    //광고 위치
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    
}
