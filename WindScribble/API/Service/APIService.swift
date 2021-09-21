//
//  APIService.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 19/09/2021.
//

import Foundation
import Combine


protocol APIServiceProtocol {
    func getServers() -> AnyPublisher<[Server], Error>
}

enum Failure: Error {
    case url
    case decode
}

final class APIService: APIServiceProtocol {
    
    func getServers() -> AnyPublisher<[Server], Error> {
        var dataTask: URLSessionDataTask?
        
        let onSubscription: (Subscription) -> Void = { _ in dataTask?.resume() }
        let onCancel: () -> Void = { dataTask?.cancel() }
        
        return Future<[Server], Error> { promise in
            guard let url = URL(string: "https://assets.windscribe.com/serverlist/ikev2/1/89yr4y78r43gyue4gyut43guy") else {
                promise(.failure(Failure.url))
                return
            }
            
            dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard let data = data else {
                    if let error = error {
                        promise(.failure(error))
                    }
                    return
                }
                do {
                    let response = try JSONDecoder().decode(GetServersResponse.self, from: data)
                    promise(.success(response.data))
                } catch {
                    promise(.failure(Failure.decode))
                }
            }
        }
        .handleEvents(receiveSubscription: onSubscription, receiveCancel: onCancel)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
}

