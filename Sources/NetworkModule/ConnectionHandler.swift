//
//  ConnectionHandler.swift
//  NEDAssistant
//
//  Created by mac on 2024/6/14.
//

import Foundation
import Network

class ConnectionHandler {
    var connection: NWConnection
    var uniqueID: Int
    var didStopCallback: ((ConnectionHandler) -> Void)?
    var newRequestCallback: ((ClientRequest) -> Void)?
    var clientRequest: ClientRequest?
    
    init(connection: NWConnection, uniqueID: Int) {
        self.connection = connection
        self.uniqueID = uniqueID
    }
    
    func start() {
        self.connection.stateUpdateHandler = self.stateDidChange(to:)
        self.connection.start(queue: DispatchQueue.global())
        self.receiveData()
    }
    
    func stateDidChange(to newState: NWConnection.State){
        switch newState {
        case .setup:
            break
        case .waiting(let error):
            print("Connection failed with error: \(error)")
            self.cancel()
        case .preparing:
            break
        case .ready:
            break
        case .failed(let error):
            print("Connection failed with error: \(error)")
            self.cancel()
        case .cancelled:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func receiveData() {
        self.connection.receive(minimumIncompleteLength: 0, maximumLength: 1024) { (data, context, isComplete, error) in
            if let error = error {
                print("Receive failed with error: \(error)")
                self.cancel()
                return
            }
            
            if let data = data {
                
                let dataString = String(data: data, encoding: .utf8)
                print("Received data: \(dataString ?? "")")
                
                // 在这里处理接收到的数据
                
                do {
                    let decoder = JSONDecoder()
                    self.clientRequest = try decoder.decode(ClientRequest.self, from: data)
                    print("Received data: \(dataString ?? "")")
                     
                     // 验证请求
                     if let request = self.clientRequest, request.validate() {
                         // 通知 Server 类有新的客户端请求到达
                         self.newRequestCallback?(request)
                     } else {
                         print("Invalid request")
                     }
                } catch {
                    print("Failded to decode JSON: \(error)")
                }
                
                // 如果数据接收完毕，继续接收下一部分数据
                if isComplete {
                    self.receiveData()
                }
            }
        }
    }
    
    func cancel() {
        self.connection.cancel()
        self.didStopCallback?(self)
    }
}
