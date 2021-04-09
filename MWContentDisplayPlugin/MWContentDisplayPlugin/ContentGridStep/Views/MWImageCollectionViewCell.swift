//
//  MWImageCollectionViewCell.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 29/10/2020.
//

import Foundation
import Combine
import MobileWorkflowCore

protocol MWImageCollectionViewCellDelegate: class {}

class MWImageCollectionViewCell: UICollectionViewCell {
    
    struct ViewData {
        let title: String?
        let subtitle: String?
        let imageUrl: URL?
    }
    
    var delegate: MWImageCollectionViewCellDelegate?
    
    //MARK: - UI
    private let titleLabel: UILabel!
    private let subtitleLabel: UILabel!
    private let imageView: UIImageView!
    
    private var imageLoadTask: AnyCancellable?
    
    override init(frame: CGRect) {
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.font = .preferredFont(forTextStyle: .body, weight: .regular)
        titleLabel.textColor = .label
        self.titleLabel = titleLabel
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.setContentCompressionResistancePriority(.required-1, for: .vertical)
        subtitleLabel.setContentHuggingPriority(.required-1, for: .vertical)
        subtitleLabel.font = .preferredFont(forTextStyle: .caption1, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        self.subtitleLabel = subtitleLabel
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10.0
        imageView.layer.masksToBounds = true
        self.imageView = imageView
        
        self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 9/16).isActive = true
        
        let infoStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        infoStack.axis = .vertical
        infoStack.distribution = .fill
        infoStack.alignment = .fill
        infoStack.spacing = 0
        infoStack.isLayoutMarginsRelativeArrangement = true
        infoStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let mainStack = UIStackView(arrangedSubviews: [imageView, infoStack])
        mainStack.axis = .vertical
        mainStack.distribution = .fill
        mainStack.alignment = .fill
        mainStack.spacing = 10
        
        super.init(frame: frame)
        
        self.contentView.addPinnedSubview(mainStack)
        
        self.backgroundColor = .secondarySystemBackground
        self.contentView.backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configuration
    
    func configure(viewData: ViewData, imageLoader: ImageLoadingService, session: Session) {
        self.imageLoadTask?.cancel()
        
        if let imageUrl = viewData.imageUrl {
//            self.imageView.tag = imageUrl.hashValue
            self.imageLoadTask = imageLoader.asyncLoad(image: imageUrl.absoluteString, session: session) { [weak self] (image) in
                guard let strongSelf = self/*,
                      strongSelf.imageView.tag == imageUrl.hashValue */ else { return }
                strongSelf.imageView.image = image
            }
        }

        self.titleLabel.text = viewData.title
        self.subtitleLabel.text = viewData.subtitle
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }
    
    private func clear() {
        self.imageLoadTask?.cancel()

        self.imageView.image = nil
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
    }
}