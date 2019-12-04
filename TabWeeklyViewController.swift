//
//  TabWeeklyViewController.swift
//  Weather
//
//  Created by Ouyu Lan on 12/1/19.
//  Copyright © 2019 Ouyu Lan. All rights reserved.
//

import UIKit
import Charts

class TabWeeklyViewController: UIViewController {

    @IBOutlet weak var sumView: UIView!
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var LabelSum: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
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
        print("load tab weekly view controller")
        
        // sum part
        sumView?.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
        sumView?.layer.cornerRadius = 12;
        sumView?.layer.masksToBounds = true;
        sumView?.layer.borderWidth = 1;
        sumView?.layer.borderColor = CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        LabelSum.text = info["summary"] as? String
        iconImgView.image = UIImage(named: self.iconImg[info["icon"] as! String] ?? "weather-sunny")
        
        // chart part
        chartView?.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        chartView?.layer.masksToBounds = true;
        chartView?.layer.borderWidth = 0.5;
        chartView?.layer.borderColor = CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        var lowTempData = [ChartDataEntry]()
        var highTempData = [ChartDataEntry]()
        let data = info["data"] as! [[String: Any]]
        for i in 0 ..< data.count {
            lowTempData.append(ChartDataEntry(
                x: Double(i),
                y: data[i]["temperatureLow"] as! Double))
            highTempData.append(ChartDataEntry(
                x: Double(i),
                y: data[i]["temperatureHigh"] as! Double))
        }
        let chartData = LineChartData()
        let lowTempDataSet = LineChartDataSet(entries: lowTempData, label: "Minimum Temperature (°F)")
        lowTempDataSet.colors = [NSUIColor.white]
        lowTempDataSet.circleHoleColor = NSUIColor.white
        lowTempDataSet.circleColors = [NSUIColor.white]
        lowTempDataSet.circleRadius = 4.0
        let highTempDataSet = LineChartDataSet(entries: highTempData, label: "Maximum Temperature (°F)")
        highTempDataSet.colors = [NSUIColor.orange]
        highTempDataSet.circleColors = [NSUIColor.orange]
        highTempDataSet.circleHoleColor = NSUIColor.orange
        highTempDataSet.circleRadius = 4.0
        chartData.addDataSet(lowTempDataSet)
        chartData.addDataSet(highTempDataSet)
        chartView.data = chartData
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
