//
//  SearchResultViewController.swift
//  Weather
//
//  Created by Ouyu Lan on 11/30/19.
//  Copyright © 2019 Ouyu Lan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner

class SearchResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FavoriteDelegate {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.card.dailyTableViewCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DailyWeatherTableViewCellId", for: indexPath) as! DailyWeatherTableViewCell
        cell.iconImg.image = UIImage(named: self.card.dailyTableViewCells[indexPath.row]["icon"] as! String)
        cell.dateLabel.text = (self.card.dailyTableViewCells[indexPath.row]["date"] as! String)
        cell.sunriseLabel.text = (self.card.dailyTableViewCells[indexPath.row]["sunrise"] as! String)
        cell.sunsetLabel.text = (self.card.dailyTableViewCells[indexPath.row]["sunset"] as! String)
        cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
        return cell
        
        
    }
    

    @IBOutlet var searchResultView: UIView!
    @IBAction func twitterBtn(_ sender: Any) {
        print("twitter called")
        var text = "https://twitter.com/intent/tweet?text="
        text += "The%20current%20temperature%20at%20"
        text += (self.card.currentInfo["city"] ?? "") + "%20is%20"
        text += (self.card.currentInfo["temperature"] ?? "") + "%C2%BAF.%20The%20weather%20condition%20is%20"
        text += (self.card.currentInfo["summary"] ?? "") + ".&hashtags=CSCI571WeatherSearch"
        text = text.replacingOccurrences(of: " ", with: "%20")
        
        guard let url = URL(string: text)
            else {
                print("error:: (SearchResultViewController) failed to generate url from " + text)
                return
        }
        print("(SearchResultViewController) twitter url:", url)
        UIApplication.shared.open(url)
    }
    
    
    var searchInput = ""
    let iconImg = [
        "clear-day": "weather-sunny",
        "clear-night" : "weather-night",
        "rain" : "weather-rainy",
        "snow" : "weather-snowy",
        "sleet" : "weather-snowy-rainy",
        "wind" : "weather-windy-variant",
        "fog" : "weather-fog",
        "cloudy" : "weather-cloudy",
        "partly-cloudy-night" : "weather-night-partly-cloudy",
        "partly-cloudy-day" : "weather-partly-cloudy",
    ]
        var apiURL = "http://csci599-hw9.appspot.com"
