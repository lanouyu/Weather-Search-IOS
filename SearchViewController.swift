//
//  SearchViewController.swift
//  Weather
//
//  Created by Ouyu Lan on 11/30/19.
//  Copyright © 2019 Ouyu Lan. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire
import SwiftSpinner
import Toast_Swift

var weatherCards:[WeatherCard] = []

class SearchViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, FavoriteDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cityAutoTableView {
            return cityAutoList.count
        } else {
            for i in 0 ..< weatherCards.count {
                if (tableView == weatherCards[i].trdSubView) {
                    return weatherCards[i].dailyTableViewCells.count
                }
            }
        }
        print("error:: (SearchViewController) table view failed to return correct number")
        return cityAutoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == cityAutoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityAutoTableViewCellId", for: indexPath) as! CityAutoTableViewCell
            cell.cityLabel.text = cityAutoList[indexPath.row]
            cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
            return cell
        } else {
            for i in 0 ..< weatherCards.count {
                if (tableView == weatherCards[i].trdSubView) {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DailyWeatherTableViewCellId" + String(i), for: indexPath) as! DailyWeatherTableViewCell
                    if (weatherCards[i].dailyTableViewCells.count == 0) {
                        print("error:: (SearchViewController) weatherCards", i, "dailyTableViewCells is empty.")
                        break
                    }
                    cell.iconImg.image = UIImage(named: weatherCards[i].dailyTableViewCells[indexPath.row]["icon"] as! String)
                    cell.dateLabel.text = (weatherCards[i].dailyTableViewCells[indexPath.row]["date"] as! String)
                    cell.sunriseLabel.text = (weatherCards[i].dailyTableViewCells[indexPath.row]["sunrise"] as! String)
                    cell.sunsetLabel.text = (weatherCards[i].dailyTableViewCells[indexPath.row]["sunset"] as! String)
                    cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
                    return cell
                }
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityAutoTableViewCellId", for: indexPath) as! CityAutoTableViewCell
        cell.cityLabel.text = "error:: (SearchViewController) table view"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cityAutoTableView {
            tableView.deselectRow(at: indexPath, animated: true)
            self.selectedCity = cityAutoList[indexPath.row]
            print("select city:", self.selectedCity)
            performSegue(withIdentifier: "showSearchWeather", sender: self)
            tableView.isHidden = true
        }
        
    }
    

    @IBOutlet var searchBarInput: UISearchBar!
    @IBOutlet weak var weatherScrollView: UIScrollView!
    @IBOutlet weak var weatherPageControl: UIPageControl!
    @IBOutlet weak var cityAutoTableView: UITableView!
    
    // global variables
    var locationManager: CLLocationManager?
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
    var dailyTableViewCells:[[String: Any]] = []
    var cityAutoList:[String] = []{
       didSet {
          if cityAutoList.count > 0 {
            cityAutoTableView.isHidden = false
            cityAutoTableView.reloadData()
          } else {
             cityAutoTableView.isHidden = true
          }
       }
    }
    var selectedCity = ""

    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("(SearchViewController) func viewWillAppear")
        
        weatherPageControl.numberOfPages = weatherCards.count
        view.bringSubviewToFront(weatherPageControl)
        
        setupWeatherCards(cards: weatherCards)
        weatherPageControl.numberOfPages = weatherCards.count
        view.bringSubviewToFront(weatherPageControl)
        
        // daily weather table view
        for i in 0 ..< weatherCards.count {
            weatherCards[i].trdSubView.dataSource = self
            weatherCards[i].trdSubView.delegate = self
            weatherCards[i].trdSubView.register(
                UINib(nibName: "DailyWeatherTableViewCell", bundle: nil),
                forCellReuseIdentifier: "DailyWeatherTableViewCellId"+String(i))
            print("(SearchViewController) DailyWeatherTableViewCellId"+String(i))
            
            let tapOnCard = UITapGestureRecognizer(target: self, action: #selector(self.showDetails(_:)))
            weatherCards[i].firstSubView.addGestureRecognizer(tapOnCard)
        }
        
        // update favorite cards
        for i in 1 ..< weatherCards.count {
            let card = weatherCards[i]
            card.favoriteDelegate = self
            getCoordinate(card: card, info: card.location)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        SwiftSpinner.show("Loading...")
        
        // search bar
        let searchBarButton = UIBarButtonItem(customView: searchBarInput)
        self.navigationItem.leftBarButtonItem = searchBarButton
        let textFieldInsideSearchBar = searchBarInput.value(forKey: "searchField") as? UITextField
//        textFieldInsideSearchBar?.textColor = UIColor(red: 0.635, green: 0.635, blue: 0.635, alpha: 1)
        textFieldInsideSearchBar?.backgroundColor = UIColor.white
        
        // cards
        weatherScrollView.delegate = self
        weatherCards = createWeatherCards()
        setupWeatherCards(cards: weatherCards)
        weatherPageControl.numberOfPages = weatherCards.count
        weatherPageControl.currentPage = 0
        view.bringSubviewToFront(weatherPageControl)
        
        // location
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
        
        // daily weather table view
        for i in 0 ..< weatherCards.count {
            weatherCards[i].trdSubView.dataSource = self
            weatherCards[i].trdSubView.delegate = self
            weatherCards[i].trdSubView.register(
                UINib(nibName: "DailyWeatherTableViewCell", bundle: nil),
                forCellReuseIdentifier: "DailyWeatherTableViewCellId"+String(i))
            print("(SearchViewController) register DailyWeatherTableViewCellId"+String(i))
        }
        
        // city autocomplete
        searchBarInput.delegate = self
        cityAutoTableView.dataSource = self
        cityAutoTableView.delegate = self
        cityAutoTableView.register(
            UINib(nibName: "CityAutoTableViewCell", bundle: nil),
            forCellReuseIdentifier: "CityAutoTableViewCellId")
        cityAutoTableView.isHidden = true
        cityAutoTableView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        cityAutoTableView.layer.cornerRadius = 5
        cityAutoTableView.layer.masksToBounds = true
        cityAutoTableView.layer.borderWidth = 1
        cityAutoTableView.layer.borderColor = CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        cityAutoTableView.rowHeight = 20
    }
    
    @objc func showDetails(_ sender:UITapGestureRecognizer?=nil) {
        performSegue(withIdentifier: "showDetailCurrent", sender: self)
    }
    
    func updateFav() {
        let curPage = weatherPageControl.currentPage
        if weatherCards[curPage].favSelected {
            // currently selected, want to delete
            print("(SearchViewController) updateFav: remove", weatherCards[curPage].firstSubViewLocLabel.text!)
            self.view.makeToast((weatherCards[curPage].firstSubViewLocLabel.text ?? "") + " was removed from the Favorite List", position: .bottom)
            
            weatherCards[curPage].removeFromSuperview()
            weatherCards.remove(at: curPage)
            let wid = Int(weatherScrollView.frame.size.width)
            weatherScrollView.setContentOffset(CGPoint(x: ((curPage)) * wid, y: 0), animated: true)
            
        }
        weatherPageControl.numberOfPages = weatherCards.count
        view.bringSubviewToFront(weatherPageControl)
        setupWeatherCards(cards: weatherCards)
    }
    
    func createWeatherCards() -> [WeatherCard] {
        print("(SearchViewController) createWeatherCards")
        
        // current card
        let card1:WeatherCard = Bundle.main.loadNibNamed("WeatherCard", owner: self, options: nil)?.first as! WeatherCard
        card1.favOutlet.isHidden = true
        let tapOnCard = UITapGestureRecognizer(target: self, action: #selector(self.showDetails(_:)))
        card1.firstSubView.addGestureRecognizer(tapOnCard)
        
        // favorite cards
        var favCities : [WeatherCard] = []
        let favListStr = UserDefaults.standard.string(forKey: "favList") ?? ""
        
        var favList = try? JSONDecoder().decode([String].self, from: favListStr.data(using: .utf8)!)
        if favList == nil {
            favList = []
        }
        print("(SearchViewController) favorite: ", favList!)
        
        for i in 0 ..< favList!.count {
            let curCard = Bundle.main.loadNibNamed("WeatherCard", owner: self, options: nil)?.first as! WeatherCard
            let tapOnCard = UITapGestureRecognizer(target: self, action: #selector(self.showDetails(_:)))
            curCard.firstSubView.addGestureRecognizer(tapOnCard)
            curCard.location = favList![i]
            curCard.favSelected = true
            curCard.favOutlet.setImage(UIImage(named: "trash-can"), for: .normal)
            
            // MARK: do : request for latlng, weather, init WeatherCard
            getCoordinate(card: curCard, info: curCard.location)
            
            
            favCities.append(curCard)
        }
        
        return [card1] + favCities
    
    }
    
    func setupWeatherCards(cards : [WeatherCard]) {
        print("(SearchViewController) setupWeatherCards")
        weatherScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        weatherScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(cards.count), height: view.frame.height)
        weatherScrollView.isPagingEnabled = true
        
        for i in 0 ..< cards.count {
            cards[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            if i == 0 {
                cards[i].favOutlet.isHidden = true
            } else {
                cards[i].favSelected = true
            }
            weatherScrollView.addSubview(cards[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == weatherScrollView {
            let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
            weatherPageControl.currentPage = Int(pageIndex)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupWeatherCards(cards: weatherCards)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager?.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        SwiftSpinner.hide()
         print("error:: (SearchViewController) \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("(SearchViewController) func locationManager")
        let currentLoc = locations.last
        if (currentLoc == nil) {
            print("error:: (SearchViewController) fail to get current location.")
            return
        }
        
        // get coordinate
        weatherCards[0].currentInfo["latitude"] = String(format: "%.6f", currentLoc?.coordinate.latitude ?? "0.0")
        weatherCards[0].currentInfo["longitude"] = String(format: "%.6f", currentLoc?.coordinate.longitude ?? "0.0")
        print("current location:", weatherCards[0].currentInfo["latitude"] ?? "0.0", weatherCards[0].currentInfo["longitude"] ?? "0.0")
        
        // get current city & weather
//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(currentLoc!, completionHandler: {
//            (placemarks, error) in
//            if error == nil {
//                let loc = placemarks?[0]
//                weatherCards[0].currentInfo["city"] = loc?.locality ?? "Unknown"
//                weatherCards[0].firstSubViewLocLabel.text = weatherCards[0].currentInfo["city"]
//                print("(SearchViewController) current city:", weatherCards[0].currentInfo["city"] ?? "Unknown")
//            }
//            else {
//                print("error:: (SearchViewController) fail to reverse geocode location.")
//            }
//        })
//
//        // get weather
        getCurrentWeather(card: weatherCards[0], lat: weatherCards[0].currentInfo["latitude"] ?? "0.0", lng: weatherCards[0].currentInfo["longitude"] ?? "0.0", loc: currentLoc!)
    }
    
    func getCurrentWeather(card: WeatherCard, lat: String, lng: String, loc: CLLocation) {
        print("(SearchViewController) func getWeather for current city", lat, lng)
        guard let url = URL(string: apiURL + "/search/weather") else {
            print("error:: (SearchViewController) failed to build url,", apiURL + "/search/weather")
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
                print("error:: (SearchViewController) get weather response result not success for current city")
                return
            }

            guard let value = response.result.value as? [String: Any] else {
                print("error:: (SearchViewController) get weather response result value not exist for current city")
                return
            }
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(loc, completionHandler: {
                (placemarks, error) in
                if error == nil {
                    let loc = placemarks?[0]
                    weatherCards[0].currentInfo["city"] = loc?.locality ?? "Unknown"
                    weatherCards[0].firstSubViewLocLabel.text = weatherCards[0].currentInfo["city"]
                    print("(SearchViewController) current city:", weatherCards[0].currentInfo["city"] ?? "Unknown")
                }
                else {
                    print("error:: (SearchViewController) fail to reverse geocode location.")
                }
            })
            
            // get weather
            
            card.weatherInfoCurrent = value["currently"] as! [String: Any]
            card.weatherInfoDaily = value["daily"] as! [String: Any]
            self.setFirstSubviewValues(card: card, info: card.weatherInfoCurrent)
            self.setSndSubviewValues(card: card, info: card.weatherInfoCurrent)
            self.setTrdSubviewValues(card: card, info: card.weatherInfoDaily)
            
            self.setupWeatherCards(cards: weatherCards)
            
            if (card == weatherCards[0]) {
                SwiftSpinner.hide()
            }
            
        }
    }
    
    func getWeather(card: WeatherCard, lat: String, lng: String) {
        print("(SearchViewController) func getWeather for", card.currentInfo["city"]!, lat, lng)
        guard let url = URL(string: apiURL + "/search/weather") else {
            print("error:: (SearchViewController) failed to build url,", apiURL + "/search/weather")
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
                print("error:: (SearchViewController) get weather response result not success for", card.currentInfo["city"]!)
                return
            }

            guard let value = response.result.value as? [String: Any] else {
                print("error:: (SearchViewController) get weather response result value not exist for", card.currentInfo["city"]!)
                return
            }
            
            card.weatherInfoCurrent = value["currently"] as! [String: Any]
            card.weatherInfoDaily = value["daily"] as! [String: Any]
            self.setFirstSubviewValues(card: card, info: card.weatherInfoCurrent)
            self.setSndSubviewValues(card: card, info: card.weatherInfoCurrent)
            self.setTrdSubviewValues(card: card, info: card.weatherInfoDaily)
            
            self.setupWeatherCards(cards: weatherCards)
            
            if (card == weatherCards[0]) {
                SwiftSpinner.hide()
            }
            
        }
    }
    
    func setFirstSubviewValues(card: WeatherCard, info: [String:Any]?) {
        print("(SearchViewController) func setFirstSubviewValues for", card.currentInfo["city"]!)
        card.firstSubViewTempLabel.text = String(format:"%.0f", info?["temperature"] as! Double) + "°F"
        card.firstSubViewSumLabel.text = (info?["summary"] as! String)
        card.firstSubViewImg.image = UIImage(named: self.iconImg[info?["icon"] as! String] ?? "weather-sunny")
        
        card.currentInfo["temperature"] = String(format:"%.0f", info?["temperature"] as! Double)
        card.currentInfo["summary"] = (info?["summary"] as! String)
    }
    
    func setSndSubviewValues(card: WeatherCard, info: [String:Any]?) {
        print("(SearchViewController) func setSndSubviewValues for", card.currentInfo["city"]!)
        card.sndSubViewHumLabel.text = String(format: "%.1f", round(info?["humidity"] as! Double * 100)) + " %"
        card.sndSubViewWindLabel.text = String(format: "%.2f", round(info?["windSpeed"] as! Double)) + " mph"
        card.sndSubViewVsbLabel.text = String(format: "%.2f", round(info?["visibility"] as! Double)) + " km"
        card.sndSubViewPrsLabel.text = String(format: "%.1f", round(info?["pressure"] as! Double)) + " mb"
    }
    
    func setTrdSubviewValues(card: WeatherCard, info: [String:Any]?) {
        print("(SearchViewController) func setTrdSubviewValues for", card.currentInfo["city"]!)
        let data = info?["data"] as! [[String:Any]]
        card.dailyTableViewCells = []
        for i in 0 ... 7 {
            card.dailyTableViewCells.append([
                "date": convertTime(timestamp: data[i]["time"] as! TimeInterval, format: "MM/dd/yyyy"),
                "sunrise": convertTime(timestamp: data[i]["sunriseTime"] as! TimeInterval, format: "HH:mm"),
                "sunset": convertTime(timestamp: data[i]["sunsetTime"] as! TimeInterval, format: "HH:mm"),
                "icon": self.iconImg[data[i]["icon"] as! String] ?? "weather-sunny"
            ])
        }
        
        card.trdSubView.reloadData()
    }
    
    
    func getCoordinate(card: WeatherCard, info: String) {
        print("(SearchViewController) func getCoordinate for", info)
        let infoList = info.components(separatedBy: ", ")
        var city = ""
        var state = ""
        if (infoList.count == 0) {
            print("error:: (SearchViewController) failed to split", info)
        } else if (infoList.count <= 2) {
            city = infoList[0]
        } else {
            city = infoList[0]
            state = infoList[1]
        }
        guard let url = URL(string: apiURL + "/search/geocode") else {
            print("error:: (SearchViewController) failed to build url,", apiURL + "/search/geocode")
            SwiftSpinner.hide()
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
                print("error:: (SearchViewController) get weather response result not success")
                return
            }

            guard let value = response.result.value as? [String: Any] else {
                print("error:: (SearchViewController) get weather response result value not exist")
                return
            }
            
            let results = value["results"] as! [[String: Any]]
            let geometry = results[0]["geometry"] as! [String: Any]
            let location = geometry["location"] as! [String: Any]
            print("location", location)
            let lat = String(format: "%.6f", location["lat"] as! Double)
            let lng = String(format: "%.6f", location["lng"] as! Double)
            card.currentInfo["city"] = city
            card.currentInfo["latitude"] = lat
            card.currentInfo["longitude"] = lng
            card.firstSubViewLocLabel.text = city
        
            // get weather
            self.getWeather(card: card, lat: lat , lng: lng)
        }
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

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("(SearchViewController) func searchBar for", searchText)
        guard let url = URL(string: apiURL + "/cityauto") else {
            print("error:: (SearchViewController) failed to build url,", apiURL + "/cityauto")
            return
        }
        print("url:", url)
        Alamofire.request(
            url,
            method: .get,
            parameters: ["input": searchText])
        .validate()
        .responseJSON { response in
            guard response.result.isSuccess else {
                print("error:: (SearchViewController) autocomplete response result not success")
                return
            }

            guard let value = response.result.value as? [String: Any] else {
                print("error:: (SearchViewController) autocomplete response result value not exist")
                return
            }
            
            let predictions = value["predictions"] as! [[String: Any]]
            self.cityAutoList = []
            for i in 0 ..< min(5, predictions.count) {
                self.cityAutoList.append(predictions[i]["description"] as! String)
            }
            print(self.cityAutoList.count, self.cityAutoList)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination is SearchResultViewController {
            let dist = segue.destination as? SearchResultViewController
            dist?.searchInput = self.selectedCity
        } else {
            let dist = segue.destination as? TabBarViewController
            let curPage = weatherPageControl.currentPage
            dist?.tabTodayData = weatherCards[curPage].weatherInfoCurrent
            dist?.tabWeeklyData = weatherCards[curPage].weatherInfoDaily
            dist?.cityName = weatherCards[curPage].currentInfo["city"] ?? "Los Angeles"
            dist?.currentInfo = weatherCards[curPage].currentInfo
        }
    }
    

}
