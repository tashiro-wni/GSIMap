//
//  Utility.swift
//  GSIMap
//
//  Created by tasshy on 2020/07/26.
//  Copyright © 2020 tasshy. All rights reserved.
//

import Foundation
import UIKit

public func LOG(_ body: Any, filename: String = #file, functionName: String = #function, line: Int = #line) {
#if DEBUG
    var file = filename.components(separatedBy: "/").last ?? filename
    file = file.replacingOccurrences(of: ".swift", with: "")
    
    //print("\(DebugLog._currentDateString()) [\(file).\(functionName):\(line)] \(body)")    // print functionName
    NSLog("[\(file):\(line)] \(body)")
#endif
}

extension UIImage {
    class func imageWithColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
