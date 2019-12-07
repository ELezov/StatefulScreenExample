//
//  Test.swift
//  MyBeeline
//
//  Created by Vladimir on 03/08/2019.
//  Copyright © 2019 Beeline. All rights reserved.
//

import UIKit

final class ContactFieldCell: UITableViewXibContainerCell<ContactFieldView> {
  override func prepareForReuse() {
    super.prepareForReuse()
    view.resetToEmptyState()
  }
}

final class ContactFieldView: UIView, NibLoadable, ResetableView {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var textLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    resetToEmptyState()
  }

  func resetToEmptyState() {
    titleLabel.text = nil
    textLabel.text = nil
  }

  func setTitle(_ title: String, text: String?) {
    titleLabel.text = title
    textLabel.text = text
  }
}
