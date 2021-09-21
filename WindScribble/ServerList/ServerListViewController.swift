//
//  ServerListViewController.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 19/09/2021.
//

import UIKit
import CoreData
import Combine

class ServerListViewController: UIViewController {
    
    @IBOutlet weak var serverCollectionView: UICollectionView!
    private var activityIndicator = UIActivityIndicatorView(style: .medium)
    private var dataSource: UICollectionViewDiffableDataSource<Section, ListItem>!
    private var serverLocations: [ServerLocation] = []
    
    private let viewModel = SelectServerViewModel()
    private let userDefault: Defaults = Defaults()
    private var bindings = Set<AnyCancellable>()
    
    var vpnServerSelectionDelegate: VPNServerSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setBindings()
        
    }
    
    private func setBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            })
            .store(in: &bindings)
        
        viewModel.$message
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] message in
                if let message = message {
                    self?.showAlert(title: "VPN Status", message: message)
                }
            })
            .store(in: &bindings)
        
        viewModel.$serverLocations
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] locations in
                self?.serverLocations = locations
                self?.createSnapshot()
            })
            .store(in: &bindings)
        
    }
    
    private func setupView() {
        activityIndicator.frame = CGRect(x:0, y:0, width:40, height:40)
        activityIndicator.center = CGPoint(x:view.bounds.width / 2, y:view.bounds.height / 2)
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        let provider = {(_: Int, layoutEnv: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.showsSeparators = true
            configuration.backgroundColor = .systemBackground
            return .list(using: configuration, layoutEnvironment: layoutEnv)
        }
        serverCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: provider)
        serverCollectionView.register(cell: .serverLocationCell, cellIdentifier: Cell.serverLocationCell.rawValue)
        serverCollectionView.delegate = self
        
        dataSource = makeDatasource()
        
    }
    
    private func makeDatasource() -> UICollectionViewDiffableDataSource<Section, ListItem> {
        
        let nodeCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ServerNode> {
            (cell, indexPath, node) in
            var content = cell.defaultContentConfiguration()
            content.text = node.name
            cell.contentConfiguration = content
        }
        
        return UICollectionViewDiffableDataSource<Section, ListItem>(collectionView: serverCollectionView) {
            (collectionView, indexPath, listItem) -> UICollectionViewCell? in
            
            switch listItem {
            case .serverLocation(let serverLocationItem):
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.serverLocationCell.rawValue, for: indexPath) as? ServerCollectionViewCell {
                    cell.setupServerLocation(serverLocation: serverLocationItem)
                    return cell
                }
                return UICollectionViewCell()
            case .serverNode(let serverNodeItem):
                let cell = collectionView.dequeueConfiguredReusableCell(using: nodeCellRegistration, for: indexPath, item: serverNodeItem)
                return cell
            }
        }
    }
    
    private func createSnapshot() {
        
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
        
        for locations in serverLocations {
            
            let headerListItem = ListItem.serverLocation(locations)
            sectionSnapshot.append([headerListItem])
            
            if locations.isExpaned {
                if let nodes = (locations.nodes?.array as? [ServerNode]) {
                    let nodesArray = nodes.map { ListItem.serverNode($0) }
                    sectionSnapshot.append(nodesArray, to: headerListItem)
                }
                
                sectionSnapshot.expand([headerListItem])
            }
        }
        
        dataSource.apply(sectionSnapshot, to: .main, animatingDifferences: true)
        
    }
    
}

extension ServerListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        
        switch item {
        case .serverLocation(let serverLocationItem):
            if serverLocationItem.isExpaned {
                serverLocationItem.isExpaned = false
            } else {
                serverLocationItem.isExpaned = true
            }
            if let e = collectionView.cellForItem(at: indexPath) as? ServerCollectionViewCell {
                e.toggle(expanded: serverLocationItem.isExpaned)
            }
            createSnapshot()
        case .serverNode(let node):
            if let server = node.serverLocation {
                vpnServerSelectionDelegate?.connect(node: node, server: server)
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

enum Section: Hashable {
    case main
}

enum ListItem: Hashable {
    case serverLocation(ServerLocation)
    case serverNode(ServerNode)
}
