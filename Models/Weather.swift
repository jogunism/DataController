//
//  File.swift
//  showMe
//
//  Created by jogunism on 2017. 5. 3..
//  Copyright © 2017년 jogunism. All rights reserved.
//

import Foundation
import SwiftyJSON

class Weather: JSONable {
    
    let station: String!
    let sky: String!
    let skyCode: String!
    let rain: Float!
    let lightning: Bool!

    required init?(json: JSON) {
        station = json["station"]["name"].stringValue
        sky = json["sky"]["name"].stringValue
        skyCode = json["sky"]["code"].stringValue
        rain = (json["rain"]["last1hour"].stringValue as NSString).floatValue
        if (json["lightning"].stringValue == "0") {
            lightning = false
        } else {
            lightning = true
        }
    }

}
