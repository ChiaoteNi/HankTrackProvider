//
//  extension + NSObject.swift
//  Utilities
//
//  Created by Chiao-Te Ni on 2017/12/7.
//  Copyright © 2017年 Chiao-Te Ni. All rights reserved.
//

import UIKit

public protocol ClassNameProtocol {
    static var className: String { get }
    var className: String { get }
}

public extension ClassNameProtocol {
    static var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}

extension NSObject: ClassNameProtocol {}
