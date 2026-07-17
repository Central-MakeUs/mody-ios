//
//  FeedRecordPhotoSourceSheetView.swift
//  Feed
//
//  Created by 김동준 on 7/15/26.
//

import SwiftUI
import DesignSystem

struct FeedRecordPhotoSourceSheetView: View {
    private let onCameraTap: () -> Void
    private let onGalleryTap: () -> Void

    init(
        onCameraTap: @escaping () -> Void,
        onGalleryTap: @escaping () -> Void
    ) {
        self.onCameraTap = onCameraTap
        self.onGalleryTap = onGalleryTap
    }

    var body: some View {
        VStack(spacing: 4) {
            sourceButton(
                title: "사진 촬영하기",
                image: .icCamera,
                action: onCameraTap
            )

            Rectangle()
                .fill(Color.gray1)
                .frame(height: 1)
                .padding(.horizontal, 24)

            sourceButton(
                title: "갤러리에서 선택하기",
                image: .icGallery,
                action: onGalleryTap
            )

            Spacer()
        }
        .padding(.top, 38)
        .background(Color.systemWhite)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

private extension FeedRecordPhotoSourceSheetView {
    func sourceButton(
        title: String,
        image: Image,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                image
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray10)
                    .frame(width: 24, height: 24)

                MText(
                    title,
                    style: .b4,
                    color: .gray10,
                    alignment: .leading
                )

                Spacer()
            }
            .vPadding(12)
            .hPadding(24)
        }
    }
}
