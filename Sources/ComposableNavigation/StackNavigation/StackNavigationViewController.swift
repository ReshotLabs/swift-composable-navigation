import UIKit
import ComposableArchitecture

/// A convenience UINavigationController implementation containing a `StackNavigationHandler`.
open class StackNavigationViewController<ViewProvider: ViewProviding>: UINavigationController {
	internal let navigationHandler: StackNavigationHandler<ViewProvider>
	
	open convenience init(
		store: Store<StackNavigation<ViewProvider.Item>.State, StackNavigation<ViewProvider.Item>.Action>,
		viewProvider: ViewProvider
	) {
		self.init(navigationHandler: StackNavigationHandler(store: store, viewProvider: viewProvider))
	}
	
	open init(navigationHandler: StackNavigationHandler<ViewProvider>) {
		self.navigationHandler = navigationHandler
		super.init(nibName: nil, bundle: nil)
		self.navigationHandler.setup(with: self)
	}
	
	open required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
