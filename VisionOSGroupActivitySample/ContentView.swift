//
//  ContentView.swift
//  VisionOSGroupActivitySample
//
//  Created by Sadao Tokuyama on 3/13/24.
//
import SwiftUI
import RealityKit
import GroupActivities

struct ContentView: View {

    @State var groupSession: GroupSession<SharePlaySampleActivity>?
    @State var groupSessionMessenger: GroupSessionMessenger?
    @State var dataList:Array<Data> = Array<Data>()
    @State var message: String = ""
    @FocusState var focus: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            TextField("Message", text: $message)
                .focused(self.$focus)
            List(dataList) { data in
                DataRow(data: data)
            }
            Button("Active") {
                activate()
            }
            Button("Send") {
                send()
            }.disabled(message.isEmpty)
        }
        .padding()
        .task {
            for await session in SharePlaySampleActivity.sessions() {
                configureGroupSession(session)
            }
        }
    }
    
    func activate() {
        Task {
            do {
                _ = try await SharePlaySampleActivity().activate()
            } catch {
                print("Failed to activate SharePlaySampleActivity activity: \(error)")
            }
        }
    }
    
    func addData() -> Data {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let data = Data(device: getDeviceSystemName(), message: message, date: formatter.string(from: Date()))
        dataList.insert(data, at: 0)
        message = ""
        return data
    }
    
    func receiveData(_ data: Data) {
        dataList.insert(data, at: 0)
    }

    func send() {
        if let messenger = self.groupSessionMessenger {
            Task {
                do {
                    try await messenger.send(addData())
                } catch {
                    print("Send error: \(error)")
                }
            }
        }
        self.focus = false
    }
    
    func configureGroupSession(_ groupSession: GroupSession<SharePlaySampleActivity>) {
        self.groupSession = groupSession
        let groupSessionMessenger = GroupSessionMessenger(session: groupSession)
        self.groupSessionMessenger = groupSessionMessenger
        
        Task {
            for await (data, _) in groupSessionMessenger.messages(of: Data.self) {
                self.receiveData(data)
            }
        }
        groupSession.join()
    }
    
    func getDeviceSystemName() -> String {
        var device = "x.circle"
        switch UIDevice.current.userInterfaceIdiom {
        case .unspecified:
            device = "unspecified"
        case .phone:
            device = "iphone"
        case .pad:
            device = "ipad"
        case .tv:
            device = "appletv"
        case .carPlay:
            device = "car"
        case .mac:
            device = "macbook"
        case .vision:
            device = "visionpro"
        @unknown default:
            device = "x.circle"
        }
        return device
    }
}

struct Data: Identifiable, Codable {
    var id = UUID()
    let device: String
    let message: String
    let date: String
}

struct DataRow: View {
    var data: Data
    var body: some View {
        HStack {
            Image(systemName: data.device)
            Text("\(data.message)")
            Text("\(data.date)").font(.caption2)
        }
    }
}
