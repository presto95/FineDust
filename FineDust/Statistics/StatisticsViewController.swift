//
//  StatisticsViewController.swift
//  FineDust
//
//  Created by Presto on 22/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import RxViewController

/// 통계 관련 뷰 컨트롤러.
final class StatisticsViewController: UIViewController, StoryboardView {
  
  var disposeBag = DisposeBag()
  
  func bind(reactor: StatisticsViewReactor) {
    
    // 위치 정보 받아오기 성공 노티피케이션 바인드
//    NotificationCenter.default.rx.notification(.didSuccessUpdatingAllLocationTasks)
//      .map { _ in Reactor.Action.handleLocation }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
    
  
    // viewDidAppear 바인드
    rx.viewDidAppear
      .map { _ in Reactor.Action.viewDidAppear }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 세그먼티드 컨트롤 탭 바인드
    segmentedControl.rx.selectedSegmentIndex
      .map { Reactor.Action.changeSegmentedControlIndex($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    
    // viewDidAppear 상태 바인드.
    reactor.state.map { $0.isPresented }
      .filter { $0 }
      .subscribe(onNext: { isPresented in
        
      })
      .disposed(by: disposeBag)
    
    // 로딩 상태 바인드.
    reactor.state.map { $0.isLoading }
      .subscribe(onNext: { isLoading in
        print("로딩중????????", isLoading)
        if isLoading {
          ProgressIndicator.shared.show()
        } else {
          ProgressIndicator.shared.hide()
        }
      })
      .disposed(by: disposeBag)
    
    // 세그먼티드 컨트롤 인덱스 상태 바인드.
    reactor.state.map { $0.segmentedControlIndex }
      .subscribe(onNext: { index in
        self.initializeSubviews()
      })
    
    // 값 상태 바인드.
    reactor.state.map { $0.values }
      .subscribe(onNext: { totalFineDust, totalUltrafineDust, todayFineDust, todayUltrafineDust in
        print("바인딩~~~", totalFineDust, totalUltrafineDust, todayFineDust, todayUltrafineDust)
        self.fineDustTotalIntakes = totalFineDust
        self.ultrafineDustTotalIntakes = totalUltrafineDust
        self.todayFineDustIntake = todayFineDust
        self.todayUltrafineDustIntake = todayUltrafineDust
        //self.initializeSubviews()
      })
      .disposed(by: disposeBag)
  }
  
  /// CALayer 관련 상수 정의.
  enum Layer {
    
    /// 경계선 라운드 반지름.
    static let cornerRadius: CGFloat = 8.0
    
    /// 경계선 두께.
    static let borderWidth: CGFloat = 1.0
  }
  
  // MARK: IBOutlets
  
  /// 서브뷰 포함하는 스크롤 뷰.
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
    }
  }
  
  /// 미세먼지 / 초미세먼지 토글하는 세그먼티드 컨트롤.
  @IBOutlet private weak var segmentedControl: UISegmentedControl!
  
  /// 값 그래프 배경 뷰.
  @IBOutlet private weak var valueGraphBackgroundView: UIView! {
    didSet {
      valueGraphBackgroundView.layer.setBorder(
        color: Asset.graphBorder.color,
        width: Layer.borderWidth,
        radius: Layer.cornerRadius
      )
    }
  }
  
  /// 비율 그래프 배경 뷰.
  @IBOutlet private weak var ratioGraphBackgroundView: UIView! {
    didSet {
      ratioGraphBackgroundView.layer.setBorder(
        color: Asset.graphBorder.color,
        width: Layer.borderWidth,
        radius: Layer.cornerRadius
      )
    }
  }
  
  // MARK: View
  
  /// 값 그래프.
  private var valueGraphView: ValueGraphView! {
    didSet {
      valueGraphView.dataSource = self
    }
  }
  
  /// 비율 그래프.
  private var ratioGraphView: RatioGraphView! {
    didSet {
      ratioGraphView.dataSource = self
    }
  }
  
  // MARK: Property
  
  /// 화면이 표시가 되었는가.
  //private var isPresented: Bool = false
  
  /// 7일간의 미세먼지 흡입량 모음.
  private var fineDustTotalIntakes = [Int](repeating: 1, count: 7)
  
  /// 7일간의 초미세먼지 흡입량 모음.
  private var ultrafineDustTotalIntakes = [Int](repeating: 1, count: 7)
  
