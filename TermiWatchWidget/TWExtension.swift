//
//  TWExtension.swift
//  TermiWatchWidget
//
//  Created by Qianlishun on 2023/10/26.
//

import Foundation
import SwiftUI

let hfBundle = Bundle(path: Bundle.main.path(forResource: "HFBundle", ofType: "bundle")!)
    

struct WXImage: View{
    let wxIcon: String
    var svg: WXSVGView?
    
    init(wxIcon: String) {
        self.wxIcon = wxIcon
        if(HFWeatherKey.count > 0 && wxIcon.hasPrefix("svg")){
            let icon = wxIcon.suffix(from: wxIcon.index(wxIcon.startIndex, offsetBy: 3))
            svg = WXSVGView(name: String(icon))
        }
    }
    var body: some View{
        if(HFWeatherKey.count == 0 || !wxIcon.hasPrefix("svg")){
            Image(systemName: wxIcon).frame(width: 15).imageScale(.small)
        }else{
            svg!
        }
    }
}
extension WXImage{
    
    @inlinable public func foregroundStyle(color: Color) -> some View{
        if(HFWeatherKey.count > 0 ){
            if (svg != nil ){
                svg!.setTint(color: color)
            }
        }
        return self.foregroundStyle(color)
    }
}


struct WXSVGView: View {
    let name: String
    let color: Color?
    var svgView: SVGView
    
    init(name: String, color: Color? = nil, svgView: SVGView? = nil) {
        self.name = name
        self.color = color
        self.svgView = SVGView(contentsOf: hfBundle!.url(forResource: name, withExtension: "svg")!)
    }
    
    var body: some View {
        if(color != nil){
            tint(svgView.svg!, color: color!.svgColor())
        }

        return svgView.frame(width: 15,height: 15)
    }
    func setTint(color: Color){
        tint(svgView.svg!, color: color.svgColor())
    }
   
    
    func tint(_ node: SVGNode, color: SVGColor) {
        if let group = node as? SVGGroup {
            for content in group.contents {
                tint(content, color: color)
            }
        } else if let shape = node as? SVGShape {
            shape.fill = color
        }
    }
}

extension Color {
    init(r: Double, g: Double, b: Double){
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0)
    }
    init(r: Double, g: Double, b: Double, a: Double){
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, opacity: a)
    }
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }

        return (r, g, b, o)
    }

    var hex: String {
        String(
            format: "#%02x%02x%02x%02x",
            Int(components.red * 255),
            Int(components.green * 255),
            Int(components.blue * 255),
            Int(components.opacity * 255)
        )
    }
    
    func svgColor() -> SVGColor{
        let r = Int(components.red*255);
        let g = Int(components.green*255);
        let b = Int(components.blue*255);
        let o = components.opacity
        return SVGColor(r: r, g: g, b: b, opacity: o)
    }
}

extension Date{

    func currentDate() -> String{
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        if ( NSLocale.preferredLanguages[0].hasPrefix("zh")){
            formatter.dateStyle = .full
            formatter.calendar = Calendar(identifier: .chinese)
            formatter.locale = Locale(identifier: "zh_CN")
            var date = formatter.string(from: self)
            date = date.components(separatedBy: CharacterSet(charactersIn: "年")).last ?? date
            date = date.replacingOccurrences(of: "星期", with: " 周")
            let jieqi = " " + (getJieQi(date: self) ?? "")
            date = date.appending(jieqi)
            return date
        }else{
            formatter.dateFormat = "EEE MM/dd YYYY"
            formatter.calendar = Calendar.current
            return formatter.string(from: self)
        }
    }
}

extension DateFormatter{
    func noYear(from: Date) -> String{
        var date = self.string(from: from)
        date = date.components(separatedBy: CharacterSet(charactersIn: "年")).last ?? date
        date = date.replacingOccurrences(of: "星期", with: " 周")
        let jieqi = " " + (getJieQi(date: from) ?? "")
        date = date.appending(jieqi)
        return date
    }
}

func getCurrentFormatter() -> DateFormatter{
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    if ( NSLocale.preferredLanguages[0].hasPrefix("zh")){
        formatter.dateStyle = .full
        formatter.calendar = Calendar(identifier: .chinese)
        formatter.locale = Locale(identifier: "zh_CN")
    }else{
        formatter.dateFormat = "EEE MM/dd YYYY"
        formatter.calendar = Calendar.current
    }
    return formatter
}
