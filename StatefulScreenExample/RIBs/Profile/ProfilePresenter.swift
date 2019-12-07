//
//  ProfilePresenter.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift

final class ProfilePresenter: ProfilePresentable {}

// MARK: - IOTransformer

extension ProfilePresenter: IOTransformer {
  func transform(_ interactorOutput: ProfileInteractorOutput) -> ProfilePresenterOutput {
    return ProfilePresenterOutput()
  }
}
