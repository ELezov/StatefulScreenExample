//
//  ProfilePresenter.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class ProfilePresenter: ProfilePresentable {}

// MARK: - IOTransformer

extension ProfilePresenter: IOTransformer {
  func transform(_ state: Observable<ProfileInteractorState>) -> ProfilePresenterOutput {
    let viewModel = Helper.viewModel(state)
    
    let isContentViewVisible = state.map { state -> Bool in
      switch state {
      case .dataLoaded:
        return true
      case .loadingError, .isLoading:
        return false
      }
    }
    .distinctUntilChanged()
    .asDriver(onErrorJustReturn: false)

    let isLoadingIndicatorVisible = state.map { state -> Bool in
      switch state {
      case .isLoading:
        return true
      case .loadingError, .dataLoaded:
        return false
      }
    }
    .distinctUntilChanged()
    .asDriver(onErrorJustReturn: false)

    let showError = state.map { state -> ErrorMessageViewModel? in
      switch state {
      case .loadingError(let error):
        return ErrorMessageViewModel(title: error.localizedDescription, buttonTitle: "Повторить")
      case .isLoading, .dataLoaded:
        return nil
      }
    }
    // .distinctUntilChanged() - ⚠️ здесь этот оператор применять не нужно
    .asSignal(onErrorJustReturn: nil)

    return .init(viewModel: viewModel,
                 isContentViewVisible: isContentViewVisible,
                 isLoadingIndicatorVisible: isLoadingIndicatorVisible,
                 showError: showError)
  }
}

extension ProfilePresenter {
  private enum Helper: Namespace {
    static func viewModel(_ state: Observable<ProfileInteractorState>) -> Driver<ProfileViewModel> {
      return state.compactMap { state -> ProfileViewModel? in
        switch state {
        case .dataLoaded(let profile):
          let emailTitle: String = (profile.email == nil ? "Добавить e-mail" : "E-mail")

          return ProfileViewModel(firstName: TitledText(title: "Имя", text: profile.firstName),
                                  lastName: TitledText(title: "Фамилия", text: profile.lastName),
                                  middleName: TitledOptionalText(title: "Отчество", maybeText: profile.middleName),
                                  login: TitledText(title: "Никнейм", text: profile.login),
                                  email: TitledOptionalText(title: emailTitle, maybeText: profile.email),
                                  phone: TitledOptionalText(title: "Телефон", maybeText: profile.phone),
                                  myOrders: "Мои заказы")

        case .loadingError, .isLoading:
          return nil
        }
      }
      .distinctUntilChanged()
      .asDriverIgnoringError()
    }
  }
}
