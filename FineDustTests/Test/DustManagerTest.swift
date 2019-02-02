//
//  DustManagerTest.swift
//  FineDustTests
//
//  Created by Presto on 01/02/2019.
//  Copyright © 2019 boostcamp3rd. All rights reserved.
//

@testable import FineDust

import Foundation
import XCTest

class DustManagerTest: XCTestCase {
  
  // 올바른 XML 데이터(Data)에 대한 Status Code를 받아 success(00)이 아닐 때의 경우를 테스트해야 함
  
  let mockNetworkManager = MockNetworkManager()
  
  let url = URL(string: "http://www.asdf.com/")
  
  /// 관측소 데이터를 가져온 것을 테스트
  func test_fetchObservatory() {
    let dustManager = DustManager<ObservatoryResponse>()
    let json = """
    { "key": "keykey", "value": "valuevalue" }
    """
    mockNetworkManager.data = json.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = nil
    let expect = expectation(description: "test")
    dustManager.fetchObservatory { response, error in
      XCTAssertNil(response)
      XCTAssertNotNil(error)
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  /// 미세먼지 데이터를 가져온 것을 테스트
  func test_fetchDustInfo() {
    let dustManager = DustManager<DustResponse>()
    let json = """
    { "key": "keykey", "value": "valuevalue" }
    """
    mockNetworkManager.data = json.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = nil
    let expect = expectation(description: "test")
    dustManager.fetchDustInfo(term: .daily, numberOfRows: 1) { response, error in
      XCTAssertNil(response)
      XCTAssertNotNil(error)
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  /// 관측소 데이터가 없는 것을 테스트
  func test_fetchObservatory_noData() {
    let dustManager = DustManager<ObservatoryResponse>()
    mockNetworkManager.data = nil
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = nil
    let expect = expectation(description: "test")
    dustManager.fetchObservatory { response, error in
      XCTAssertNil(response)
      XCTAssertNil(error)
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  /// 미세먼지 데이터가 없는 것을 테스트
  func test_fetchDustInfo_noData() {
    let dustManager = DustManager<DustResponse>()
    mockNetworkManager.data = nil
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = nil
    let expect = expectation(description: "test")
    dustManager.fetchDustInfo(term: .daily, numberOfRows: 1) { response, error in
      XCTAssertNil(response)
      XCTAssertNil(error)
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  /// 관측소 호출 중 네트워킹 에러 발생을 테스트
  func test_fetchObservatory_httpError() {
    let dustManager = DustManager<ObservatoryResponse>()
    mockNetworkManager.data = nil
    mockNetworkManager.httpStatusCode = HTTPStatusCode.default
    mockNetworkManager.error = HTTPError.default
    let expect = expectation(description: "test")
    dustManager.fetchObservatory { response, error in
      XCTAssertNil(response)
      if let err = error as? HTTPError {
        XCTAssertEqual(err, HTTPError.default)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  /// 미세먼지 호출 중 네트워킹 에러 발생을 테스트
  func test_fetchDustInfo_httpError() {
    let dustManager = DustManager<DustResponse>()
    mockNetworkManager.data = nil
    mockNetworkManager.httpStatusCode = HTTPStatusCode.default
    mockNetworkManager.error = HTTPError.default
    let expect = expectation(description: "test")
    dustManager.fetchDustInfo(term: .daily, numberOfRows: 1) { response, error in
      XCTAssertNil(response)
      if let err = error as? HTTPError {
        XCTAssertEqual(err, HTTPError.default)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  /// 관측소 호출 중 응답 관련 에러 발생을 테스트
  func test_fetchObservatory_dustError() {
    let dustManager = DustManager<ObservatoryResponse>()
    let json = """
    { "key": "keykey", "value": "valuevalue" }
    """
    mockNetworkManager.data = json.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.accessDenied
    let expect = expectation(description: "test")
    dustManager.fetchObservatory { response, error in
      XCTAssertNil(response)
      if let err = error as? DustError {
        XCTAssertEqual(err, DustError.accessDenied)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  /// 미세먼지 호출 중 응답 관련 에러 발생을 테스트
  func test_fetchDustInfo_dustError() {
    let dustManager = DustManager<DustResponse>()
    let json = """
    { "key": "keykey", "value": "valuevalue" }
    """
    mockNetworkManager.data = json.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = DustError.accessDenied
    let expect = expectation(description: "test")
    dustManager.fetchDustInfo(term: .daily, numberOfRows: 1) { response, error in
      XCTAssertNil(response)
      if let err = error as? DustError {
        XCTAssertEqual(err, DustError.accessDenied)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_fetchObservatory_xmlError1() {
    let dustManager = DustManager<ObservatoryResponse>()
    let json = """
    { "key": "keykey", "value": "valuevalue" }
    """
    mockNetworkManager.data = json.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = XMLError.implementationIsMissing("asdf")
    let expect = expectation(description: "test")
    dustManager.fetchObservatory { response, error in
      XCTAssertNil(response)
      if let err = error as? XMLError {
        XCTAssertEqual(err, XMLError.implementationIsMissing("asdf"))
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func test_fetchObservatory_xmlError2() {
    let dustManager = DustManager<ObservatoryResponse>()
    let json = """
    { "key": "keykey", "value": "valuevalue" }
    """
    mockNetworkManager.data = json.data(using: .utf8)
    mockNetworkManager.httpStatusCode = HTTPStatusCode.success
    mockNetworkManager.error = XMLError.nodeHasNoValue
    let expect = expectation(description: "test")
    dustManager.fetchObservatory { response, error in
      XCTAssertNil(response)
      if let err = error as? XMLError {
        XCTAssertEqual(err, XMLError.nodeHasNoValue)
      }
      expect.fulfill()
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
}
