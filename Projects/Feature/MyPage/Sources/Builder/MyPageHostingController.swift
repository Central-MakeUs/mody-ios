//
//  MyPageHostingController.swift
//  MyPage
//
//  Created by 김동준 on 7/20/26.
//

import ComposableArchitecture
import CoreModyImageInterface
import MyPageInterface
import SwiftUI

final class MyPageHostingController: UIHostingController<MyPageView>, MyPageInputHandler {
    private let store: StoreOf<MyPageFeature>

    init(
        store: StoreOf<MyPageFeature>,
        imageLoader: RemoteImageLoading
    ) {
        self.store = store
        super.init(
            rootView: MyPageView(
                store: store,
                imageLoader: imageLoader
            )
        )
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handle(input: MyPageInput) {
        store.send(.input(input))
    }
}
