//
//  RequestType.swift
//  MessageList
//
//  Created by David Figueroa on 3/06/22.
//

import Foundation

enum RequestType {
    case getPosts
}

extension RequestType: APIRequest {
    
    var scheme: String {
        switch self {
        default:
            return "https"
        }
    }
    
    var baseURL: String {
        switch self {
        default:
            return "jsonplaceholder.typicode.com"
        }
    }
    
    var path: String {
        switch self {
        case .getPosts:
            return "/comments"
        }
    }
    
    var parameters: [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }
    
    var method: String {
        switch self {
        default:
            return "GET"
        }
    }
    
    var absoluteString: String {
        switch self {
        default:
            return self.scheme + "://" + self.baseURL + self.path
        }
    }
}
