//
//  ProfileViewController.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxCocoa
import RxDataSources
import RxSwift

final class ProfileTableViewController: UIViewController, ProfileViewControllable {
  @IBOutlet private weak var tableView: UITableView!

  private let loadingIndicatorView = LoadingIndicatorView()
  private let errorMessageView = ErrorMessageView()

  private lazy var dataSource: RxTableViewSectionedAnimatedDataSource<Section> = {
    let makeCellForRowDataSource = TableViewHelper.makeCellForRowDataSource(vc: self)
    return RxTableViewSectionedAnimatedDataSource<Section>(configureCell: makeCellForRowDataSource)
  }()

  // MARK: View Events

  private let emailUpdateTap = PublishRelay<Void>()
  private let retryButtonTap = PublishRelay<Void>()

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

extension ProfileTableViewController {
  private func initialSetup() {
    tableView.isVisible = false

    loadingIndicatorView.isVisible = false

    errorMessageView.isVisible = false

    view.addStretchedToBounds(subview: loadingIndicatorView)
    view.addStretchedToBounds(subview: errorMessageView)
  }
}

// MARK: - BindableView

extension ProfileTableViewController: BindableView {
  func getOutput() -> ProfileViewOutput {
    .init(emailUpdateTap: ControlEvent(events: emailUpdateTap),
          retryButtonTap: ControlEvent(events: retryButtonTap))
  }

  func bindWith(_ input: ProfilePresenterOutput) {
    bindTableView(input.viewModel)

    input.isContentViewVisible.drive(tableView.rx.isVisible).disposed(by: disposeBag)

    input.isLoadingIndicatorVisible.drive(loadingIndicatorView.rx.isVisible).disposed(by: disposeBag)
    input.isLoadingIndicatorVisible.drive(loadingIndicatorView.indicatorView.rx.isAnimating).disposed(by: disposeBag)

    input.showError.emit(onNext: { [weak self] maybeViewModel in
      self?.errorMessageView.isVisible = (maybeViewModel != nil)

      if let viewModel = maybeViewModel {
        self?.errorMessageView.resetToEmptyState()

        self?.errorMessageView.setTitle(viewModel.title, buttonTitle: viewModel.buttonTitle, action: {
          self?.retryButtonTap.accept(Void())
        })
      }
    }).disposed(by: disposeBag)
  }

  private func bindTableView(_ viewModel: Driver<ProfileViewModel>) {
    // Преобразуем ProfileViewModel в представление, подходящее для TableView
    let sectionsSource = viewModel.map { viewModel -> [Section] in

      let emailItem: RowItem
      if let email = viewModel.email.model {
        emailItem = .email(TitledText(title: viewModel.email.title, text: email))
      } else {
        emailItem = .addEmail(viewModel.email.title)
      }

      let rowItems: [RowItem] = [
        .titleText(viewModel.firstName),
        .titleText(viewModel.lastName),
        .titleOptionalText(viewModel.middleName),
        .titleText(viewModel.login),
        .titleOptionalText(viewModel.phone),
        emailItem,
        .myOrders(viewModel.myOrders)
      ]

      return [Section(title: nil, items: rowItems)]
    }

    sectionsSource.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
  }
}

// MARK: - TableViewHelper

extension ProfileTableViewController {
  private enum TableViewHelper: Namespace {
    static func makeCellForRowDataSource(vc: ProfileTableViewController)
      -> RxTableViewSectionedAnimatedDataSource<Section>.ConfigureCell {
      return { _, _, _, item -> UITableViewCell in
        switch item {
        case .titleText:
          return UITableViewCell()
        case .titleOptionalText:
          return UITableViewCell()
        case .addEmail:
          return UITableViewCell()
        case .email(let email):
          return UITableViewCell()
        case .myOrders:
          return UITableViewCell()
        }
      }
    }
  }
}

// MARK: Section & Row Item

extension ProfileTableViewController {
  private struct Section: Hashable, AnimatableSectionModelType {
    var title: String?
    var items: [RowItem]

    var identity: String = "SingleSection" // т.к секция одна то уникальный id ей не нужен

    init(original: Section, items: [RowItem]) {
      self = original
      self.items = items
    }

    init(title: String?, items: [RowItem]) {
      self.title = title
      self.items = items
    }

    typealias Item = RowItem
  }

  private enum RowItem: Hashable, IdentifiableType {
    case titleText(TitledText)
    case titleOptionalText(TitledModel<String?>)
    case addEmail(String)
    case email(TitledText)
    case myOrders(String)

    var identity: String {
      switch self {
      case .titleText(let viewModel): return viewModel.title
      case .titleOptionalText(let viewModel): return viewModel.title
      case .addEmail(let message): return message
      case .email(let viewModel): return viewModel.title
      case .myOrders(let text): return text
      }
    }
  }
}

// MARK: - RibStoryboardInstantiatable

extension ProfileTableViewController: RibStoryboardInstantiatable {}