//    var apiURL = "http://localhost:3000"
    var card: WeatherCard = WeatherCard()

    override func viewWillAppear(_ animated: Bool) {
        card.favoriteDelegate = self
    }
    
    func updateFav() {
        
        if card.favSelected {
            // currently selected, want to delete
            var iter = 1
            while iter < weatherCards.count{
                if weatherCards[iter].location == card.location {
                    weatherCards[iter].removeFromSuperview()
                    weatherCards.remove(at: iter)
                    break
                }
                iter += 1
            }
        } else {
            // currently not selected, want to add
            // update weatherCards
            let curCard = Bundle.main.loadNibNamed("WeatherCard", owner: self, options: nil)?.first as! WeatherCard
            curCard.location = card.location
            curCard.currentInfo = card.currentInfo
            curCard.dailyTableViewCells = card.dailyTableViewCells
            curCard.weatherInfoCurrent = card.weatherInfoCurrent
            curCard.weatherInfoDaily = card.weatherInfoDaily
            curCard.favSelected = true
            curCard.favOutlet.setImage(UIImage(named: "trash-can"), for: .normal)
            weatherCards.append(curCard)
            // update scroll view
            // update tableview in each weatherCards
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let city = self.searchInput.components(separatedBy: ", ")[0]
        SwiftSpinner.show("Fetching Weather Details for " + city)
        
        self.title = city
        
        
        // card
        card = Bundle.main.loadNibNamed("WeatherCard", owner: self, options: nil)?.first as! WeatherCard
        searchResultView.addSubview(card)
        
        card.location = searchInput

        card.translatesAutoresizingMaskIntoConstraints = true
        card.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        card.autoresizingMask = [UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin, UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleBottomMargin]
        
        card.trdSubView.dataSource = self
        card.trdSubView.delegate = self
        card.trdSubView.register(
            UINib(nibName: "DailyWeatherTableViewCell", bundle: nil),
            forCellReuseIdentifier: "DailyWeatherTableViewCellId")

        let tapOnCard = UITapGestureRecognizer(target: self, action: #selector(self.showDetails(_:)))
        card.firstSubView.addGestureRecognizer(tapOnCard)
        
        // if favorite
        let favListStr = UserDefaults.standard.string(forKey: "favList") ?? ""
        
        var favList = try? JSONDecoder().decode([String].self, from: favListStr.data(using: .utf8)!)
        if favList == nil {
            favList = []
        }
        if (favList?.contains(self.searchInput) ?? false) {
            card.favSelected = true
            card.favOutlet.setImage(UIImage(named: "trash-can"), for: .normal)
        }
        print("favorite: ", favList!)
        
        // get coordinate
        getCoordinate(info: searchInput)
    }
    
    @objc func showDetails(_ sender:UITapGestureRecognizer?=nil) {
        performSegue(withIdentifier: "showDetailSearch", sender: self)
    }
    
    func getCoordinate(info: String) {
        print("(SearchResultViewController) func getCoordinate for", info)
        let infoList = info.components(separatedBy: ", ")
        var city = ""
        var state = ""
        if (infoList.count == 0) {
            print("error:: (SearchResultViewController) failed to split", info)
        } else if (infoList.count <= 2) {
            city = infoList[0]
        } else {
            city = infoList[0]
            state = infoList[1]
        }
        guard let url = URL(string: apiURL + "/search/geocode") else {
            print("error:: (SearchResultViewController) failed to build url,", apiURL + "/search/geocode")
            return
        }
        print("url:", url)
        Alamofire.request(
        url,
        method: .get,
        parameters: ["city": city,
                     "state": state])
        .validate()
        .responseJSON { response in
            guard response.result.isSuccess else {
                print("error:: (SearchResultViewController) get weather response result not success")
                SwiftSpinner.hide()
                return
            }

            guard let value = response.result.value as? [String: Any] else {
                print("error:: (SearchResultViewController) get weather response result value not exist")
                SwiftSpinner.hide()
                return
            }
            
            let results = value["results"] as! [[String: Any]]
            let geometry = results[0]["geometry"] as! [String: Any]
            let location = geometry["location"] as! [String: Any]
            print("location", location)
            self.card.currentInfo["latitude"] = String(format: "%.6f", location["lat"] as! Double)
            self.card.currentInfo["longitude"] = String(format: "%.6f", location["lng"] as! Double)
            self.card.currentInfo["city"] = city
            self.card.firstSubViewLocLabel.text = self.card.currentInfo["city"]
        
            // get weather
            self.getWeather(lat: self.card.currentInfo["latitude"] ?? "0.0", lng: self.card.currentInfo["longitude"] ?? "0.0")
        }
    }
    
    func getWeather(lat: String, lng: String) {
        print("(SearchResultViewController) func getWeather for", self.card.currentInfo["city"]!, lat, lng)
        guard let url = URL(string: apiURL + "/search/weather") else {
            print("error:: (SearchResultViewController) failed to build url,", apiURL + "/search/weather")
            SwiftSpinner.hide()
            return
        }
        print("url:", url)
        Alamofire.request(
            url,
            method: .get,
            parameters: ["lat": lat,
                         "lng": lng])
        .validate()
        .responseJSON { response in
            guard response.result.isSuccess else {
                print("error:: (SearchResultViewController) get weather response result not success")
                SwiftSpinner.hide()
                return
            }

            guard let value = response.result.value as? [String: Any] else {
                print("error:: (SearchResultViewController) get weather response result value not exist")
                SwiftSpinner.hide()
                return
            }
            
            self.card.weatherInfoCurrent = value["currently"] as! [String: Any]
            self.card.weatherInfoDaily = value["daily"] as! [String: Any]
            self.setFirstSubviewValues(info: value["currently"] as? [String: Any])
            self.setSndSubviewValues(info: value["currently"] as? [String: Any])
            self.setTrdSubviewValues(info: value["daily"] as? [String: Any])
            
            SwiftSpinner.hide()
        }
    }
    
    func setFirstSubviewValues(info: [String:Any]?) {
        print("(SearchResultViewController) func setFirstSubviewValues")
        self.card.firstSubViewTempLabel.text = String(format:"%.0f", info?["temperature"] as! Double) + "°F"
        self.card.firstSubViewSumLabel.text = (info?["summary"] as! String)
        self.card.firstSubViewImg.image = UIImage(named: self.iconImg[info?["icon"] as! String] ?? "weather-sunny")
        
        self.card.currentInfo["temperature"] = String(format:"%.0f", info?["temperature"] as! Double)
        self.card.currentInfo["summary"] = (info?["summary"] as! String)
    }
    
    func setSndSubviewValues(info: [String:Any]?) {
        print("(SearchResultViewController) func setSndSubviewValues")
        self.card.sndSubViewHumLabel.text = String(format: "%.1f", round(info?["humidity"] as! Double * 100)) + " %"
        self.card.sndSubViewWindLabel.text = String(format: "%.2f", round(info?["windSpeed"] as! Double)) + " mph"
        self.card.sndSubViewVsbLabel.text = String(format: "%.2f", round(info?["visibility"] as! Double)) + " km"
        self.card.sndSubViewPrsLabel.text = String(format: "%.1f", round(info?["pressure"] as! Double)) + " mb"
    }
    
    func setTrdSubviewValues(info: [String:Any]?) {
        print("(SearchResultViewController) func setTrdSubviewValues")
        let data = info?["data"] as! [[String:Any]]
        self.card.dailyTableViewCells = []
        for i in 0 ... 7 {
            self.card.dailyTableViewCells.append([
                "date": convertTime(timestamp: data[i]["time"] as! TimeInterval, format: "MM/dd/yyyy"),
                "sunrise": convertTime(timestamp: data[i]["sunriseTime"] as! TimeInterval, format: "HH:mm"),
                "sunset": convertTime(timestamp: data[i]["sunsetTime"] as! TimeInterval, format: "HH:mm"),
                "icon": self.iconImg[data[i]["icon"] as! String] ?? "weather-sunny"
            ])
        }
        
        self.card.trdSubView.reloadData()
    }
    
    func convertTime(timestamp: TimeInterval, format: String) -> String{
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = format
        let returnDate = dateFormatter.string(from: date)
        return returnDate
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
         let dist = segue.destination as? TabBarViewController
        dist?.tabTodayData = self.card.weatherInfoCurrent
        dist?.tabWeeklyData = self.card.weatherInfoDaily
        dist?.cityName = self.card.currentInfo["city"] ?? "Los Angeles"
    }
    
}
