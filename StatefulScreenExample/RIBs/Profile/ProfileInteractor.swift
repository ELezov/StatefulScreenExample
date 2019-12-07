//
//  ProfileInteractor.swift
//  StatefulScreenExample
//
//  Created by Dmitriy Ignatyev on 07.12.2019.
//  Copyright © 2019 IgnatyevProd. All rights reserved.
//

import RIBs
import RxSwift

final class ProfileInteractor: PresentableInteractor<ProfilePresentable>, ProfileInteractable {
  // MARK: Dependencies
  weak var router: ProfileRouting?
  
  private let profileService: ProfileService
  
  // MARK: Internals
  

  init(presenter: ProfilePresentable,
                profileService: ProfileService) {
    self.profileService = profileService
    super.init(presenter: presenter)
  }

  override func didBecomeActive() {
    super.didBecomeActive()
  }
  
  private func loadProfile() {
    
  }
}

// MARK: - IOTransformer

extension ProfileInteractor: IOTransformer {
  func transform(_ input: ProfileViewOutput) -> ProfileInteractorOutput {
    
    return ProfileInteractorOutput()
  }
}
