//
//  RootNavigationBuilder.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 08.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs

final class RootNavigationComponent: Component<RootNavigationDependency> {}

final class RootNavigationBuilder: Builder<RootNavigationDependency>, RootNavigationBuildable {

    override init(dependency: RootNavigationDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: RootNavigationListener) -> RootNavigationRouting {
        let component = RootNavigationComponent(dependency: dependency)
        let viewController = RootNavigationViewController.instantiateFromStoryboard()
        let interactor = RootNavigationInteractor(presenter: viewController)
        interactor.listener = listener
        return RootNavigationRouter(interactor: interactor, viewController: viewController)
    }
}
