//
//  TabTodayViewController.swift
//  Weather
//
//  Created by Ouyu Lan on 12/1/19.
//  Copyright © 2019 Ouyu Lan. All rights reserved.
//

import UIKit

class TabTodayViewController: UIViewController {

    @IBOutlet weak var cubeView1: UIView!
    @IBOutlet weak var cubeView2: UIView!
    @IBOutlet weak var cubeView3: UIView!
    @IBOutlet weak var cubeView4: UIView!
    @IBOutlet weak var cubeView5: UIView!
    @IBOutlet weak var cubeView6: UIView!
    @IBOutlet weak var cubeView7: UIView!
    @IBOutlet weak var cubeView8: UIView!
    @IBOutlet weak var cubeView9: UIView!
    
    @IBOutlet weak var LabelWind: UILabel!
    @IBOutlet weak var LabelPres: UILabel!
    @IBOutlet weak var LabelPrec: UILabel!
    @IBOutlet weak var LabelTemp: UILabel!
    @IBOutlet weak var LabelSum: UILabel!
    @IBOutlet weak var LabelHumd: UILabel!
    @IBOutlet weak var LabelVisb: UILabel!
    @IBOutlet weak var LabelClod: UILabel!
    @IBOutlet weak var Labelozon: UILabel!
    
    @IBOutlet weak var ImgViewIcon: UIImageView!
    
    var info: [String: Any] = [:]
    let iconImg = [
        "clear-day": "weather-sunny",
        "clear-night" : "weather-night",
        "rain" : "weather-rainy",
        "sleet" : "weather-snowy-rainy",
        "snow" : "weather-snowy",
        "wind" : "weather-windy-variant",
        "fog" : "weather-fog",
        "cloudy" : "weather-cloudy",
        "partly-cloudy-night" : "weather-night-partly-cloudy",
        "partly-cloudy-day" : "weather-partly-cloudy",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // cubeView
        let cubeViews = [self.cubeView1, self.cubeView2, self.cubeView3,
                         self.cubeView4, self.cubeView5, self.cubeView6,
                         self.cubeView7, self.cubeView8, self.cubeView9]
        for cubeView in cubeViews {
            cubeView?.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
            cubeView?.layer.cornerRadius = 12;
            cubeView?.layer.masksToBounds = true;
            cubeView?.layer.borderWidth = 0.5;
            cubeView?.layer.borderColor = CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        // label
        print("load today tab with info\n", info)
        self.LabelWind.text = String(format: "%.2f", round(info["windSpeed"]  as! Double)) + " mph"
        self.LabelPres.text = String(format: "%.1f", round(info["pressure"]  as! Double)) + " mb"
        self.LabelPrec.text = String(format: "%.1f", round(info["precipIntensity"]  as! Double)) + " mmph"
        self.LabelTemp.text = String(format: "%.0f", round(info["temperature"]  as! Double)) + "°F"
        self.LabelHumd.text = String(format: "%.1f", round(info["humidity"]  as! Double * 100)) + " %"
        self.LabelVisb.text = String(format: "%.2f", round(info["visibility"]  as! Double)) + " km"
        self.LabelClod.text = String(format: "%.2f", round(info["cloudCover"]  as! Double * 100)) + " %"
        self.Labelozon.text = String(format: "%.1f", round(info["ozone"]  as! Double)) + " DU"
        
        // icon
        let icon = info["icon"] as! String
//        if icon == "partly-cloudy-day" {
//            self.LabelSum.text = "cloudy day"
//        } else if icon == "partly-cloudy-night" {
//            self.LabelSum.text = "cloudy night"
//        } else {
//            self.LabelSum.text = icon.replacingOccurrences(of: "-", with: " ", options: .literal, range: nil)
//        }
        self.LabelSum.text = info["summary"] as? String
        self.ImgViewIcon.image = UIImage(named: self.iconImg[icon] ?? "weather-sunny")
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
