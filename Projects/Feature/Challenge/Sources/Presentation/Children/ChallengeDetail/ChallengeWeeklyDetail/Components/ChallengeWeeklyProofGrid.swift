//
//  ChallengeWeeklyProofGrid.swift
//  Challenge
//
//  Created by 김동준 on 8/13/26.
//

import CoreModyImageInterface
import DesignSystem
import SwiftUI

struct ChallengeWeeklyProofGrid: View {
    private let itemSize: CGFloat
    private let proofs: [WeeklyChallengeImageInfo]
    private let showsAuthenticationItem: Bool
    private let imageLoader: RemoteImageLoading
    private let onAuthenticationTap: () -> Void

    init(
        itemSize: CGFloat,
        proofs: [WeeklyChallengeImageInfo],
        showsAuthenticationItem: Bool,
        imageLoader: RemoteImageLoading,
        onAuthenticationTap: @escaping () -> Void
    ) {
        self.itemSize = itemSize
        self.proofs = proofs
        self.showsAuthenticationItem = showsAuthenticationItem
        self.imageLoader = imageLoader
        self.onAuthenticationTap = onAuthenticationTap
    }

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.fixed(itemSize), spacing: 10),
                GridItem(.fixed(itemSize), spacing: 10)
            ],
            spacing: 10
        ) {
            if showsAuthenticationItem {
                authenticationItem
            }

            ForEach(proofs, id: \.proofId) { proof in
                ChallengeWeeklyProofItem(
                    proof: proof,
                    itemSize: itemSize,
                    imageLoader: imageLoader
                )
            }
        }
        .animation(.easeInOut(duration: 0.22), value: showsAuthenticationItem)
        .animation(.easeInOut(duration: 0.22), value: proofs.map(\.proofId))
    }
}

private extension ChallengeWeeklyProofGrid {
    var authenticationItem: some View {
        Button(action: onAuthenticationTap) {
            VStack(spacing: 8) {
                Image.icPlus
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.gray9)
                    .frame(width: 18, height: 18)

                MText(
                    "인증하기",
                    style: .c1,
                    color: .gray9
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray1)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(width: itemSize, height: itemSize)
    }
}
