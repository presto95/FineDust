//
//  StatisticsViewReactor.swift
//  FineDust
//
//  Created by Presto on 21/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

/// 통계 뷰 컨트롤러 리액터.
final class StatisticsViewControllerReactor: Reactor {
  
  /// 초기 상태.
  let initialState = State()
  
  /// 흡입량 서비스.
  let intakeService: IntakeServiceType
  
  // MARK: Dependency Injection
  
  init(intakeService: IntakeServiceType = IntakeService()) {
    self.intakeService = intakeService
  }
  
  // MARK: Action
  
  enum Action {
    
    case viewHasPresent
    
    case changeSegmentedControlIndex(Int)
    
    case handleLocationIfSuccess
    
    case handleLocationIfFail(Notification)
  }
  
  // MARK: Mutation
  
  enum Mutation {
    
    case setLoadingStatus(Bool)
    
    case setSegmentedControlIndex(Int)
    
    case setIntakes(totalFineDust: [Int],
      totalUltrafineDust: [Int],
      todayFineDust: Int,
      todayUltrafineDust: Int)
    
    case handleIfFail(Notification)
  }
  
  // MARK: State
  
  struct State {
    
    var hasRequested: Bool = false
    
    var isLoading: Bool = false
    
    var segmentedControlIndex: Int = 0
    
    var intakes: (totalFineDust: [Int],
      totalUltrafineDust: [Int],
      todayFineDust: Int,
      todayUltrafineDust: Int) = ([], [], 0, 0)
    
    var locationTaskError: LocationTaskError?
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewHasPresent, .handleLocationIfSuccess:
      return requestIntakeMutation().debug("request")
    case let .changeSegmentedControlIndex(index):
      return Observable.just(Mutation.setSegmentedControlIndex(index))
    case let .handleLocationIfFail(notification):
      return Observable.just(Mutation.handleIfFail(notification))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setLoadingStatus(isLoading):
      state.isLoading = isLoading
      return state
    case let .setSegmentedControlIndex(index):
      state.segmentedControlIndex = index
      return state
    case let .setIntakes(totalFineDust, totalUltrafineDust, todayFineDust, todayUltrafineDust):
      state.intakes = (totalFineDust, totalUltrafineDust, todayFineDust, todayUltrafineDust)
      return state
    case let .handleIfFail(notification):
      state.locationTaskError = notification.locationTaskError
      return state
    }
  }
}
