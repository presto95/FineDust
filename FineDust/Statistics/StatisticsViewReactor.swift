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
  
  let intakeService: IntakeServiceType
  
  init(intakeService: IntakeServiceType = IntakeService()) {
    self.intakeService = intakeService
  }
  
  enum Action {
    case viewDidAppear
    case changeSegmentedControlIndex(Int)
    case handleLocation
  }
  
  enum Mutation {
    case setPresentationStatus(Bool)
    case setLoadingStatus(Bool)
    case setSegmentedControlIndex(Int)
    case setValues(totalFineDust: [Int],
      totalUltrafineDust: [Int],
      todayFineDust: Int,
      todayUltrafineDust: Int)
  }
  
  struct State {
    var isPresented: Bool = false
    var isLoading: Bool = false
    var segmentedControlIndex: Int = 0
    var values: (totalFineDust: [Int],
      totalUltrafineDust: [Int],
      todayFineDust: Int,
      todayUltrafineDust: Int) = ([], [], 0, 0)
  }
  
  let initialState = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidAppear:
      return Observable.concat([
        Observable.just(Mutation.setPresentationStatus(true)),
        //Observable.just(Mutation.setLoadingStatus(true)),
        requestIntake().map { Mutation.setValues(totalFineDust: $0[0].0,
                                                 totalUltrafineDust: $0[1].0,
                                                 todayFineDust: $0[0].1,
                                                 todayUltrafineDust: $0[1].1) },
        //Observable.just(Mutation.setLoadingStatus(false))
        ])
    case let .changeSegmentedControlIndex(index):
      return Observable.just(Mutation.setSegmentedControlIndex(index))
    case .handleLocation:
      return Observable.concat([
        //Observable.just(Mutation.setLoadingStatus(true)),
        requestIntake().map { Mutation.setValues(totalFineDust: $0[0].0,
                                                 totalUltrafineDust: $0[1].0,
                                                 todayFineDust: $0[0].1,
                                                 todayUltrafineDust: $0[1].1) },
        //Observable.just(Mutation.setLoadingStatus(false))
        ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setPresentationStatus(isPresented):
      state.isPresented = isPresented
      return state
    case let .setLoadingStatus(isLoading):
      state.isLoading = isLoading
      return state
    case let .setSegmentedControlIndex(index):
      state.segmentedControlIndex = index
      return state
    case let .setValues(totalFineDust, totalUltrafineDust, todayFineDust, todayUltrafineDust):
      state.values = (totalFineDust, totalUltrafineDust, todayFineDust, todayUltrafineDust)
      return state
    }
  }
}

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
    let zipped
      = Observable
        .zip(requestIntakesInWeekObservable,
             requestTodayIntakesObservable) { (first, second) -> [([Int], Int)] in
      return [(first.0, second.0), (first.1, second.1)]
    }
    return zipped
  }
}
