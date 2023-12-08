//
//  ViewController.swift
//  TermiWatchWidget
//
//  Created by Qianlishun on 2023/10/10.
//

import SwiftUI
import ClockKit

@main
struct TermiWatch: App {
    @Environment(\.scenePhase) private var scenePhase
    @State var viewModel = QTermiViewModel()
    
#if targetEnvironment(simulator)
#else
    let locationMgr = WidgetLocationManager()
#endif
    
    var body: some Scene {
        WindowGroup {
            VStack{
                Spacer()
                ContentView(viewModel: viewModel)
                Spacer()
                HStack(alignment: .bottom, content: {
                    Button(LocalizedStringKey("Sync Watch Face"), action: addWatchFace).frame(width: 200,height: 50).background(.orange).foregroundStyle(.black).border(.black, width: 1).cornerRadius(5)

                })
                Spacer()
            }
        }
        //  如果这里报错，要兼容iOS17以下，true 修改为 false
        //  If an error is reported here, it should be compatible with iOS17 or below, and true should be changed to false
#if true
        .onChange(of: scenePhase, initial: true) {
            switch scenePhase {
            case .active:
                print("📲 active")
                viewModel.updateModel()
            case .inactive:
                print("📲 inactive")
            case .background:
                print("📲 background")
            @unknown default: break
            }
        }
#else
        .onChange(of: scenePhase) { phase in
            
            if(phase == .active){
                viewModel.updateModel()
            }
        }
#endif
        
    }
    
    let library = CLKWatchFaceLibrary()
    
    func addWatchFace(){
        
        guard let url = Bundle.main.url(forResource: "TermiWatchWidget", withExtension: "watchface") else {
            fatalError("*** Unable to find My.watchface in the app bundle ***")
        }
        library.addWatchFace(at: url) { error in
            if let error = error {
                fatalError("*** An error occurred: \(error.localizedDescription) ***")
            }
        }
    }
    
}
