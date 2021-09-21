//
//  ColorExtensions.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 19/09/2021.
//

import UIKit

struct Colors{
    static let primaryColor: String = "#e76f51"
    static let inActiveColor: String = "#828E98"
    static let white: String = "#FFFFFF"
}

extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
    public class var primaryColor: UIColor {
        return UIColor(hexString: Colors.primaryColor)
    }
    
    public class var lightPrimaryColor: UIColor {
        return UIColor(hexString: Colors.primaryColor, alpha: 0.5)
    }
    
    public class var lighterPrimaryColor: UIColor {
        return UIColor(hexString: Colors.primaryColor, alpha: 0.1)
    }
    
    public class var inActiveColor: UIColor {
        return UIColor(hexString: Colors.inActiveColor)
    }
    
    public class var lightInActiveColor: UIColor {
        return UIColor(hexString: Colors.white, alpha: 0.6)
    }
    
    public class var lighterInActiveColor: UIColor {
        return UIColor(hexString: Colors.white, alpha: 0.1)
    }
    
    public class var inActiveBackgroundColor: UIColor {
        return UIColor(hexString: Colors.inActiveColor, alpha: 0.1)
    }
}
