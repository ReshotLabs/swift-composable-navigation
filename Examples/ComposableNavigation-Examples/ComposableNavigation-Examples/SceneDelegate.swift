import UIKit
import SwiftUI
import ComposableNavigation
import ComposableArchitecture

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else {
			return
		}
		
		// 👉 Choose showcase 👈
		let showcase: Showcase = .advanced
		
		let window = UIWindow(windowScene: windowScene)
		window.rootViewController = makeRootViewController(
			with: readShowcaseForUITest() ?? showcase
		)
		self.window = window
		window.makeKeyAndVisible()
	}
	
	// MARK: - Showcases
	
	enum Showcase {
		case modal
		case stack
		case tabs
		case advanced
		case uiTest(UITest)
		
		enum UITest: String {
			case swipeDownModalSheet
			case swipeBackOnStackNavigation
			case changingTabs
		}
	}
	
	func makeRootViewController(with showcase: Showcase) -> UIViewController {
		switch showcase {
		case .modal:
			return ModalShowcase.makeView(Store(
				initialState: .init(),
				reducer: ModalShowcase.reducer,
				environment: .init()
			))
		case .stack:
			return StackShowcase.makeView(Store(
				initialState: .init(),
				reducer: StackShowcase.reducer,
				environment: .init()
			))
		case .tabs:
			return TabsShowcase.makeView(Store(
				initialState: .init(),
				reducer: TabsShowcase.reducer,
				environment: .init()
			))
		case .advanced:
			return AdvancedTabBar.makeView(Store(
				initialState: AdvancedTabBar.State(),
				reducer: AdvancedTabBar.reducer,
				environment: .init(countryProvider: .init())
			))
		case .uiTest(.swipeDownModalSheet):
			return SwipeDownModalSheet.makeView(Store(
				initialState: .init(),
				reducer: SwipeDownModalSheet.reducer,
				environment: .init()
			))
		case .uiTest(.swipeBackOnStackNavigation):
			return SwipeBackOnStackNavigation.makeView( Store(
				initialState: .init(),
				reducer: SwipeBackOnStackNavigation.reducer,
				environment: .init()
			))
		case .uiTest(.changingTabs):
			return ChangingTabs.makeView(Store(
				initialState: .init(),
				reducer: ChangingTabs.reducer,
				environment: .init()
			))
		}
	}
	
	// MARK: - Helper
	
	func readShowcaseForUITest() -> Showcase? {
		guard
			CommandLine.arguments.contains("-uiTest"),
			let showcaseString = CommandLine.arguments.last
		else {
			return nil
		}
		guard let showcase = Showcase.UITest(rawValue: showcaseString) else {
			fatalError("Can not parse showcase for UITest")
		}
		return .uiTest(showcase)
	}
}