  /// 오늘의 미세먼지 흡입량.
  private var todayFineDustIntake: Int = 1
  
  /// 오늘의 초미세먼지 흡입량.
  private var todayUltrafineDustIntake: Int = 1
  
  /// 미세먼지의 전체에 대한 마지막 값의 비율
  private var fineDustLastValueRatio: Double {
    let reduced = fineDustTotalIntakes.reduce(0, +)
    let sum = reduced == 0 ? 1 : reduced
    let last = fineDustTotalIntakes.last ?? 1
    return Double(last) / Double(sum)
  }
  
  /// 초미세먼지의 전체에 대한 마지막 값의 비율
  private var ultrafineDustLastValueRatio: Double {
    let reduced = ultrafineDustTotalIntakes.reduce(0, +)
    let sum = reduced == 0 ? 1 : reduced
    let last = ultrafineDustTotalIntakes.last ?? 1
    return Double(last) / Double(sum)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createSubviews()
    setConstraintsToSubviews()
  }
}

// MARK: - ValueGraphView Delegate 구현

extension StatisticsViewController: ValueGraphViewDataSource {
  
  var intakes: [Int] {
    return segmentedControl.selectedSegmentIndex == 0
      ? fineDustTotalIntakes : ultrafineDustTotalIntakes
  }
}

// MARK: - RatioGraphView Delegate 구현

extension StatisticsViewController: RatioGraphViewDataSource {
  
  var intakeRatio: Double {
    return segmentedControl.selectedSegmentIndex == 0
      ? fineDustLastValueRatio : ultrafineDustLastValueRatio
  }
  
  var totalIntake: Int {
    let reducedFineDust = fineDustTotalIntakes.map { Int($0) }.reduce(0, +)
    let reducedUltrafineDust = ultrafineDustTotalIntakes.map { Int($0) }.reduce(0, +)
    return segmentedControl.selectedSegmentIndex == 0 ? reducedFineDust : reducedUltrafineDust
  }
  
  var todayIntake: Int {
    return segmentedControl.selectedSegmentIndex == 0
      ? todayFineDustIntake : todayUltrafineDustIntake
  }
}

// MARK: - Private Extension

private extension StatisticsViewController {
  
  /// 서브뷰 생성하여 프로퍼티에 할당.
  func createSubviews() {
    valueGraphView
      = UIView.instantiate(fromXib: ValueGraphView.classNameToString) as? ValueGraphView
    ratioGraphView
      = UIView.instantiate(fromXib: RatioGraphView.classNameToString) as? RatioGraphView
    valueGraphView.translatesAutoresizingMaskIntoConstraints = false
    ratioGraphView.translatesAutoresizingMaskIntoConstraints = false
    valueGraphBackgroundView.addSubview(valueGraphView)
    ratioGraphBackgroundView.addSubview(ratioGraphView)
  }
  
  /// 서브뷰에 오토레이아웃 설정.
  func setConstraintsToSubviews() {
    NSLayoutConstraint.activate([
      valueGraphView.anchor.top.equal(to: valueGraphBackgroundView.anchor.top),
      valueGraphView.anchor.leading.equal(to: valueGraphBackgroundView.anchor.leading),
      valueGraphView.anchor.trailing.equal(to: valueGraphBackgroundView.anchor.trailing),
      valueGraphView.anchor.bottom.equal(to: valueGraphBackgroundView.anchor.bottom),
      ratioGraphView.anchor.top.equal(to: ratioGraphBackgroundView.anchor.top),
      ratioGraphView.anchor.leading.equal(to: ratioGraphBackgroundView.anchor.leading),
      ratioGraphView.anchor.trailing.equal(to: ratioGraphBackgroundView.anchor.trailing),
      ratioGraphView.anchor.bottom.equal(to: ratioGraphBackgroundView.anchor.bottom)
      ])
  }
  
  /// 모든 서브뷰 초기화.
  func initializeSubviews() {
    initializeValueGraphView()
    initializeRatioGraphView()
  }
  
  /// 값 그래프 뷰 초기화.
  func initializeValueGraphView() {
    valueGraphView.setup()
  }
  
  /// 비율 그래프 뷰 초기화.
  func initializeRatioGraphView() {
    ratioGraphView.setup()
  }
}
