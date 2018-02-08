//
//  ViewController.swift
//  DCLABO
//
//  Created by 米田大貴 on 2017/09/24.
//  Copyright © 2017年 DCreates. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class LaboController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var pj: UIButton!
    @IBOutlet weak var beacon: UIButton!
    
//    AIRCON
    @IBOutlet weak var aircon: UIButton!
    @IBOutlet weak var ac_tmp: UILabel!
    @IBOutlet weak var ac_view: UIView!
    
    
//    LIGHT
    @IBOutlet weak var li_single: UIButton!
    @IBOutlet weak var li_double: UIButton!
    @IBOutlet weak var li_view: UIView!
    @IBOutlet weak var slider: UISlider!
    
//    SPEAKER
    @IBOutlet weak var speaker: UIButton!
    @IBOutlet weak var sp_view: UIView!
    @IBOutlet weak var value_label: UILabel!
    
    var button_state:[String:Int] = [:]
    
//    UUIDからNSUUIDを作成
    var locationManager: CLLocationManager!
    let macBeaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!, identifier:"myBeacon")
    
//    cronのレスポンス用
    var result: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        importState()
//        print(button_state["light"])
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func slider(_ sender: UISlider) {
//        
        var slider_value = Int(floor((sender.value * 100)))
        self.value_label.text = String(slider_value)
        print(slider_value)
    }
    
    @IBAction func pj(_ sender: Any) {
//        self.pj.backgroundColor = UIColor.red
    }
    
    @IBAction func cron(_ sender: UIButton) {
//        var now_cron: NSString = ""
//        now_cron = throwServer(device: "cron", toGo: "myhome", h: "nil", m: "nil", isAdd: "nil", isAfter: "nil")
//        
//        let alert: UIAlertController = UIAlertController(title:"NowCronSettings", message: self.result, preferredStyle: UIAlertControllerStyle.alert)
//        let defaultAction: UIAlertAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.default, handler:{
//            (action: UIAlertAction!) -> Void in
//            print("OK")
//        })
//        alert.addAction(defaultAction)
//        present(alert, animated: true, completion: nil)
        throwServer(device: "dr", toGo: "myhome", h: "nil", m: "nil", isAdd: "nil", isAfter: "nil")
        
        
    }
    
    @IBAction func aircon(_ sender: Any) {
        throwServer(device: "aircon", toGo: "myhome", h:"nil", m:"nil",isAdd:"nil",isAfter:"nil")
        importState()
    }
    
    @IBAction func change_tmp(_ sender: Any) {
        print("Hello")
    }
    

    @IBAction func light_single(_ sender: Any) {
        throwServer(device: "li-single", toGo: "myhome", h:"nil", m:"nil",isAdd:"nil",isAfter:"nil")
        importState()
    }
    
    @IBAction func light_double(_ sender: Any) {
        throwServer(device: "li-double", toGo: "myhome", h:"nil", m:"nil",isAdd:"nil",isAfter:"nil")
        importState()
    }
    
    @IBAction func reload(_ sender: Any) {
        importState()
    }
    
    
    
    
    func throwServer(device: String, toGo:String, h:String, m:String, isAdd:String, isAfter:String) -> NSString {
        var result:NSString = " "
        var urlString = " "
        
        let status = Reach().connectionStatus()
//        経路設計
        switch (status){
        case .online(.wiFi):
            urlString = "http://192.168.1.10:10080/"
        case .online(.wwan):
            urlString = "http://118.241.146.6:10080/"
        default:
            print("ERROR")
            
        }
        
        
        if toGo == "myhome"{
            urlString = urlString + "myhome?_t&device=" + device
        }else if toGo == "cron"{
//            http://192.168.1.10:10080/cron?_t&device=wakeup&cron_min=20&cron_hou=08&after_time=1&add_cron=1
//            http://192.168.1.10:10080/cron?_tdevice=wakeup&cron_min=01&cron_hou=22&after_time=1&add_cron=0
            urlString = urlString + "cron?_t&device=" + device + "&cron_min=" + m + "&cron_hou=" + h + "&after_time=" + isAfter + "&add_cron=" + isAdd
            
        }
        
        print(urlString)
        
        let config  = URLSessionConfiguration.default;
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main);
        let request = URLRequest(url: URL(string: urlString)!);
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            if ((error) == nil) {
//                self.result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
//                print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
                
                self.result = String(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
                print(self.result)
                
            } else {
                print("AsyncGetHttpRequest:Error");
            }
        };
        
        task.resume();
        return result
    }
    
    
