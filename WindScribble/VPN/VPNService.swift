//
//  VPNService.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 19/09/2021.
//

import NetworkExtension
import SwiftKeychainWrapper

protocol VPNServerSelectionDelegate {
    func connect(node: ServerNode, server: ServerLocation)
}

class VPNService {
    
    private enum Config {
        static let password = "xpcnwg6abh"
        static let username = "prd_test_j4d3vk6"
        static let passwordKey = "password"
    }
    
    private let vpnManager = NEVPNManager.shared()
    
    var vpnConnectionStatus: NEVPNStatus {
        return vpnManager.connection.status
    }
    
    func connectVPN(hostname: String, dnsHostname: String, completion: @escaping (Result<NEVPNStatus, Error>) -> ()) {
        vpnManager.loadFromPreferences {[unowned self] error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                KeychainWrapper.standard.set(Config.password, forKey: Config.passwordKey)
                
                let vpnProtocol = NEVPNProtocolIKEv2()
                
                vpnProtocol.useExtendedAuthentication = true
                vpnProtocol.ikeSecurityAssociationParameters.encryptionAlgorithm =  NEVPNIKEv2EncryptionAlgorithm.algorithmAES256GCM
                vpnProtocol.ikeSecurityAssociationParameters.diffieHellmanGroup = NEVPNIKEv2DiffieHellmanGroup.group21
                vpnProtocol.ikeSecurityAssociationParameters.integrityAlgorithm = NEVPNIKEv2IntegrityAlgorithm.SHA256
                vpnProtocol.ikeSecurityAssociationParameters.lifetimeMinutes = 1440
                vpnProtocol.childSecurityAssociationParameters.encryptionAlgorithm =  NEVPNIKEv2EncryptionAlgorithm.algorithmAES256GCM
                vpnProtocol.childSecurityAssociationParameters.diffieHellmanGroup = NEVPNIKEv2DiffieHellmanGroup.group21
                vpnProtocol.childSecurityAssociationParameters.integrityAlgorithm = NEVPNIKEv2IntegrityAlgorithm.SHA256
                vpnProtocol.childSecurityAssociationParameters.lifetimeMinutes = 1440
                vpnProtocol.username = Config.username
                vpnProtocol.passwordReference = KeychainWrapper.standard.data(forKey: Config.passwordKey)
                vpnProtocol.serverAddress = hostname
                vpnProtocol.remoteIdentifier = dnsHostname
                vpnProtocol.localIdentifier = dnsHostname
                
                vpnManager.protocolConfiguration = vpnProtocol
                vpnManager.localizedDescription = "WindScribble"
                
                self.vpnManager.saveToPreferences {[weak self] error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        do {
                            if let self = self {
                                self.vpnManager.isEnabled = true
                                try self.vpnManager.connection.startVPNTunnel()
                                completion(.success(self.vpnManager.connection.status))
                            }
                        } catch let connectionError {
                            completion(.failure(connectionError))
                        }
                    }
                }
            }
        }
    }
    
    func disconnect() {
        vpnManager.connection.stopVPNTunnel()
    }
}
