//
//  WeatherCard.swift
//  Weather
//
//  Created by Ouyu Lan on 11/30/19.
//  Copyright © 2019 Ouyu Lan. All rights reserved.
//

import UIKit
import Toast_Swift

@objc protocol FavoriteDelegate {
    func updateFav()
}

class WeatherCard: UIView {
    @IBOutlet weak var firstSubView: UIView!
    @IBOutlet weak var firstSubViewImg: UIImageView!
    @IBOutlet weak var firstSubViewTempLabel: UILabel!
    @IBOutlet weak var firstSubViewSumLabel: UILabel!
    @IBOutlet weak var firstSubViewLocLabel: UILabel!
    @IBOutlet weak var sndSubView: UIView!
    @IBOutlet weak var sndSubViewHumLabel: UILabel!
    @IBOutlet weak var sndSubViewWindLabel: UILabel!
    @IBOutlet weak var sndSubViewVsbLabel: UILabel!
    @IBOutlet weak var sndSubViewPrsLabel: UILabel!
    @IBOutlet weak var trdSubView: UITableView!
    
    @IBOutlet weak var favOutlet: UIButton!
    
    var favSelected = false
    var location = ""
    var currentInfo = [
        "latitude": "",
        "longitude": "",
        "temperature": "",
        "summary": "",
        "city": "",
        "icon": "",
    ]
    var dailyTableViewCells:[[String: Any]] = []
    var weatherInfoCurrent: [String: Any] = [:]
    var weatherInfoDaily: [String: Any] = [:]
    var favoriteDelegate : FavoriteDelegate?
    
    
    @IBAction func favBtnAction(_ sender: Any) {
        let favListStr = UserDefaults.standard.string(forKey: "favList") ?? ""
        var favList = try? JSONDecoder().decode([String].self, from: favListStr.data(using: .utf8)!)
        if favList == nil {
            favList = []
        }
        print("before click favlist: ",favListStr)
        if favSelected {
            // delete fav
            favList = favList?.filter {$0 != self.location}
            let dataToStore = (try? JSONEncoder().encode(favList)) ?? nil
            let stringToStore = String(data: dataToStore!, encoding: .utf8)
            UserDefaults.standard.set(stringToStore, forKey: "favList")
            favOutlet.setImage(UIImage(named: "plus-circle"), for: .normal)
            print("after click favlist: ", stringToStore!)
            // update slides
            favoriteDelegate?.updateFav()
            favSelected = false
            self.makeToast((self.firstSubViewLocLabel.text ?? "") + " was removed from the Favorite List", position: .bottom)
        } else {
            // add fav, means in detail controller
            favList?.append(self.location)
            let dataToStore = (try? JSONEncoder().encode(favList)) ?? nil
            let stringToStore = String(data: dataToStore!, encoding: .utf8)
            UserDefaults.standard.set(stringToStore, forKey: "favList")
            
            favOutlet.setImage(UIImage(named: "trash-can"), for: .normal)
            print("after click favlist: ", stringToStore!)
            favoriteDelegate?.updateFav()
            favSelected = true
            self.makeToast((self.firstSubViewLocLabel.text ?? "") + " was added to the Favorite List", position: .bottom)
        }
    }
    
    
    
    override func draw(_ rect: CGRect) {
        // first subview
        self.firstSubView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
        self.firstSubView.layer.cornerRadius = 12;
        self.firstSubView.layer.masksToBounds = true;
        self.firstSubView.layer.borderWidth = 1;
        self.firstSubView.layer.borderColor = CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        // second subview
        self.sndSubView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        
        // third subview
        self.trdSubView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.trdSubView.layer.cornerRadius = 12;
        self.trdSubView.layer.masksToBounds = true;
        self.trdSubView.layer.borderWidth = 1;
        self.trdSubView.layer.borderColor = CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        let tapOnCard = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        self.firstSubView.addGestureRecognizer(tapOnCard)
        
        
//        if !ifFaved {
//            favButtonOutlet.setImage(UIImage(named: "trash-can"), for: .normal)
//        }
    }
}
