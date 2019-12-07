//
//  ProfileRouter.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs

final class ProfileRouter: ViewableRouter<ProfileInteractable, ProfileViewControllable>, ProfileRouting {
  override init(interactor: ProfileInteractable, viewController: ProfileViewControllable) {
    super.init(interactor: interactor, viewController: viewController)
    interactor.router = self
  }
}
