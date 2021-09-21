//
//  Defaults.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 21/09/2021.
//

import Foundation
class Defaults {
    
    var defaults: UserDefaults? = nil
    
    init() {
        defaults = UserDefaults.standard
    }
    
    // MARK: Has Loaded Server
    func setHasLoadedServers(status: Bool) {
        defaults?.set(status, forKey: DefaultKeys.hasLoadedServers)
    }
    
    func hasLoadedServers() -> Bool {
        return defaults?.bool(forKey: DefaultKeys.hasLoadedServers) ?? false
    }
    
    // MARK: Server name
    func setServerName(name: String) {
        defaults?.set(name, forKey: DefaultKeys.selectedServerName)
    }
    
    func getServerName() -> String? {
        return defaults?.string(forKey: DefaultKeys.selectedServerName)
    }
    
    // MARK: Server city
    func setServerCity(name: String) {
        defaults?.set(name, forKey: DefaultKeys.selectedServerCity)
    }
    
    func getServerCity() -> String? {
        return defaults?.string(forKey: DefaultKeys.selectedServerCity)
    }
    
    // MARK: Country code
    func setServerCountryCode(countryCode: String) {
        defaults?.set(countryCode, forKey: DefaultKeys.selectedServerCountryCode)
    }
    
    func getServerCountryCode() -> String? {
        return defaults?.string(forKey: DefaultKeys.selectedServerCountryCode)
    }
    
    // MARK: Hostname
    func setHostname(hostname: String) {
        defaults?.set(hostname, forKey: DefaultKeys.hostname)
    }
    
    func getHostname() -> String? {
        return defaults?.string(forKey: DefaultKeys.selectedServerCountryCode)
    }
    
    // MARK: DNS Hostname
    func setDNSHostname(dnsHostname: String) {
        defaults?.set(dnsHostname, forKey: DefaultKeys.dnsHostname)
    }
    
    func getDNSHostname() -> String? {
        return defaults?.string(forKey: DefaultKeys.dnsHostname)
    }
    
    
    struct DefaultKeys {
        static let hasLoadedServers = "hasLoadedServers"
        static let selectedServerName = "serverName"
        static let selectedServerCity = "serverCity"
        static let selectedServerCountryCode = "countryCode"
        static let hostname = "hostname"
        static let dnsHostname = "dnsHostname"
    }
}
