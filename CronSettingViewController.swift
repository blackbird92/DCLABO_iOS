//
//  cron_settingViewController.swift
//  DCLABO
//
//  Created by 米田大貴 on 2017/09/30.
//  Copyright © 2017年 DCreates. All rights reserved.
//

import UIKit


class CronSettingViewController: UIViewController {
    var device:String = ""
    var hou:String = ""
    var min:String = ""
    
//    基本的には追加
    var isAdd:String = "1"
//    基本的にはこの時間に
    var isAfter:String = "1"
    
    var selected_Hour:String = ""
    var selected_Min:String = ""
    
    @IBOutlet weak var aircon_button: UIButton!
    @IBOutlet weak var light_button: UIButton!
    @IBOutlet weak var wakeup_button: UIButton!
    
    @IBOutlet weak var cron_state: UITextView!
    @IBOutlet weak var nowCronSettings: UITextView!
    
    let vc:LaboController = LaboController()
    var result:NSString = " "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        importState()
        
//        let result:NSString = self.vc.throwServer(device: "cron", toGo: "myhome", h:"nil",m:"nil",isAdd:"nil",isAfter:"nil")
//        self.nowCronSettings.text = result as String!
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    セレクター
    @IBAction func is_after(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            isAfter = "1"
            print("this time")
        case 1:
            isAfter = "0"
            print("this time afeter")
        default:
            print("this time")
        }
    }
    
    
    @IBAction func is_add(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            isAdd = "1"
            print("ADD")
        case 1:
            isAdd = "0"
            print("NEW")
        default:
            print("ADD")
        }
    }
    
//    セレクターここまで
    
    
//    デバイスの選択
    @IBAction func aircon(_ sender: Any) {
        device = "aircon"
        self.aircon_button.alpha = 1
        
//        それ以外を排除 ここダルい)
        self.light_button.alpha = 0.6
        self.wakeup_button.alpha = 0.6
        
        
    }
    
    @IBAction func light(_ sender: Any) {
        device = "light"
        self.light_button.alpha = 1
        
//        それ以外を排除 ここダルい)
        self.aircon_button.alpha = 0.6
        self.wakeup_button.alpha = 0.6
    }
    
    @IBAction func wakeup(_ sender: Any) {
        device = "wakeup"
        self.wakeup_button.alpha = 1
        
//        それ以外を排除 ここダルい)
        self.aircon_button.alpha = 0.6
        self.light_button.alpha = 0.6
    }

//    デバイスの選択　ここまで
    

//    デートピッカー
    @IBAction func date_picker(_ sender: UIDatePicker) {
        let df_h = DateFormatter()
        let df_m = DateFormatter()
        
        df_h.dateFormat = "HH"
        df_m.dateFormat = "mm"
        
        self.selected_Hour = df_h.string(from: sender.date)
        self.selected_Min = df_m.string(from: sender.date)
        
        print(selected_Hour + " : " + selected_Min)
    }
    
    
//    サブミット
    @IBAction func submit(_ sender: Any) {
//        これで閉じられる
//        self.dismiss(animated: true, completion: nil)
        
        
//        こうやって別ファイルの関数を呼び出すっぽい。
//        let vc:ViewController = ViewController()
//        vc.hello()
        
        if device != ""{
            vc.throwServer(device: self.device, toGo: "cron", h: self.selected_Hour, m: self.selected_Min, isAdd: self.isAdd, isAfter: self.isAfter)
        }else{
            print("Oh! Device is  ")
        }
        
        importState()
    }
    
    @IBAction func clear(_ sender: Any) {
        vc.throwServer(device: "clear", toGo: "myhome", h:"nil", m:"nil",isAdd:"nil",isAfter:"nil")
        
        importState()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated:true, completion:nil)
    }
    
    @IBAction func reload(_ sender: Any) {
        importState()
    }
    
    
    //    クローン読み込み
    func importState(){
        var urlString = " "
        
        let status = Reach().connectionStatus()
        //        経路設計
        switch (status){
        case .online(.wiFi):
            urlString = "http://192.168.1.10:10080/myhome?_t&device=cron_state"
        case .online(.wwan):
            urlString = "http://118.241.146.6:10080/myhome?_t&device=cron_state"
        default:
            print("ERROR")
            
        }
        
        let config  = URLSessionConfiguration.default;
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main);
        let request = URLRequest(url: URL(string: urlString)!);
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            if ((error) == nil) {
                self.cron_state.text = String(data: data!, encoding: .utf8)!
            } else {
                print("AsyncGetHttpRequest:Error");
            }
        };
        
        task.resume();
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

