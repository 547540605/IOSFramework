//
//  ClientRequest.swift
//  NEDAssistant
//
//  Created by mac on 2024/6/15.
//

import Foundation

struct ClientRequest: Codable {
    let action: String
    let args: Args
    
    struct Args: Codable {
        let image: String
        let brightness: String
    }
}
