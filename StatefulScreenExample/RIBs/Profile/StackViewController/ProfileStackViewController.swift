//
//  ProfileViewController.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift

final class ProfileStackViewController: UIViewController, ProfileViewControllable {
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

extension ProfileStackViewController {
  private func initialSetup() {}
}

// MARK: - BindableView

extension ProfileStackViewController: BindableView {
  func getOutput() -> ProfileViewOutput {
    return ProfileViewOutput()
  }

  func bindWith(_ input: ProfilePresenterOutput) {}
}

// MARK: - RibStoryboardInstantiatable

extension ProfileStackViewController: RibStoryboardInstantiatable {}
