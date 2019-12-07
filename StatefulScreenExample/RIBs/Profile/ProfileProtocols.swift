//
//  ProfileProtocols.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

// MARK: - Builder

protocol ProfileBuildable: Buildable {
  func build() -> ProfileRouting
  
  func buildScreenWithTableView() -> ProfileRouting
}

// MARK: - Router

protocol ProfileInteractable: Interactable {
  var router: ProfileRouting? { get set }
}

protocol ProfileViewControllable: ViewControllable {}

// MARK: - Interactor

protocol ProfileRouting: ViewableRouting {
  /// Переход на экран смены e-mail'a
  func routeToEmailChange()
  
  /// Переход на экран добавления e-mail'a
  func routeToEmailAddition()
}

protocol ProfilePresentable: Presentable {}

// MARK: Outputs

enum ProfileInteractorState {
  case isLoadingProfile
  case dataLoaded(Profile)
  case profileLoadingError(Error)
}

struct ProfilePresenterOutput {
  let viewModel: Driver<ProfileViewModel>
  let isContentViewVisible: Driver<Bool>
  let isLoadingIndicatorVisible: Driver<Bool>
  
  /// nil означает что нужно спрятать сообщение об ошибке
  let showError: Signal<ErrorMessageViewModel?>
}

struct ProfileViewOutput {
  /// Добавление / изменение e-mail'a
  let emailUpdateTap: ControlEvent<Void>
  
  let retryButtonTap: ControlEvent<Void>
}

struct ProfileViewModel {
  let firstName: TitledText
  let lastName: TitledText
  let middleName: TitledModel<String?>
  
  let login: TitledText
  let email: TitledModel<String?>
  let phone: TitledModel<String?>
  
  let myOrders: String
}

struct ErrorMessageViewModel {
  let title: String
  let buttonTitle: String
}