//    CClocationManagerデリゲート　実装
//    
    // 認証状況の取得
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            startMonitoring(macBeaconRegion)
        }
    }
    
    // beaconの計測ごとに呼ばれる
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("beacons=\(beacons)")
        if !beacons.isEmpty {
            let beacon = beacons[0]
            updateDistance(beacon.proximity)
        } else {
            updateDistance(.unknown)
            //manager.stopRangingBeaconsInRegion(region)
        }
    }
    
    func startMonitoring(_ beaconRegion: CLBeaconRegion) {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            locationManager.startMonitoring(for: beaconRegion)
        }
    }
    
    func startRanging(_ beaconRegion: CLBeaconRegion) {
        if CLLocationManager.isRangingAvailable() {
            locationManager.startRangingBeacons(in: beaconRegion)
        }
    }
    
    func updateDistance(_ distance: CLProximity) {
        switch distance {
        case .unknown:
            print("distance:unknown")
//            self.view.backgroundColor = UIColor.gray
            self.beacon.backgroundColor = UIColor.white
            self.beacon.alpha = 0.6
            
        case .far:
            print("distance:far")
//            self.view.backgroundColor = UIColor.blue
            self.beacon.backgroundColor = UIColor.white
            self.beacon.alpha = 0.8
            
        case .near:
            print("distance:near")
//            self.view.backgroundColor = UIColor.orange
            self.beacon.backgroundColor = UIColor.white
            
            
        case .immediate:
            print("distance:immediate")
//            self.view.backgroundColor = UIColor.red
            self.beacon.backgroundColor = UIColor.white
        }
    }
    
    // モニタリング開始直後
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // 現在自分がどのような状況にいるのか、知らせる(didDetermineStateを呼ぶ)よう要求
        manager.requestState(for: region)
        print("start scanning")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // 距離測定を開始
        if region.isMember(of: CLBeaconRegion.self) {
            startRanging(region as! CLBeaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for inRegion: CLRegion) {
        switch(state) {
        case .inside:
            print("inside")
            // 距離測定を開始
            if inRegion.isMember(of: CLBeaconRegion.self) {
                startRanging(inRegion as! CLBeaconRegion)
            }
        case .outside:
            print("outside")
        case .unknown:
            print("unknown")
        }
    }
    
    
//    Wends01のstate.jsonを取り込む
    func importState(){
        var urlString = " "
        
        let status = Reach().connectionStatus()
        //        経路設計
        switch (status){
        case .online(.wiFi):
            urlString = "http://192.168.1.10:10080/myhome?_t&device=state"
        case .online(.wwan):
            urlString = "http://118.241.146.6:10080/myhome?_t&device=state"
        default:
            print("ERROR")
            
        }
//        print(urlString)
        
        var import_data:Data = Data()
        
        let config  = URLSessionConfiguration.default;
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main);
        let request = URLRequest(url: URL(string: urlString)!);
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            if ((error) == nil) {
//                print(data)
//                var import_data = data!
//                print(String(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!))
                
                self.JsonToDict(importData: data!)
//                print(import_data)
                
            } else {
                print("AsyncGetHttpRequest:Error");
            }
        };
        
        task.resume();
    }
    
    func JsonToDict(importData:Data){
        //        JSON文字列をDictionaryにする。
        do{
            self.button_state = try JSONSerialization.jsonObject(with: importData, options: []) as! [String:Int]
            for element in self.button_state {
//                print("\(element)")
            }
        }catch{
            print(error.localizedDescription)
        }
        
        print(self.button_state)
        colorChange()
    }
    
    func colorChange(){
        print("HELLO")
        for (key,val) in self.button_state{
            print("キー:\(key), 値:\(val)")
            
            switch(key){
            case "aircon":
                if val == 1{
                    self.aircon.alpha = 1
                    self.ac_tmp.alpha = 1
                    self.ac_view.alpha = 1
                }else{
                    self.aircon.alpha = 0.6
                    self.ac_tmp.alpha = 0.6
                    self.ac_view.alpha = 0.6
//                    self.ac_tmp.value(forKey: "℃")
                }
                break
            case "aircon_tmp":
                self.ac_tmp.text = String(val) + " ℃"
            case "light":
                if val == 0{
                    self.li_single.alpha = 0.6
                    self.li_double.alpha = 0.6
                    self.li_view.alpha = 0.6
                }else if val == 1{
                    self.li_single.alpha = 0.8
                    self.li_double.alpha = 0.8
                    self.li_view.alpha = 0.85
                }else if val == 2{
                    self.li_single.alpha = 1
                    self.li_double.alpha = 1
                    self.li_view.alpha = 1
                }
                break;
                
            case "pj":
                if val > 0{
                    print("pj is gone")
                }
            case "speaker":
                if val == 1{
                    self.speaker.alpha = 1
                    self.sp_view.alpha = 1
                    
                }else if val == 0{
                    self.speaker.alpha = 0.6
                    self.sp_view.alpha = 0.6
                }
            case "volume":
                self.value_label.text = String(val)
                self.slider.value = (Float(val / 100))
            default:
                break;
            }
        }
    }
}
