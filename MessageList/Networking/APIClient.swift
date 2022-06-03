//
//  APIClient.swift
//  MessageList
//
//  Created by David Figueroa on 3/06/22.
//

import Foundation

class APIClient {
    
    private var request: URLRequest?
    
    func createRequestWithURLComponents(requestType: RequestType) -> URLRequest? {
        
        var components = URLComponents(string: requestType.absoluteString)!
        
        components.queryItems = requestType.parameters
        request = URLRequest(url: components.url!)
        request?.httpMethod = requestType.method
        return request
    }
    
    func sendRequest<T:Codable>(model: T.Type, request: URLRequest, completionHandler: @escaping (Result<T, Error>) -> ()) {
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(model.self, from: data)
                completionHandler(.success(response))

            } catch {
                completionHandler(.failure(error))
            }
        }).resume()
    }
}
