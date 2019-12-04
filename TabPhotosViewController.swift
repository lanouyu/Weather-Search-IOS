//
//  TabPhotosViewController.swift
//  Weather
//
//  Created by Ouyu Lan on 12/1/19.
//  Copyright © 2019 Ouyu Lan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner

class TabPhotosViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var cityName: String = ""
    var apiURL = "http://csci599-hw9.appspot.com"
    var imgWidth:CGFloat = 0
    var imgHeight:CGFloat = 0
    var yPos:CGFloat = 0
    var scrollViewHeight:CGFloat = 0
    var imgList:[UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("load tab photos view controller.")
        SwiftSpinner.show("Fetching Google Images...")
        
        self.imgWidth = self.scrollView.frame.size.width
        self.imgHeight = self.imgWidth
        
        getPhotos()
        
    }
    
    func getPhotos() {
        print("(TabPhotosViewController) func getPhotos")
        guard let url = URL(string: apiURL + "/cityphoto") else {
            print("error:: (TabPhotosViewController) failed to build url,", apiURL + "/cityphoto")
            SwiftSpinner.hide()
            return
        }
        print("url:", url)
        Alamofire.request(
            url,
            method: .get,
            parameters: ["city": self.cityName])
        .validate()
        .responseJSON { response in
            guard response.result.isSuccess else {
                print("error:: get photo response result not success")
                SwiftSpinner.hide()
                return
            }

            guard let value = response.result.value as? [String: Any] else {
                print("error:: get photo response result value not exist")
                SwiftSpinner.hide()
                return
            }
            
            self.imgWidth = self.scrollView.frame.size.width
            self.imgHeight = self.imgWidth
            let items = value["items"] as! [[String: Any]]
            for i in 0 ..< min(8, items.count) {
                let ifHidSpinner = (i == (min(8, items.count) - 1))
                self.loadImage(from: URL(string: items[i]["link"] as! String)!, ifHidSpinner: ifHidSpinner)
            }
            
//            print("imgList count", self.imgList.count)
//            for imgView in self.imgList {
//                imgView.frame.origin.y = self.yPos
//                self.scrollView.addSubview(imgView)
//
//                self.yPos += self.imgHeight
//                self.scrollViewHeight += self.imgHeight
//                self.scrollView.contentSize.height = self.scrollViewHeight
//            }
            
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func loadImage(from url: URL, ifHidSpinner: Bool) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                print("load image from url:", url, "data:", data)
                let imgView = UIImageView(image: UIImage(data: data))
                imgView.frame.size.width = self.imgWidth
                imgView.frame.size.height = self.imgHeight
                imgView.contentMode = UIView.ContentMode.scaleAspectFill
                imgView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//                imgView.center = self.view.center
                self.imgList.append(imgView)
                imgView.frame.origin.y = self.yPos
                self.scrollView.addSubview(imgView)

                self.yPos += self.imgHeight
                self.scrollViewHeight += self.imgHeight
                self.scrollView.contentSize.height = self.scrollViewHeight
                
                if (ifHidSpinner) {
                    SwiftSpinner.hide()
                }
            }
        }
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
