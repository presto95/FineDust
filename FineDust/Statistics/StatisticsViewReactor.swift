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
    case setTotalFineDustIntake([CGFloat])
    case setTotalUltrafineDustIntake([CGFloat])
    case setTodayFineDustIntake(Int)
    case setTodayUltrafineDustIntake(Int)
  }
  
  struct State {
    var isPresented: Bool = false
    var isLoading: Bool = false
    var segmentedControlIndex: Int = 0
    var totalFineDustIntake: [CGFloat] = [CGFloat](repeating: 1, count: 7)
    var totalUltrafineDustIntake: [CGFloat] = [CGFloat](repeating: 1, count: 7)
    var todayFineDustIntake: Int = 1
    var todayUltrafineDustIntake: Int = 1
  }
  
  let initialState = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidAppear:
      return Observable.just(Mutation.setPresentationStatus(true))
    case let .changeSegmentedControlIndex(index):
      return Observable.just(Mutation.setSegmentedControlIndex(index))
    case .handleLocation:
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setPresentationStatus(isPresented):
      state.isPresented = isPresented
      return state
    case let .setTotalFineDustIntake(totalFineDustIntake):
      state.totalFineDustIntake = totalFineDustIntake
      return state
    case let .setSegmentedControlIndex(index):
      state.segmentedControlIndex = index
      return state
    case let .setTotalUltrafineDustIntake(totalUltrafineDustIntake):
      state.totalUltrafineDustIntake = totalUltrafineDustIntake
      return state
    case let .setTodayFineDustIntake(todayFineDustIntake):
      state.todayFineDustIntake = todayFineDustIntake
      return state
    case let .setTodayUltrafineDustIntake(todayUltrafineDustIntake):
      state.todayUltrafineDustIntake = todayUltrafineDustIntake
      return state
    case let .setLoadingStatus(isLoading):
      state.isLoading = isLoading
      return state
    }
  }
}
//
//extension StatisticsViewReactor: LocationObserver {
//  func handleIfFail(_ notification: Notification) {
//    <#code#>
//  }
//
//  func handleIfAuthorizationDenied(_ notification: Notification) {
//    <#code#>
//  }
//
//  func registerLocationObserver() {
//    <#code#>
//  }
//
//  func unregisterLocationObserver() {
//    <#code#>
//  }
//
//
//  func handleIfSuccess(_ notification: Notification) {
//    // 탭바 컨트롤러의 현재 뷰컨트롤러가 해당 뷰컨트롤러일 때만 노티피케이션 성공 핸들러 로직을 수행함
//
//  }
//}

extension StatisticsViewReactor {
  
  private func requestIntake() {
    
  }
}
