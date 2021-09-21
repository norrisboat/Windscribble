//
//  HomeViewModel.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 19/09/2021.
//

import Foundation
import Combine
import CoreData
import NetworkExtension

enum VPNConnectionState {
    case connecting
    case connected
    case disconnecting
    case disconnected
    case error(Error)
}

enum LoadingServerState {
    case loading
    case doneLoading
    case error(Error)
}

final class HomeViewModel {
    
    @Published var vpnState: VPNConnectionState = .disconnected
    @Published var loadingState: LoadingServerState = .loading
    @Published var selectedServerLocation: ServerLocation? = nil
    @Published var selectedNode: ServerNode? = nil
    @Published var ipAddress: String = ""
    @Published var message: String? = nil
    
    private let apiService: APIServiceProtocol
    private let vpnService: VPNService
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        self.apiService = APIService()
        self.vpnService = VPNService()
        
        fetchServers()
        
        if isConnectedToVpn() {
            vpnState = .connected
            getCurrentIP()
        }
    }
    
    private func fetchServers() {
        loadingState = .loading
        
        let getServersCompletionHandler: (Subscribers.Completion<Error>) -> Void = { [weak self] completion in
            switch completion {
            case .failure(let error): self?.loadingState = .error(error)
            case .finished: self?.loadingState = .doneLoading
            }
        }
        
        let getServersValueHandler: ([Server]) -> Void = { [weak self] servers in
            self?.saveServers(servers: servers)
        }
        
        apiService
            .getServers()
            .sink(receiveCompletion: getServersCompletionHandler, receiveValue: getServersValueHandler)
            .store(in: &cancellables)
        
    }
    
    private func saveServers(servers: [Server]) {
        let managedObjectContext = CoreDataStorage.shared.managedObjectContext()
        
        for server in servers {
            let serverLocation = ServerLocation(context: managedObjectContext)
            serverLocation.name = server.name
            serverLocation.countryCode = server.countryCode
            serverLocation.dnsHostname = server.dnsHostname
            var serverNodes: [ServerNode] = []
            
            for node in server.nodes {
                let serverNode = ServerNode(context: managedObjectContext)
                serverNode.name = node.group
                serverNode.hostname = node.hostname
                serverNodes.append(serverNode)
                
            }
            serverLocation.nodes = NSOrderedSet(array: serverNodes)
            
        }
        
        CoreDataStorage.shared.saveContext()
    }
    
    func connectVPN(hostname: String, dnsHostname: String) {
        vpnService.connectVPN(hostname: hostname, dnsHostname: dnsHostname, completion: {  [weak self] result in
            switch result {
            case .success(_): break
            case .failure(let error):
                self?.message = error.localizedDescription
            }
            
        })
    }
    
    func connectVPN(node: ServerNode, server: ServerLocation) {
        if let hostname = node.hostname, let dnsHostname = server.dnsHostname {
            vpnService.connectVPN(hostname: hostname, dnsHostname: dnsHostname, completion: {  [weak self] result in
                switch result {
                case .success(_):
                    self?.selectedNode = node
                    self?.selectedServerLocation = server
                case .failure(let error):
                    self?.message = error.localizedDescription
                }
                
            })
        }
    }
    
    func vpnStatusChanged() {
        switch vpnService.vpnConnectionStatus {
        case .connecting: vpnState = .connecting
        case .connected:
            vpnState = .connected
            getCurrentIP()
        case .disconnecting: vpnState = .disconnecting
        case .disconnected: vpnState = .disconnected
        default: vpnState = .error(fatalError("Couldn't connect to vpn"))
        }
    }
    
    func disconnectVPN() {
        vpnService.disconnect()
    }
    
    private func isConnectedToVpn() -> Bool {
        if let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? Dictionary<String, Any>,
           let scopes = settings["__SCOPED__"] as? [String:Any] {
            for (key, _) in scopes {
                if key.contains("tap") || key.contains("tun") || key.contains("ppp") || key.contains("ipsec") {
                    return true
                }
            }
        }
        return false
    }
    
    private func getCurrentIP() {
        Ipify.getPublicIPAddress { [weak self] result in
            switch result {
            case .success(let ip):
                self?.ipAddress = ip
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
