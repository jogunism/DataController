//
//  DataController.swift
//  showMe
//
//  Created by jogun on 2017. 4. 24..
//  Copyright © 2017년 jogunism. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation


public enum dataType {
    case vision
    case weather
    case todayText
    case search
}

protocol DataControllerDelegate {
    func success(_ type: dataType, _ data:Any)
    func fail(_ type: dataType, _ data:String)
}

class DataController: NSObject {

    // MARK: - variable

    var locationmanager = CLLocationManager()
    var delegate:DataControllerDelegate?

    
    // MARK: - init
    
    override init() {
        locationmanager.requestWhenInUseAuthorization()
        locationmanager.startUpdatingLocation()
    }



    // MARK: - methods

    func vision(_ imageBase64: String) {

        var googleURL: URL {
            return URL(string: "\(Constant.Global.googleAPIUrl)?key=\(Constant.Global.googleAPIKey)")!
        }

        var request = URLRequest(url: googleURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")

        // Build API request
        let params:NSMutableDictionary? = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 5
                    ],
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 5
                    ],
                    [
                        "type": "LANDMARK_DETECTION",
                        "maxResults": 5
                    ],
                    [
                        "type": "SAFE_SEARCH_DETECTION",
                        "maxResults": 5
                    ]
                ]
            ]
        ]

        let data = try! JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions.prettyPrinted)
        let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        request.httpBody = json!.data(using: String.Encoding.utf8.rawValue);

        Alamofire.request(request)
            .responseData{ response in

                switch response.result {
                case .success(let value):

                    DispatchQueue.main.async(execute: {

                        let json = JSON(value)["responses"][0]

//                        var faceAnnotations: [FaceAnnotation] = []
//                        if(json["faceAnnotations"] != JSON.null) {
//                            if let arr = json["faceAnnotations"].to(type: FaceAnnotation.self) {
//                                faceAnnotations = arr as! [FaceAnnotation]
//                            }
//                        }
//
//                        var labelAnnotations: [LabelAnnotation] = []
//                        if(json["labelAnnotations"] != JSON.null) {
//                            if let arr = json["labelAnnotations"].to(type: LabelAnnotation.self) {
//                                labelAnnotations = arr as! [LabelAnnotation]
//                            }
//                        }
//
//                        var safeSearchAnnotation: SafeSearchAnnotaion! = nil
//                        if(json["safeSearchAnnotation"] != JSON.null) {
//                            if let obj = json["safeSearchAnnotation"].to(type: SafeSearchAnnotaion.self) {
//                                safeSearchAnnotation = obj as! SafeSearchAnnotaion
//                            }
//                        }
//
//                        var landmarkAnnotation: [LandmarkAnnotaion] = []
//                        if(json["landmarkAnnotations"] != JSON.null) {
//                            if let arr = json["landmarkAnnotations"].to(type: LandmarkAnnotaion.self) {
//                                landmarkAnnotation = arr as! [LandmarkAnnotaion]
//                            }
//                        }
//                        self.delegate?.success(.vision, faceAnnotations)

                        var faces = [[String : String]]()
                        for face in json["faceAnnotations"].arrayValue {
                            var el = [String : String]()
                            el["headwear"] = face["headwearLikelihood"].rawString()!
                            el["surprise"] = face["surpriseLikelihood"].rawString()!
                            el["anger"] = face["angerLikelihood"].rawString()!
                            el["joy"] = face["joyLikelihood"].rawString()!
                            el["sorrow"] = face["sorrowLikelihood"].rawString()!
                            el["underExposed"] = face["underExposedLikelihood"].rawString()!
                            el["blurred"] = face["blurredLikelihood"].rawString()!
                            faces.append(el)
                        }

                        var labels = [[String : String]]()
                        for label in json["labelAnnotations"].arrayValue {
                            var el = [String : String]()
                            el["score"] = label["score"].rawString()
                            el["desc"] = label["description"].rawString()
                            labels.append(el)
                        }
                        
                        var safeSearch = [String : String]()
                        safeSearch["adult"] = json["safeSearchAnnotation"]["adult"].rawString()
                        safeSearch["violence"] = json["safeSearchAnnotation"]["violence"].rawString()
                        safeSearch["spoof"] = json["safeSearchAnnotation"]["spoof"].rawString()
                        safeSearch["medical"] = json["safeSearchAnnotation"]["medical"].rawString()

                        var landmarks = [[String : String]]()
                        for landmark in json["landmarkAnnotations"].arrayValue {
                            var el = [String : String]()
                            el["score"] = landmark["score"].rawString()
                            el["desc"] = landmark["description"].rawString()
                            landmarks.append(el)
                        }

                        let obj: Parameters = [
                            "faces": JSON(faces).rawString()!,
                            "labels": JSON(labels).rawString()!,
                            "safeSearch": JSON(safeSearch).rawString()!,
                            "landmarks": JSON(landmarks).rawString()!
                        ]

                        self.getTodayText(obj)
                    })

                case .failure(let error):
                    print(error.localizedDescription)
                    self.delegate?.fail(.vision, error as! String)
                }
            }
    }


    func getCurrentWhether() {

        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse){
            return;
        }

        let params: Parameters = [
            "version": 1,
            "lat": locationmanager.location!.coordinate.latitude,
            "lon": locationmanager.location!.coordinate.longitude
        ]

        Alamofire.request(Constant.Global.skWhetherAPIUrl,
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: ["appKey" : Constant.Global.skWhetherAPIKey])
                 .responseJSON { response in

                    switch response.result {
                    case .success(let value):

                        DispatchQueue.main.async(execute: {

                            let json = JSON(value)

                            var weatherInfo: [Weather] = []
                            if(json["weather"]["minutely"] != JSON.null) {
                                if let arr = json["weather"]["minutely"].to(type: Weather.self) {
                                    weatherInfo = arr as! [Weather]
                                } else {
                                    self.delegate?.fail(.weather, "Temporary error occured to get weather data.")
                                }
                            }
                            if (weatherInfo.count < 1) {
                                self.delegate?.fail(.weather, "")
                            } else {
                                self.delegate?.success(.weather, weatherInfo[0])
                            }
                        })

                    case .failure(let error):
                        print(error.localizedDescription)
                        self.delegate?.fail(.weather, error as! String)
                    }
        }

    }
    
    func getTodayText() {
        getTodayText(nil)
    }

    func getTodayText(_ obj:Parameters?) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        if (obj == nil) {
            self.delegate?.success(.todayText, "Hey!\nHow are you?\nWhat a beautiful day today!\n=)")
            appDelegate.hideLoadingView()
            return
        }

        let headers: HTTPHeaders = [
            "charset": "utf-8",
            "Accept": "application/json"
        ]

        Alamofire.request("\(Constant.Global.DOMAIN)/api/mobile/todayText",
                    method: .post,
                    parameters: obj,
                    encoding: URLEncoding.default,
                    headers: headers)
            .responseJSON { response in

                print(response.result)

//                switch(response.result) {
//                case .success(let value):
//                    self.delegate?.success(.todayText, "Hey!\nHow are you?\nWhat a beautiful day today!\n=)")
//                case .failure(let error):
//                    self.delegate?.fail(.todayText, "")
//                    break
//                }

                appDelegate.hideLoadingView()
        }
    }


    func doSearch(_ txt: String) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showLoadingView()

        let uri = "\(Constant.Global.DOMAIN)/api/search/?q=\(Util.urlEncode(txt))&count=30"

        Alamofire.request(uri)
                 .responseJSON { response in

                    switch response.result {
                    case .success(let value):

                        DispatchQueue.main.async(execute: {
                            
                            let json = JSON(value)
                            
                            var authors: [Author] = []
                            if (json["AUTHOR"] != JSON.null) {
                                if let arr = json["AUTHOR"]["list"].to(type: Author.self) {
                                    authors = arr as! [Author]
                                }
                            }

                            var episodes: [Episode] = []
                            if (json["POST"] != JSON.null) {
                                if let arr = json["POST"]["list"].to(type: Episode.self) {
                                    episodes = arr as! [Episode]
                                }
                            }

                            self.delegate?.success(.vision, ["episodes": episodes, "episodeCount":json["POST"]["totalCount"], "authors": authors])

                            appDelegate.hideLoadingView()
                        })
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.delegate?.fail(.vision, error as! String)
                        
                        appDelegate.hideLoadingView()
                    }
                 }
    }


}

