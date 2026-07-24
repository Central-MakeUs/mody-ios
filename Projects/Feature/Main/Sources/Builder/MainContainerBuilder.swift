//
//  MainContainerBuilder.swift
//  Main
//
//  Created by 김동준 on 7/24/26.
//

@MainActor
protocol MainContainerBuildable {
    func makeMainContainerViewController(
        tabBarController: MainTabBarController,
        tabs: [MainTab]
    ) -> MainContainerViewController
}

struct MainContainerBuilder: MainContainerBuildable {
    private let makeMainReactor: () -> MainReactor

    init(makeMainReactor: @escaping () -> MainReactor) {
        self.makeMainReactor = makeMainReactor
    }

    func makeMainContainerViewController(
        tabBarController: MainTabBarController,
        tabs: [MainTab]
    ) -> MainContainerViewController {
        MainContainerViewController(
            tabBarController: tabBarController,
            tabs: tabs,
            reactor: makeMainReactor()
        )
    }
}
