import XCTest
@testable import Coordinator

class HomeCoordinator: Coordinator {

    func goToProfile() {
        startChild(ProfileCoordinator(), modal: true, animated: false)
    }
}

class ProfileCoordinator: Coordinator {
    init() {
        super.init(value: Configuration(initialView: UIViewController()))
    }
}

final class CoordinatorTests: XCTestCase {

    func testStartingChildAddChildToTree() {
        let homeNavigation = HomeCoordinator(value: Configuration(initialView: UIViewController()))
        homeNavigation.goToProfile()
        let count = homeNavigation.children.count
        XCTAssert(count == 1)
    }

    static var allTests = [
        ("Starting child coordinator adds it to tree", testStartingChildAddChildToTree),
    ]
}
