//
//  RatioGraphView.swift
//  FineDust
//
//  Created by Presto on 22/01/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

import UIKit

/// 비율 그래프 뷰.
final class RatioGraphView: UIView {
  
  // MARK: Constant
  
  /// 상수 정리.
  enum Constant {
    
    /// 레이어 선 두께.
    static let lineWidth: CGFloat = 10.0
  }
  
  // MARK: Delegate
  
  /// Ratio Graph View Data Source.
  weak var dataSource: RatioGraphViewDataSource?
  
  // MARK: Private Properties
  
  /// 전체에 대한 부분의 비율.
  private var ratio: CGFloat {
    return dataSource?.intakeRatio ?? .leastNonzeroMagnitude
  }
  
  /// 비율을 각도로 변환.
  private var endAngle: CGFloat {
    return ratio * 2 * .pi - .pi / 2
  }
  
  /// 배경 뷰 높이.
  private var backgroundViewHeight: CGFloat {
    return backgroundView.bounds.height * 0.7
  }
  
  // MARK: IBOutlet
  
  /// 배경 뷰.
  @IBOutlet private weak var backgroundView: UIView!
  
  // MARK: View
  
  /// 퍼센트 레이블.
  private lazy var percentLabel: FDCountingLabel = {
    let label = FDCountingLabel()
    label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
    label.translatesAutoresizingMaskIntoConstraints = false
    backgroundView.addSubview(label)
    NSLayoutConstraint.activate([
      label.anchor.centerX.equal(to: backgroundView.anchor.centerX),
      label.anchor.centerY.equal(to: backgroundView.anchor.centerY)
      ])
    return label
  }()
  
  /// 타이머.
  private var timer: Timer?
  
  // MARK: Method
  
  /// 뷰 전체 설정.
  func setup() {
    deinitializeElements()
    drawRatioGraph()
    setPercentLabel()
  }
}

// MARK: - View Drawing

private extension RatioGraphView {
  
  /// 서브뷰 초기화.
  func deinitializeElements() {
    timer?.invalidate()
    backgroundView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
  }
  
  /// 비율 원 그래프 그리기.
  func drawRatioGraph() {
    let path = UIBezierPath(arcCenter: .init(x: backgroundView.bounds.width / 2,
                                             y: backgroundView.bounds.height / 2),
                            radius: backgroundViewHeight / 2,
                            startAngle: -.pi / 2,
                            endAngle: .pi * 3 / 2,
                            clockwise: true)
    // 전체 레이어
    let entireLayer = CAShapeLayer()
    entireLayer.path = path.cgPath
    entireLayer.lineWidth = Constant.lineWidth
    entireLayer.fillColor = UIColor.clear.cgColor
    entireLayer.strokeColor = Asset.graph1.color.cgColor
    backgroundView.layer.addSublayer(entireLayer)
    // 부분 레이어
    let portionLayer = CAShapeLayer()
    portionLayer.path = path.cgPath
    portionLayer.lineWidth = Constant.lineWidth
    portionLayer.fillColor = UIColor.clear.cgColor
    portionLayer.strokeColor = Asset.graphToday.color.cgColor
    portionLayer.strokeEnd = 0
    backgroundView.layer.addSublayer(portionLayer)
    // 부분 레이어에 애니메이션
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    animation.fromValue = 0
    animation.toValue = ratio
    animation.duration = 1
    portionLayer.strokeEnd = ratio
    portionLayer.add(animation, forKey: animation.keyPath)
  }
  
  /// 비어 있는 원 안에 퍼센트 레이블 설정하기.
  func setPercentLabel() {
    let endValue = Int(ratio * 100)
    let interval = 1.0 / Double(endValue)
    backgroundView.addSubview(percentLabel)
    percentLabel.countFromZero(to: endValue, unit: .percent, interval: interval)
  }
}
