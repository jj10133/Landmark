import SwiftUI

@main
struct App: SwiftUI.App {
    
    @StateObject private var worker = Worker()
    @StateObject private var ipcViewModel = IPCViewModel()
    @State private var isWorkletStarted = false
    
    @Environment(\.scenePhase) private var scenePhase
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ipcViewModel)
                .onAppear {
                    worker.start()
                    isWorkletStarted = true
                    ipcViewModel.configure(with: worker.ipc)
//                    Task {
//                        await ipcViewModel.readFromIPC()
//                    }
                }
                .onDisappear {
                    worker.terminate()
                }
        }
        .onChange(of: scenePhase) { phase in
            guard isWorkletStarted else { return }
            
            switch phase {
            case .background:
                worker.suspend()
            case .active:
                worker.resume()
            default:
                break
            }
        }
    }
}
