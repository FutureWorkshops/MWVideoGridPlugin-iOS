//
//  MWContentStackStep.swift
//  MWVideoGridPlugin
//
//  Created by Xavi Moll on 6/4/21.
//

import Foundation
import MobileWorkflowCore

public class MWContentStackStep: ORKStep {
    
    let headerImageURL: URL?
    let items: [StepItem]
    
    init(identifier: String, headerImageURL: URL?, items: [StepItem]) {
        self.items = items
        self.headerImageURL = headerImageURL
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func stepViewControllerClass() -> AnyClass {
        return MWContentStackViewController.self
    }
}

extension MWContentStackStep: MobileWorkflowStep {
    public static func build(stepInfo: StepInfo, services: MobileWorkflowServices) throws -> Step {
        let jsonItems = (stepInfo.data.content["items"] as? Array<[String:Any]>) ?? []
        var headerImageURL: URL?
        if let headerImageURLString = stepInfo.data.content["imageURL"] as? String {
            headerImageURL = URL(string: headerImageURLString)
        }
        return MWContentStackStep(identifier: stepInfo.data.identifier,
                                  headerImageURL: headerImageURL,
                                  items: jsonItems.compactMap { StepItem(json: $0, localizationService: services.localizationService) })
    }
}

// Describes all the supported types of item that can be shown vertically stacked.
// For now, just title, text and listItem
// Every case includes the model that defines the concrete implementation as an associated type
enum StepItem: Identifiable {
    
    case title(StepItemTitle)
    case text(StepItemText)
    case listItem(StepItemListItem)
    
    var id: String {
        switch self {
        case .title(let item): return item.id
        case .text(let item): return item.id
        case .listItem(let item): return item.id
        }
    }
    
    init?(json: [String:Any], localizationService: LocalizationService) {
        if let stepTypeTitle = StepItemTitle(json: json, localizationService: localizationService) {
            self = .title(stepTypeTitle)
        } else if let stepTypeText = StepItemText(json: json, localizationService: localizationService) {
            self = .text(stepTypeText)
        } else if let stepTypeListItem = StepItemListItem(json: json, localizationService: localizationService) {
            self = .listItem(stepTypeListItem)
        } else {
            return nil
        }
    }
}

struct StepItemTitle: Identifiable {
    let id: String
    let title: String?
    
    init?(json: [String:Any], localizationService: LocalizationService) {
        guard (json["type"] as? String) == Optional("title") else {
            return nil
        }
        guard let id = json["id"] as? String else {
            assertionFailure("Missing id.")
            return nil
        }
        self.id = id
        self.title = localizationService.translate(json["title"] as? String)
    }
}

struct StepItemText: Identifiable {
    let id: String
    let text: String?
    
    init?(json: [String:Any], localizationService: LocalizationService) {
        guard (json["type"] as? String) == Optional("text") else {
            return nil
        }
        guard let id = json["id"] as? String else {
            assertionFailure("Missing id.")
            return nil
        }
        self.id = id
        self.text = localizationService.translate(json["text"] as? String)
    }
}

struct StepItemListItem: Identifiable {
    let id: String
    let title: String?
    let detailText: String?
    let imageURL: URL?
    
    init?(json: [String:Any], localizationService: LocalizationService) {
        guard (json["type"] as? String) == Optional("listItem") else {
            return nil
        }
        guard let id = json["id"] as? String else {
            assertionFailure("Missing id.")
            return nil
        }
        self.id = id
        self.title = localizationService.translate(json["text"] as? String)
        self.detailText = localizationService.translate(json["detailText"] as? String)
        if let imageURLString = json["imageURL"] as? String {
            self.imageURL = URL(string: imageURLString)
        } else {
            self.imageURL = nil
        }
    }
}

