//
//  TabBarViewController.swift
//  Weather
//
//  Created by Ouyu Lan on 12/1/19.
//  Copyright © 2019 Ouyu Lan. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    @IBAction func twitterBtnActTab(_ sender: Any) {
        print("twitter called")
        var text = "https://twitter.com/intent/tweet?text="
        text += "The%20current%20temperature%20at%20"
        text += (self.currentInfo["city"] ?? "") + "%20is%20"
        text += (self.currentInfo["temperature"] ?? "") + "%C2%BAF.%20The%20weather%20condition%20is%20"
        text += (self.currentInfo["summary"] ?? "") + ".&hashtags=CSCI571WeatherSearch"
        text = text.replacingOccurrences(of: " ", with: "%20")
        
        guard let url = URL(string: text)
            else {
                print("error:: failed to generate url from " + text)
                return
        }
        print("twitter url:", url)
        UIApplication.shared.open(url)
    }
    
    var currentInfo: [String: String] = [:]
    var tabTodayData: [String: Any] = [:]
    var tabWeeklyData: [String: Any] = [:]
    var cityName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("load tab bar view controller")
        let tabToday = self.viewControllers?[0] as! TabTodayViewController
        let tabWeekly = self.viewControllers?[1] as! TabWeeklyViewController
        let tabPhoto = self.viewControllers?[2] as! TabPhotosViewController
        tabToday.info = self.tabTodayData
        tabWeekly.info = self.tabWeeklyData
        tabPhoto.cityName = self.cityName
        
        self.title = self.cityName
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
