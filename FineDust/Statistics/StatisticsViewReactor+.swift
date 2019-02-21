//
//  StatisticsViewReactor+.swift
//  FineDust
//
//  Created by Presto on 21/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

extension StatisticsViewControllerReactor {
  
  func requestIntakeMutation() -> Observable<Mutation> {
    return Observable.concat([
      Observable.just(Mutation.setLoadingStatus(true)),
      requestIntake()
        .retry(2)
        .catchErrorJustReturn([([], 0)])
        .map { Mutation.setIntakes(totalFineDust: $0[0].0,
                                   totalUltrafineDust: $0[1].0,
                                   todayFineDust: $0[0].1,
                                   todayUltrafineDust: $0[1].1)
          
        }
        .take(1),
      Observable.just(Mutation.setLoadingStatus(false))
      ])
  }
  
  func requestIntake() -> Observable<[([Int], Int)]> {
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

