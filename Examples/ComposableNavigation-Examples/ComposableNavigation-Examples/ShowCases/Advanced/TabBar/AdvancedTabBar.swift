import UIKit
import SwiftUI
import ComposableNavigation
import ComposableArchitecture

struct AdvancedTabBar: ReducerProtocol {
	
	// MARK: TCA
	
	enum Screen: CaseIterable {
		case deepLink
		case listAndDetail
		case alertPlayground
	}
	
	struct State: Equatable {
		var deepLink = CountryDeepLink.State()
		var listAndDetail = CountryListAndDetail.State()
		var alertPlayground = AlertPlayground.State()
		
		var tabNavigation = TabNavigation<Screen>.State(
			items: Screen.allCases,
			activeItem: .listAndDetail
		)
	}
	
	enum Action: Equatable {
		case deepLink(CountryDeepLink.Action)
		case listAndDetail(CountryListAndDetail.Action)
		case alertPlayground(AlertPlayground.Action)
		case tabNavigation(TabNavigation<Screen>.Action)
	}
	
	let countryProvider: CountryProvider
	
	private var privateReducer: Reduce<State, Action> {
		.init { state, action in
			switch action {
			case .deepLink(.showSorting):
				return .run { send in
					await send(.tabNavigation(.setActiveItem(.listAndDetail)))
					await send(.listAndDetail(.stackNavigation(.setItems([.list]))))
					await send(.listAndDetail(.modalNavigation(.set(.init(item: .sort, style: .pageSheet)))))
				}
			case .deepLink(.showSortingReset):
				return .run { send in
					await send(.tabNavigation(.setActiveItem(.listAndDetail)))
					await send(.listAndDetail(.stackNavigation(.setItems([.list]))))
					await send(.listAndDetail(.modalNavigation(.set(.init(item: .sort, style: .pageSheet)))))
					await send(.listAndDetail(.countrySort(.alertNavigation(.set(.init(item: .resetAlert, style: .fullScreen))))))
				}
			case .deepLink(.showCountry(let countryId)):
				return .run { send in
					await send(.tabNavigation(.setActiveItem(.listAndDetail)))
					await send(.listAndDetail(.stackNavigation(.setItems([.list, .detail(id: countryId)]))))
				}
			case .deepLink(.showAlertOptions):
				return .run { send in
					await send(.tabNavigation(.setActiveItem(.alertPlayground)))
					await send(.alertPlayground(.alertNavigation(.set(.init(item: .actionSheet, style: .fullScreen)))))
				}
			default:
				break
			}
			return .none
		}
	}
	
	var body: some ReducerProtocol<State, Action> {
		Scope(state: \.deepLink, action: /Action.deepLink) {
			CountryDeepLink()
		}
		Scope(state: \.listAndDetail, action: /Action.listAndDetail) {
			CountryListAndDetail(countryProvider: countryProvider)
		}
		Scope(state: \.alertPlayground, action: /Action.alertPlayground) {
			AlertPlayground()
		}
		Scope(state: \.tabNavigation, action: /Action.tabNavigation) {
			TabNavigation<Screen>()
		}
		privateReducer
	}
	
	// MARK: View creation
	
	struct ViewProvider: ViewProviding {
		let store: Store<State, Action>
		
		func makePresentable(for navigationItem: Screen) -> Presentable {
			switch navigationItem {
			case .deepLink:
				let viewController = CountryDeepLinkView(
					store: store.scope(
						state: \.deepLink,
						action: Action.deepLink
					)
				).viewController
				viewController.tabBarItem = UITabBarItem(
					title: "Deep link",
					image: UIImage(systemName: "link"),
					tag: 0
				)
				return viewController

			case .listAndDetail:
				let listAndDetailStore = store.scope(
					state: \.listAndDetail,
					action: Action.listAndDetail
				)
				ViewStore(listAndDetailStore).send(.loadCountries)
				let stackNavigationController = StackNavigationViewController(
					store: listAndDetailStore.scope(
						state: \.stackNavigation,
						action: CountryListAndDetail.Action.stackNavigation
					),
					viewProvider: CountryListAndDetail.StackViewProvider(store: listAndDetailStore)
				)
				stackNavigationController.navigationBar.prefersLargeTitles = true
				let viewController = stackNavigationController
					.withModal(
						store: listAndDetailStore.scope(
							state: \.modalNavigation,
							action: CountryListAndDetail.Action.modalNavigation
						),
						viewProvider: CountryListAndDetail.ModalViewProvider(store: listAndDetailStore)
					)
				viewController.tabBarItem = UITabBarItem(
					title: "List",
					image: UIImage(systemName: "list.dash"),
					tag: 1
				)
				return viewController
				
			case .alertPlayground:
				let alertPlaygroundStore = store.scope(
					state: \.alertPlayground,
					action: Action.alertPlayground
				)
				let viewController = AlertPlaygroundView(store: alertPlaygroundStore).viewController
					.withModal(
						store: alertPlaygroundStore.scope(
							state: \.alertNavigation,
							action: AlertPlayground.Action.alertNavigation
						),
						viewProvider: AlertPlayground.ModalViewProvider(store: alertPlaygroundStore)
					)
				viewController.tabBarItem = UITabBarItem(
					title: "Alerts",
					image: UIImage(systemName: "exclamationmark.bubble"),
					tag: 2
				)
				return viewController
			}
		}
	}
	
	static func makeView(_ store: Store<State, Action>) -> UIViewController {
		return TabNavigationViewController(
			store: store.scope(
				state: \.tabNavigation,
				action: Action.tabNavigation
			),
			viewProvider: ViewProvider(store: store)
		)
	}
}
