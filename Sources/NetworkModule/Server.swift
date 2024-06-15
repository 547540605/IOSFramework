//
//  Server.swift
//  NEDAssistant
//
//  Created by mac on 2024/6/14.
//

import Foundation
import Network

public class Server{
    var listener: NWListener?

    public init() throws {
        let listener = try NWListener(using: .tcp, on: 8889)
        listener.stateUpdateHandler = self.stateDidChange(to:)
        listener.newConnectionHandler = self.didAccept(connection:)
        self.listener = listener
    }
    
    public func start() throws {
        self.listener?.start(queue: .main)
    }

    func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case.setup:
            break
        case.waiting:
            break
        case.ready:
            break
        case.failed(let error):
            self.listenerDidFail(error: error)
        case.cancelled:
            break
        @unknown default:
            fatalError()
        }
    }
    
    var nextID: Int = 0
    
    var connectionsHandlers: [Int: ConnectionHandler] = [:]
    
    func didAccept(connection: NWConnection) {
        let handler = ConnectionHandler(connection: connection, uniqueID: self.nextID)
        self.nextID += 1
        self.connectionsHandlers[handler.uniqueID] = handler
        handler.didStopCallback = self.connectionDidStop(_:)
        handler.start()
    }
    
    func stop() {
        if let listener = self.listener {
            self.listener = nil
            listener.cancel()
        }
        for handler in self.connectionsHandlers.values {
            handler.cancel()
        }
        self.connectionsHandlers.removeAll()
    }
    
    func listenerDidFail(error: Error) {
        print("Listener failed with error: \(error)")
        // 你可以在这里添加一些错误处理的代码，例如重启服务器或者记录错误日志
    }
    
    func connectionDidStop(_ handler: ConnectionHandler) {
        if let key = self.connectionsHandlers.keys.first(where: { self.connectionsHandlers[$0] === handler }) {
            self.connectionsHandlers[key] = nil
        }
    }

}

