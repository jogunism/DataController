//
//  FaceAnnotation.swift
//  showMe
//
//  Created by jogun on 2017. 4. 25..
//  Copyright © 2017년 jogunism. All rights reserved.
//

import Foundation
import SwiftyJSON

class FaceAnnotation: JSONable {

    let anger: String!
    let blurred: String!
    let headwear: String!
    let joy: String!
    let sorrow: String!
    let surprise: String!
    let underExposed: String!
    
    required init(json: JSON) {
        anger = json["angerLikelihood"].stringValue
        blurred = json["blurredLikelihood"].stringValue
        headwear = json["headwearLikelihood"].stringValue
        joy = json["joyLikelihood"].stringValue
        sorrow = json["sorrowLikelihood"].stringValue
        surprise = json["surpriseLikelihood"].stringValue
        underExposed = json["underExposedLikelihood"].stringValue
    }
}
