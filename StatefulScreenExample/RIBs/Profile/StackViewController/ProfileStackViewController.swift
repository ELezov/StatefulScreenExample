//
//  ProfileViewController.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxSwift

final class ProfileStackViewController: UIViewController, ProfileViewControllable {
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var stackView: UIStackView!
  
  private let firstNameView = ContactFieldView.loadFromNib()
  private let lastNameView = ContactFieldView.loadFromNib()
  private let middleNameView = ContactFieldView.loadFromNib()
  private let loginView = ContactFieldView.loadFromNib()
  private let phoneView = ContactFieldView.loadFromNib()
  
  private let emailView = ContactFieldView.loadFromNib()
  private let addEmailView = DisclosureTextView.loadFromNib()
  
  private let myOrdersView = DisclosureTextView.loadFromNib()
  
  // Service Views
  private let loadingIndicatorView = LoadingIndicatorView()
  private let errorMessageView = ErrorMessageView()
  
  // MARK: View Events
  
  private let emailUpdateTap = PublishRelay<Void>()
  private let retryButtonTap = PublishRelay<Void>()
  private let myOrdersTap = PublishRelay<Void>()
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

extension ProfileStackViewController {
  private func initialSetup() {
    scrollView.isVisible = false
    
    loadingIndicatorView.isVisible = false
    
    errorMessageView.isVisible = false
    
    view.addStretchedToBounds(subview: loadingIndicatorView)
    view.addStretchedToBounds(subview: errorMessageView)
    
    stackView.addArrangedSubviews([
      firstNameView,
      lastNameView,
      middleNameView,
      loginView,
      phoneView,
      emailView,
      addEmailView,
      myOrdersView
    ])
    
    tapGesturesInitialSetup()
  }
  
  private func tapGesturesInitialSetup() {
    do {
      let tapGesture = UITapGestureRecognizer()
      emailView.addGestureRecognizer(tapGesture)
      tapGesture.rx.event.mapAsVoid().bind(to: emailUpdateTap).disposed(by: disposeBag)
    }
    
    do {
      let tapGesture = UITapGestureRecognizer()
      addEmailView.addGestureRecognizer(tapGesture)
      tapGesture.rx.event.mapAsVoid().bind(to: emailUpdateTap).disposed(by: disposeBag)
    }
    
    do {
      let tapGesture = UITapGestureRecognizer()
      myOrdersView.addGestureRecognizer(tapGesture)
      tapGesture.rx.event.mapAsVoid().bind(to: myOrdersTap).disposed(by: disposeBag)
    }
  }
}

// MARK: - BindableView

extension ProfileStackViewController: BindableView {
  func getOutput() -> ProfileViewOutput {
    .init(emailUpdateTap: ControlEvent(events: emailUpdateTap),
          myOrdersTap: ControlEvent(events: myOrdersTap),
          retryButtonTap: ControlEvent(events: retryButtonTap))
  }
  
  func bindWith(_ input: ProfilePresenterOutput) {
    bindViewModel(input.viewModel)
    
    input.isContentViewVisible.drive(scrollView.rx.isVisible).disposed(by: disposeBag)
    
    input.isLoadingIndicatorVisible.drive(loadingIndicatorView.rx.isVisible).disposed(by: disposeBag)
    input.isLoadingIndicatorVisible.drive(loadingIndicatorView.indicatorView.rx.isAnimating).disposed(by: disposeBag)
    
    input.showError.emit(onNext: { [unowned self] maybeViewModel in
      self.errorMessageView.isVisible = (maybeViewModel != nil)
      
      if let viewModel = maybeViewModel {
        self.errorMessageView.resetToEmptyState()
        
        self.errorMessageView.setTitle(viewModel.title, buttonTitle: viewModel.buttonTitle, action: {
          self.retryButtonTap.accept(Void())
        })
      }
    }).disposed(by: disposeBag)
  }
  
  private func bindViewModel(_ profileViewModel: Driver<ProfileViewModel>) {
    profileViewModel.map { $0.firstName }.drive(onNext: { [unowned self] viewModel in
      self.firstNameView.setTitle(viewModel.title, text: viewModel.text)
    }).disposed(by: disposeBag)
    
    profileViewModel.map { $0.lastName }.drive(onNext: { [unowned self] viewModel in
      self.lastNameView.setTitle(viewModel.title, text: viewModel.text)
    }).disposed(by: disposeBag)
    
    profileViewModel.map { $0.middleName }.drive(onNext: { [unowned self] viewModel in
      self.middleNameView.setTitle(viewModel.title, text: viewModel.maybeText)
    }).disposed(by: disposeBag)
    
    profileViewModel.map { $0.login }.drive(onNext: { [unowned self] viewModel in
      self.loginView.setTitle(viewModel.title, text: viewModel.text)
    }).disposed(by: disposeBag)
    
    profileViewModel.map { $0.phone }.drive(onNext: { [unowned self] viewModel in
      self.phoneView.setTitle(viewModel.title, text: viewModel.maybeText)
    }).disposed(by: disposeBag)
    
    profileViewModel.map { $0.email }.drive(onNext: { [unowned self] viewModel in
      if let email = viewModel.maybeText {
        self.emailView.setTitle(viewModel.title, text: email)
        self.emailView.isVisible = true
        self.addEmailView.isVisible = false
      } else {
        self.addEmailView.setText(viewModel.title)
        self.addEmailView.isVisible = true
        self.emailView.isVisible = false
      }
    }).disposed(by: disposeBag)
    
    profileViewModel.map { $0.myOrders }.drive(onNext: { [unowned self] title in
      self.myOrdersView.setText(title)
    }).disposed(by: disposeBag)
  }
}

// MARK: - RibStoryboardInstantiatable

extension ProfileStackViewController: RibStoryboardInstantiatable {}
