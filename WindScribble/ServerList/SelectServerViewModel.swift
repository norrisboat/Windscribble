//
//  SelectServerViewModel.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 21/09/2021.
//

import Foundation
import CoreData

final class SelectServerViewModel {
    
    @Published var message: String? = nil
    @Published var serverLocations: [ServerLocation] = []
    @Published var isLoading = true
    
    init() {
        getServers()
    }
    
    private func getServers() {
        isLoading = true
        let managedObjectContext = CoreDataStorage.shared.managedObjectContext()
        let fetchRequest: NSFetchRequest<ServerLocation> = ServerLocation.fetchRequest()
        
        do {
            let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sectionSortDescriptor]
            serverLocations = try managedObjectContext.fetch(fetchRequest)
            isLoading = false
        } catch {
            isLoading = false
            message = "Couldn't load servers"
        }
        
    }
    
}
