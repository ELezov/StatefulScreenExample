//
//  RootNavigationRouter.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 08.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs

final class RootNavigationRouter: LaunchRouter<RootNavigationInteractable, RootNavigationViewControllable>, RootNavigationRouting {
    override init(interactor: RootNavigationInteractable, viewController: RootNavigationViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
