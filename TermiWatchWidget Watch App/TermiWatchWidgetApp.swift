//
//  WatchKitAppApp.swift
//  WatchKitApp Watch App
//
//  Created by Qianlishun on 2023/10/10.
//

import SwiftUI
import WidgetKit

@main
struct TermiWatchWidgetApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State var viewModel = QTermiViewModel()
    @State var imageIndex = 1
    let userdefaults = UserDefaults.init(suiteName: qGroupBundleID)

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .onTapGesture {
                    imageIndex+=2
                    if(imageIndex>qBGImageCount){
                        imageIndex = 1;
                    }
                    let weatherImage = qBGImageNamePre + String(imageIndex);
                    let healthImage = qBGImageNamePre + String(imageIndex+1);
                    userdefaults?.setValue(weatherImage, forKey: qWeatherImageKey)
                    userdefaults?.setValue(healthImage, forKey: qHealthImageKey)

                    viewModel.updateModel()
                }
        }
        
//  如果这里报错，要兼容iOS17以下，使用下面被注释的内容
//  If an error is reported here, it should be compatible with iOS17 or below, and true should be changed to false

//#if true
        .onChange(of: scenePhase, initial: true) {
            switch scenePhase {
            case .active:
                print("📲 active")
                WidgetCenter.shared.reloadTimelines(ofKind: "HealthWidget" )
                WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget" )

                viewModel.updateModel()
            case .inactive:
                print("📲 inactive")
            case .background:
                print("📲 background")
            @unknown default: break
            }
        }
        
//#else
//        .onChange(of: scenePhase) { phase in
//
//            if(phase == .active){
//                viewModel.updateModel()
//                WidgetCenter.shared.reloadTimelines(ofKind: "HealthWidget" )
//                WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget" )
//            }
//        }
//#endif
    }
    
}

#Preview {
    
    VStack{
        Text("100")
        let img = UIImage(named: "100")!

        Image(uiImage: img).frame(width: 100, height: 100, alignment: .center).backgroundStyle(.white).foregroundStyle(.red)

    }
}
