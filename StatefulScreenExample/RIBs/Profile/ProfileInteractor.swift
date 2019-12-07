//
//  ProfileInteractor.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class ProfileInteractor: PresentableInteractor<ProfilePresentable>, ProfileInteractable {
  // MARK: Dependencies
  
  weak var router: ProfileRouting?
  
  private let profileService: ProfileService
  
  // MARK: Internals
  
  private let _state = BehaviorRelay<ProfileInteractorState>(value: .isLoading)
  
  private let didLoadProfile = PublishRelay<Profile>()
  private let profileLoadingError = PublishRelay<Error>()
  
  private let disposeBag = DisposeBag()
  
  init(presenter: ProfilePresentable,
       profileService: ProfileService) {
    self.profileService = profileService
    super.init(presenter: presenter)
  }
  
  override func didBecomeActive() {
    super.didBecomeActive()
    loadProfile()
  }
  
  private func loadProfile() {
    profileService.profile { [weak self] result in
      switch result {
      case .success(let profile): self?.didLoadProfile.accept(profile)
      case .failure(let error): self?.profileLoadingError.accept(error)
      }
    }
  }
}

// MARK: - IOTransformer

extension ProfileInteractor: IOTransformer {
  private typealias State = ProfileInteractorState
  
  func transform(_ input: ProfileViewOutput) -> Observable<ProfileInteractorState> {
    let readonlyState = _state.asObservable()
    
    let profileRequest: VoidClosure = { [weak self] in self?.loadProfile() }
    
    StateTransform.fromLoadingErrorToIsLoading(readonlyState: readonlyState,
                                               retryButtonTap: input.retryButtonTap,
                                               stateEntryAction: profileRequest,
                                               bindTo: _state,
                                               disposedBy: disposeBag)
    
    StateTransform.fromIsLoadingToLoadingError(readonlyState: readonlyState,
                                               profileLoadingError: profileLoadingError.asObservable(),
                                               bindTo: _state,
                                               disposedBy: disposeBag)
    
    StateTransform.fromIsLoadingToDataLoaded(readonlyState: readonlyState,
                                             didLoadProfile: didLoadProfile.asObservable(),
                                             bindTo: _state,
                                             disposedBy: disposeBag)
    
    bindRouting(input, readonlyState: readonlyState)
    
    return readonlyState
  }
  
  private func bindRouting(_ viewOutput: ProfileViewOutput, readonlyState: Observable<State>) {
    viewOutput.emailUpdateTap.withLatestFrom(readonlyState).subscribe(onNext: { [weak self] state in
      switch state {
      case .dataLoaded(let profile):
        if profile.email == nil {
          // Если email'a ещё ещё нет - добавляем его
          self?.router?.routeToEmailAddition()
        } else {
          // Ессли уже есть - меняем
          self?.router?.routeToEmailChange()
        }
      default: break
      }
    }).disposed(by: disposeBag)
    
    viewOutput.myOrdersTap.withLatestFrom(readonlyState).subscribe(onNext: { [weak self] state in
      switch state {
      case .dataLoaded:
        self?.router?.routeToOrdersList()
      default: break
      }
    }).disposed(by: disposeBag)
  }
}

extension ProfileInteractor {
  /// StateTransform реализует переходы между всеми состояниями
  private enum StateTransform: Namespace {
    static func fromLoadingErrorToIsLoading(readonlyState: Observable<ProfileInteractorState>,
                                            retryButtonTap: ControlEvent<Void>,
                                            stateEntryAction: @escaping () -> Void,
                                            bindTo _state: BehaviorRelay<State>,
                                            disposedBy disposeBag: DisposeBag) {
      let fromLoadingErrorToIsLoading = retryButtonTap.filteredByState(readonlyState) { state in
        switch state {
        case .loadingError: return true
        default: return false
        }
      }
      .do(onNext: stateEntryAction)
      .map { State.isLoading }
      
      fromLoadingErrorToIsLoading.bind(to: _state).disposed(by: disposeBag)
    }
    
    static func fromIsLoadingToLoadingError(readonlyState: Observable<ProfileInteractorState>,
                                            profileLoadingError: Observable<Error>,
                                            bindTo _state: BehaviorRelay<State>,
                                            disposedBy disposeBag: DisposeBag) {
      let fromIsLoadingToLoadingError = profileLoadingError.filteredByState(readonlyState) { state in
        switch state {
        case .isLoading: return true
        default: return false
        }
      }
      .map { error in State.loadingError(error) }
      
      fromIsLoadingToLoadingError.bind(to: _state).disposed(by: disposeBag)
    }
    
    static func fromIsLoadingToDataLoaded(readonlyState: Observable<ProfileInteractorState>,
                                          didLoadProfile: Observable<Profile>,
                                          bindTo _state: BehaviorRelay<State>,
                                          disposedBy disposeBag: DisposeBag) {
      let fromIsLoadingToDataLoaded = didLoadProfile.filteredByState(readonlyState) { state in
        switch state {
        case .isLoading: return true
        default: return false
        }
      }
      .map { profile in State.dataLoaded(profile) }
      
      fromIsLoadingToDataLoaded.bind(to: _state).disposed(by: disposeBag)
    }
  }
}
