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
  private let myOrdersTap = PublishRelay<Void>()

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    initialSetup()
  }
}

extension ProfileTableViewController {
  private func initialSetup() {
    title = "TableView Profile"
    
    tableView.isVisible = false

    loadingIndicatorView.isVisible = false

    errorMessageView.isVisible = false

    view.addStretchedToBounds(subview: loadingIndicatorView)
    view.addStretchedToBounds(subview: errorMessageView)
    
    tableView.register(ContactFieldCell.self)
    tableView.register(DisclosureTextCell.self)
    
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    
    dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .fade,
                                                               reloadAnimation: .fade,
                                                               deleteAnimation: .fade)
  }
}

// MARK: - BindableView

extension ProfileTableViewController: BindableView {
  func getOutput() -> ProfileViewOutput {
    .init(emailUpdateTap: ControlEvent(events: emailUpdateTap),
          myOrdersTap: ControlEvent(events: myOrdersTap),
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

  /// Преобразуем ProfileViewModel в представление, подходящее для TableView
  private func bindTableView(_ viewModel: Driver<ProfileViewModel>) {
    let sectionsSource = viewModel.map { viewModel -> [Section] in

      let emailItem: RowItem
      if let email = viewModel.email.maybeText {
        emailItem = .email(TitledText(title: viewModel.email.title, text: email))
      } else {
        emailItem = .addEmail(viewModel.email.title)
      }

      let rowItems: [RowItem] = [
        .contactField(viewModel.firstName),
        .contactField(viewModel.lastName),
        .contactOptionalText(viewModel.middleName),
        .contactField(viewModel.login),
        .contactOptionalText(viewModel.phone),
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
      return { _, tableView, indexPath, item -> UITableViewCell in
        switch item {
        case .contactField(let viewModel):
          let cell: ContactFieldCell = tableView.dequeue(forIndexPath: indexPath)
          cell.view.setTitle(viewModel.title, text: viewModel.text)
          return cell
          
        case .contactOptionalText(let viewModel):
          let cell: ContactFieldCell = tableView.dequeue(forIndexPath: indexPath)
          cell.view.setTitle(viewModel.title, text: viewModel.maybeText)
          return cell
          
        case .addEmail(let title):
          let cell: DisclosureTextCell = tableView.dequeue(forIndexPath: indexPath)
          cell.view.setText(title)
          return cell
          
        case .email(let viewModel):
          let cell: ContactFieldCell = tableView.dequeue(forIndexPath: indexPath)
          cell.view.setTitle(viewModel.title, text: viewModel.text)
          return cell
          
        case .myOrders(let title):
          let cell: DisclosureTextCell = tableView.dequeue(forIndexPath: indexPath)
          cell.view.setText(title)
          return cell
        }
      }
    }
  }
}

extension ProfileTableViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let rowItem = dataSource[indexPath]

    switch rowItem {
    case .addEmail: emailUpdateTap.accept(Void())
    case .email: emailUpdateTap.accept(Void())
    case .contactField: break
    case .contactOptionalText: break
    case .myOrders: myOrdersTap.accept(Void())
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
    case contactField(TitledText)
    case contactOptionalText(TitledOptionalText)
    case addEmail(String)
    case email(TitledText)
    case myOrders(String)

    var identity: String {
      switch self {
      case .contactField(let viewModel): return viewModel.title
      case .contactOptionalText(let viewModel): return viewModel.title
      case .addEmail(let message): return message
      case .email(let viewModel): return viewModel.title
      case .myOrders(let text): return text
      }
    }
  }
}

// MARK: - RibStoryboardInstantiatable

extension ProfileTableViewController: RibStoryboardInstantiatable {}
