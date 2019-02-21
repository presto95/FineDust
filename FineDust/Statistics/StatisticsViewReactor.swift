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

final class StatisticsViewReactor: Reactor {
  
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
    case setHasViewPresented(Bool)
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
    var hasViewPresented: Bool = false
    var isLoading: Bool = false
    var segmentedControlIndex: Int = 0
    var intakes: (totalFineDust: [Int],
      totalUltrafineDust: [Int],
      todayFineDust: Int,
      todayUltrafineDust: Int) = ([], [], 0, 0)
    var locationTaskError: LocationTaskError?
  }
  
  let initialState = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewHasPresent:
      return Observable.concat([
        Observable.just(Mutation.setHasViewPresented(true)),
        Observable.just(Mutation.setLoadingStatus(true)),
        requestIntake()
          .catchErrorJustReturn([([], 0)])
          .map {
            Mutation
              .setIntakes(totalFineDust: $0[0].0,
                          totalUltrafineDust: $0[1].0,
                          todayFineDust: $0[0].1,
                          todayUltrafineDust: $0[1].1)
        }
        .take(1),
        Observable.just(Mutation.setLoadingStatus(false))
        ]).debug("mutation viewHasPresent")
    case let .changeSegmentedControlIndex(index):
      return Observable.just(Mutation.setSegmentedControlIndex(index))
    case .handleLocationIfSuccess:
      return Observable.concat([
        Observable.just(Mutation.setLoadingStatus(true)),
        requestIntake()
          .retry()
          .map { Mutation.setIntakes(totalFineDust: $0[0].0,
                                     totalUltrafineDust: $0[1].0,
                                     todayFineDust: $0[0].1,
                                     todayUltrafineDust: $0[1].1)
            
        }
        .take(1),
        Observable.just(Mutation.setLoadingStatus(false))
        ])
    case let .handleLocationIfFail(notification):
      return Observable.just(Mutation.handleIfFail(notification))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setHasViewPresented(isPresented):
      state.hasViewPresented = isPresented
      return state
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

// MARK: - Private Method

extension StatisticsViewReactor {
  
  private func requestIntake() -> Observable<[([Int], Int)]> {
    let requestIntakesInWeekObservable = Observable<([Int], [Int])>.create { emitter in
      self.intakeService.requestIntakesInWeek { fineDusts, ultrafineDusts, error in
        if let error = error {
          emitter.onError(error)
          return
        }
        guard let fineDusts = fineDusts, let ultrafineDusts = ultrafineDusts else {
          emitter.onCompleted()
          return
        }
        emitter.onNext((fineDusts, ultrafineDusts))
      }
      return Disposables.create()
    }
    let requestTodayIntakesObservable = Observable<(Int, Int)>.create { emitter in
      self.intakeService.requestTodayIntake { fineDust, ultrafineDust, error in
        if let error = error {
          emitter.onError(error)
          return
        }
        guard let fineDust = fineDust, let ultrafineDust = ultrafineDust else {
          emitter.onCompleted()
          return
        }
        emitter.onNext((fineDust, ultrafineDust))
      }
      return Disposables.create()
    }
    let zipped = Observable
      .zip(requestIntakesInWeekObservable,
           requestTodayIntakesObservable) { (week, today) -> [([Int], Int)] in
            return [(week.0, today.0), (week.1, today.1)]
    }
    return zipped
  }
}
