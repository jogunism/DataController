//
//  JSONable.swift
//  showMe
//
//  Created by jogunism on 2017. 4. 25..
//  Copyright © 2017년 jogunism. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JSONable {
    init?(json: JSON)
}
