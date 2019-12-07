//
//  Test.swift
//  MyBeeline
//
//  Created by Vladimir on 03/08/2019.
//  Copyright © 2019 Beeline. All rights reserved.
//

import UIKit

final class DisclosureTextCell: UITableViewXibContainerCell<DisclosureTextView> {
  override func prepareForReuse() {
    super.prepareForReuse()
    view.resetToEmptyState()
  }
}

final class DisclosureTextView: UIView, NibLoadable, ResetableView {
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    resetToEmptyState()
    initialSetup()
  }

  func resetToEmptyState() {
    textLabel.text = nil
  }

  func setText(_ text: String) {
    textLabel.text = text
  }

  private func initialSetup() {
    let image = UIImage(named: "accessory_arrow")
    imageView.image = image
  }
}
