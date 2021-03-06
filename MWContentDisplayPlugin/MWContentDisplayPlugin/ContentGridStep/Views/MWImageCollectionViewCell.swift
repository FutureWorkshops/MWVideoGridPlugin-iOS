//
//  MWImageCollectionViewCell.swift
//  MWContentDisplayPlugin
//
//  Created by Roberto Arreaza on 29/10/2020.
//

import Foundation
import Combine
import MobileWorkflowCore

class MWImageCollectionViewCell: UICollectionViewCell {
    
    struct ViewData {
        let title: String?
        let subtitle: String?
        let imageUrl: URL?
    }
    
    //MARK: Class properties
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let imageView = UIImageView()
    private var imageLoadTask: AnyCancellable?
    
    //MARK: Lifecycle
    override init(frame: CGRect) {
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.titleLabel.setContentHuggingPriority(.required, for: .vertical)
        self.titleLabel.font = .preferredFont(forTextStyle: .body)
        self.titleLabel.textColor = .label
        
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.setContentCompressionResistancePriority(.required-1, for: .vertical)
        self.subtitleLabel.setContentHuggingPriority(.required-1, for: .vertical)
        self.subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        self.subtitleLabel.textColor = .secondaryLabel
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.cornerRadius = 16.0
        self.imageView.layer.masksToBounds = true
        self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 9/16).isActive = true
        
        let infoStack = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])
        infoStack.axis = .vertical
        infoStack.distribution = .fill
        infoStack.alignment = .fill
        infoStack.spacing = 0
        
        let mainStack = UIStackView(arrangedSubviews: [self.imageView, infoStack])
        mainStack.axis = .vertical
        mainStack.distribution = .fill
        mainStack.alignment = .fill
        mainStack.spacing = 12
        
        super.init(frame: frame)
        
        self.contentView.addPinnedSubview(mainStack)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }
    
    //MARK: Configuration
    func configure(viewData: ViewData, isLargeSection: Bool, imageLoader: ImageLoadingService, session: Session) {
        self.titleLabel.text = viewData.title
        self.subtitleLabel.text = viewData.subtitle
        
        self.imageView.layer.cornerRadius = isLargeSection ? 16.0 : 12.0
        self.imageLoadTask?.cancel()
        if let imageUrl = viewData.imageUrl {
            self.imageLoadTask = imageLoader.asyncLoad(image: imageUrl.absoluteString, session: session) { [weak self] (image) in
                guard let strongSelf = self else { return }
                strongSelf.imageView.image = image
            }
        }
    }
    
    private func clear() {
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
        
        self.imageLoadTask?.cancel()
        self.imageView.image = nil
    }
}
