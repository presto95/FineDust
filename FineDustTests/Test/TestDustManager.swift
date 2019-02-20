//
//  TestDustManager.swift
//  FineDustTests
//
//  Created by Presto on 19/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

@testable import FineDust
import Foundation
import XCTest

class TestDustManager: XCTestCase {
  
  func test_init() {
    let dustManager = DustManager.shared
    XCTAssertNotNil(dustManager)
  }
}
