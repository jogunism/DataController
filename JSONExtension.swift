//
//  JSONExtension.swift
//  showMe
//
//  Created by jogunism on 2017. 4. 25..
//  Copyright © 2017년 jogunism. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {

    func to<T>(type: T?) -> Any? {

        if let baseObj = type as? JSONable.Type {
            if self.type == .array {
                var arrObject: [Any] = []
                for obj in self.arrayValue {
                    let object = baseObj.init(json: obj)
                    arrObject.append(object!)
                }
                return arrObject
            } else {
                let object = baseObj.init(json: self)
                return object!
            }
        }
        return nil
    }

}
