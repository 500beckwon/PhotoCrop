//
//  PhotoCropUITests.swift
//  PhotoCropUITests
//
//  Created by ByungHoon Ann on 2023/01/31.
//

import XCTest

final class PhotoCropUITests: XCTestCase {

    override func setUpWithError() throws {

        // 실패가 발생해도 계속 진행시킬 것인지 여부 false = 정지, true = 계속 진행
        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
