//
//  ClientRequest.swift
//  NEDAssistant
//
//  Created by mac on 2024/6/15.
//

import Foundation

public enum ClientRequest: Codable {
    case setBackgroundImage(image: String)
    case setBrightness(brightness: Int)
    case getBrightness
    
    enum CodingKeys: String, CodingKey {
        case action, args
    }
    
    enum ActionType: String, Codable {
        case setBackgroundImage = "setbackgroudimage"
        case setBrightness = "setbrightness"
        case getBrightness = "getbrightness"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let action = try container.decode(ActionType.self, forKey: .action)
        
        switch action {
        case .setBackgroundImage:
            let args = try container.decode([String: String].self, forKey: .args)
            guard let image = args["image"] else {
                throw DecodingError.dataCorruptedError(forKey: .args, in: container, debugDescription: "Missing image argument")
            }
            self = .setBackgroundImage(image: image)
        case .setBrightness:
            let args = try container.decode([String: Int].self, forKey: .args)
            guard let brightness = args["brightness"] else {
                throw DecodingError.dataCorruptedError(forKey: .args, in: container, debugDescription: "Missing brightness argument")
            }
            self = .setBrightness(brightness: brightness)
        case .getBrightness:
            self = .getBrightness
        }
    }
    
public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .setBackgroundImage(let image):
            try container.encode(ActionType.setBackgroundImage, forKey: .action)
            try container.encode(["image": image], forKey: .args)
        case .setBrightness(let brightness):
            try container.encode(ActionType.setBrightness, forKey: .action)
            try container.encode(["brightness": brightness], forKey: .args)
        case .getBrightness:
            try container.encode(ActionType.getBrightness, forKey: .action)
        }
    }
    
    func validate() -> Bool {
        switch self {
        case .setBackgroundImage(let image):
            return !image.isEmpty
        case .setBrightness(let brightness):
            return brightness >= 0 && brightness <= 100
        case .getBrightness:
            return true
        }
    }
}
