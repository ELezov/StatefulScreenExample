//
//  RootNavigationProtocols.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 08.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift

// MARK: - Builder

protocol RootNavigationBuildable: Buildable {
  func build(withListener listener: RootNavigationListener) -> RootNavigationRouting
}

// MARK: - Router

protocol RootNavigationInteractable: Interactable {
  var router: RootNavigationRouting? { get set }
}

protocol RootNavigationViewControllable: ViewControllable {}

// MARK: - Interactor

protocol RootNavigationRouting: ViewableRouting {}
