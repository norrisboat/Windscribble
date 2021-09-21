//
//  HomeViewController.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 19/09/2021.
//

import UIKit
import Combine
import NetworkExtension

class HomeViewController: UIViewController {
    
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var countrylabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var connectionInfoView: UIStackView!
    @IBOutlet weak var serverStatusLabel: UILabel!
    @IBOutlet weak var openServerListImageView: UIImageView!
    @IBOutlet weak var ipAddressImageView: UIImageView!
    @IBOutlet weak var ipAddressTitleLabel: UILabel!
    @IBOutlet weak var openServerListButton: UIButton!
    @IBOutlet weak var loadServerActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var pulseView: PulseView!
    
    var userDefault: Defaults = Defaults()
    let viewModel = HomeViewModel()
    let vpnService = VPNService()
    
    private var bindings = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setBindings()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(vpnStatusUpdates(notification:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
    
    @IBAction func onSelectServerTapped(_ sender: Any) {
        bottomView.tapBounceAnimation()
        guard let serverListViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ServerListViewController") as? ServerListViewController else { return }
        serverListViewController.vpnServerSelectionDelegate = self
        self.present(serverListViewController, animated: true, completion: nil)
    }
    
    private func setupViews() {
        bottomView.backgroundColor = .primaryColor
        connectedLabel.makePill()
        bottomView.roundTopCorners(radius: 20)
        
        if userDefault.hasLoadedServers() {
            setServerView(isLoading: false)
        }
        
        let pulseTap = UITapGestureRecognizer.init(target: self, action: #selector(onPulseClicked))
        pulseView.addGestureRecognizer(pulseTap)
        pulseView.isUserInteractionEnabled = true
    }
    
    private func setupVPNView() {
        
        if let serverName = userDefault.getServerName(), serverName != "" {
            countrylabel.text = serverName
        }
        
        if let cityName = userDefault.getServerCity(), cityName != "" {
            cityLabel.text = cityName
        }
        
        if let countryCode = userDefault.getServerCountryCode(), countryCode != "" {
            countryFlag.makeCircular()
            ipAddressImageView.makeCircular()
            countryCode.loadFlagImage().sink { [weak self] image in self?.countryFlag.image = image }.store(in: &bindings)
        }
    }
    
    private func setServerView(isLoading: Bool) {
        if isLoading {
            loadServerActivityIndicator.startAnimating()
            openServerListButton.isEnabled = false
            openServerListImageView.isHidden = true
            serverStatusLabel.text = "Loading Servers"
        } else {
            loadServerActivityIndicator.stopAnimating()
            openServerListButton.isEnabled = true
            openServerListImageView.isHidden = false
            serverStatusLabel.text = "Select Server"
        }
    }
    
    private func setupConnectedView() {
        pulseView.isUserInteractionEnabled = true
        connectionInfoView.isHidden = false
        setupVPNView()
        pulseView.connectedAnimation()
        connectedLabel.text = "Connected"
        connectedLabel.backgroundColor = .lighterPrimaryColor
        connectedLabel.textColor = .primaryColor
        connectionInfoView.backgroundColor = .lighterPrimaryColor
    }
    
    private func setupDisconnectedView() {
        pulseView.isUserInteractionEnabled = true
        connectionInfoView.isHidden = true
        connectedLabel.text = "Connection not secure"
        connectedLabel.backgroundColor = .inActiveBackgroundColor
        connectedLabel.textColor = .inActiveColor
        pulseView.disconnected()
    }
    
    private func setBindings() {
        
        viewModel.$message
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] message in
                if let message = message {
                    self?.showAlert(title: "VPN Error", message: message)
                }
            })
            .store(in: &bindings)
        
        viewModel.$loadingState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] loadingState in
                if !(self?.userDefault.hasLoadedServers() ?? false) {
                    switch loadingState {
                    case .loading:
                        self?.setServerView(isLoading: true)
                    case .doneLoading:
                        self?.userDefault.setHasLoadedServers(status: true)
                        self?.setServerView(isLoading: false)
                    case .error(let error):
                        self?.loadServerActivityIndicator.stopAnimating()
                        self?.openServerListButton.isEnabled = true
                        self?.openServerListImageView.isHidden = false
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            })
            .store(in: &bindings)
        
        viewModel.$vpnState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] vpnState in
                switch vpnState {
                case .connected:
                    self?.setupConnectedView()
                case .connecting:
                    self?.pulseView.isUserInteractionEnabled = false
                    self?.pulseView.bouncyAnimation()
                case .disconnecting:
                    print("Disconnecting")
                case .disconnected:
                    self?.setupDisconnectedView()
                case .error(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            })
            .store(in: &bindings)
        
        viewModel.$selectedNode
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] node in
                if let city = node?.name, let hostname = node?.hostname {
                    self?.userDefault.setServerCity(name: city)
                    self?.userDefault.setHostname(hostname: hostname)
                }
            })
            .store(in: &bindings)
        
        viewModel.$selectedServerLocation
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] server in
                if let serverName = server?.name, let countryCode = server?.countryCode, let dnsHostname = server?.dnsHostname {
                    self?.userDefault.setServerName(name: serverName)
                    self?.userDefault.setServerCountryCode(countryCode: countryCode)
                    self?.userDefault.setDNSHostname(dnsHostname: dnsHostname)
                }
            })
            .store(in: &bindings)
        
        viewModel.$ipAddress
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] ipAddress in
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.ipAddressImageView.isHidden = false
                    self?.ipAddressTitleLabel.isHidden = false
                    self?.ipAddressLabel.text = ipAddress
                })
            })
            .store(in: &bindings)
    }
    
    @objc func onPulseClicked() {
        switch viewModel.vpnState {
        case .connected:
            let alert = UIAlertController(title: "Disconnect", message: "Are you sure you want to disconnect?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {
                [weak self] alert in
                self?.viewModel.disconnectVPN()
            }))
        default:
            if userDefault.getServerName() != nil {
                if let hostname = userDefault.getHostname(), let dnsHostname = userDefault.getDNSHostname() {
                    viewModel.connectVPN(hostname: hostname, dnsHostname: dnsHostname)
                }
            }
        }
    }
    
    @objc private func vpnStatusUpdates(notification: Notification) {
        viewModel.vpnStatusChanged()
    }
    
}

extension HomeViewController: VPNServerSelectionDelegate {
    
    func connect(node: ServerNode, server: ServerLocation) {
        viewModel.connectVPN(node: node, server: server)
    }
}

