//
//  MWGridStep.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 27/10/2020.
//

import Foundation
import MobileWorkflowCore

public class MWGridStep: MWStep, HasSecondaryWorkflows {
    
    public let session: Session
    public let services: StepServices
    public let secondaryWorkflowIDs: [String]
    public var items: [GridStepItem] = []
    
    init(identifier: String, session: Session, services: StepServices, secondaryWorkflowIDs: [String], items: [GridStepItem]) {
        self.session = session
        self.services = services
        self.secondaryWorkflowIDs = secondaryWorkflowIDs
        self.items = items
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        return MWGridStepViewController(step: self)
    }
}

extension MWGridStep: BuildableStep {
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        
        let secondaryWorkflowIDs: [String] = (stepInfo.data.content["workflows"] as? [[String: Any]])?.compactMap({ $0.getString(key: "id") }) ?? []
        
        if stepInfo.data.type == MWContentDisplayStepType.grid.typeName {
            // Local grid (coming from the app.json)
            let contentItems = stepInfo.data.content["items"] as? [[String: Any]] ?? []
            let items: [GridStepItem] = try contentItems.compactMap {
                guard let text = services.localizationService.translate($0["text"] as? String) else { return nil }
                let detailText = services.localizationService.translate($0["detailText"] as? String)
                guard let id = $0.getString(key: "id") else {
                    throw ParseError.invalidStepData(cause: "Grid item has invalid id")
                }
                return GridStepItem(id: id, type: $0["type"] as? String, text: text, detailText: detailText, imageURL: $0["imageURL"] as? String)
            }
            return MWGridStep(identifier: stepInfo.data.identifier, session: stepInfo.session, services: services, secondaryWorkflowIDs: secondaryWorkflowIDs, items: items)
        } else if stepInfo.data.type == MWContentDisplayStepType.networkGrid.typeName {
            // Remote grid (coming from a network call)
            let emptyText = services.localizationService.translate(stepInfo.data.content["emptyText"] as? String)
            let remoteURLString = stepInfo.data.content["url"] as? String
            return MWNetworkGridStep(identifier: stepInfo.data.identifier, stepInfo: stepInfo, services: services, secondaryWorkflowIDs: secondaryWorkflowIDs, url: remoteURLString, emptyText: emptyText)
        } else {
            throw ParseError.invalidStepData(cause: "Tried to create a grid that's not local nor remote.")
        }
    }
}

extension MWGridStep {
    func viewControllerSections() -> [MWGridStepViewController.Section] {
        
        var vcSections = [MWGridStepViewController.Section]()
        
        var currentSection: GridStepItem?
        var currentItems = [GridStepItem]()
        
        self.items.forEach { item in
            switch item.itemType {
            case .carouselLarge, .carouselSmall:
                if let currentSection = currentSection {
                    // complete current section before starting new one
                    vcSections.append(self.viewControllerSectionFromSection(currentSection, items: currentItems))
                    currentItems.removeAll()
                }
                currentSection = item
            case .item:
                currentItems.append(item)
            }
        }
        
        if let currentSection = currentSection {
            // complete final section
            vcSections.append(self.viewControllerSectionFromSection(currentSection, items: currentItems))
        } else if !currentItems.isEmpty {
            // no sections found, add all to single section
            let section = GridStepItem(id: "DEFAULT_SECTION", type: GridItemType.carouselSmall.rawValue, text: L10n.defaultSectionTitle, detailText: "", imageURL: "")
            vcSections.append(self.viewControllerSectionFromSection(section, items: currentItems))
        }
        
        return vcSections
    }
    
    private func viewControllerSectionFromSection(_ section: GridStepItem, items: [GridStepItem]) -> MWGridStepViewController.Section {
        
        let vcItems = items.map { MWGridStepViewController.Item(id: $0.id, title: $0.text, subtitle: $0.detailText, imageUrl: $0.imageURL.flatMap { URL(string: $0) }) }
        
        let vcSection = MWGridStepViewController.Section(id: section.id, type: section.itemType, title: section.text, items: vcItems)
        
        return vcSection
    }
    
}
