//
//  ChallengeDetailGroupRequiredProgressGauge.swift
//  Challenge
//
//  Created by 김동준 on 8/9/26.
//

import DesignSystem
import SwiftUI

struct ChallengeDetailGroupRequiredProgressGauge: View {
    private let status: ChallengeStepCountStatus?
    private let deviceWidth: CGFloat
    private let hPadding: CGFloat = 54
    private let gaugeLineWidth: CGFloat = 12

    init(
        status: ChallengeStepCountStatus?,
        deviceWidth: CGFloat
    ) {
        self.status = status
        self.deviceWidth = deviceWidth
    }

    var body: some View {
        VStack(spacing: 0) {
            gaugeSection
            percentageTextRow
        }
    }

    private var gaugeSection: some View {
        ZStack(alignment: .top) {
            gauge

            VStack(spacing: 8) {
                percentageText
                Image.imgModyChallengeWalking
            }
            .padding(.top, 30)
        }
    }

    private var percentageTextRow: some View {
        HStack(spacing: 0) {
            MText("0", style: .c2, color: .gray6)
                .frame(width: 24)
            Spacer()
            MText("100", style: .c2, color: .gray6)
                .frame(width: 24)
        }
        .hPadding(hPadding - (gaugeLineWidth/2))
    }
}

private extension ChallengeDetailGroupRequiredProgressGauge {
    var gauge: some View {
        ZStack(alignment: .top) {
            gaugeTrack
            gaugeProgress
        }
        .frame(
            width: gaugeSize,
            height: (gaugeSize / 2) + (gaugeLineWidth / 2),
            alignment: .top
        )
        .clipped()
    }

    var gaugeTrack: some View {
        Circle()
            .inset(by: gaugeLineWidth / 2)
            .trim(from: 0, to: 0.5)
            .stroke(
                Color.gray2,
                style: StrokeStyle(lineWidth: gaugeLineWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(180))
            .frame(width: gaugeSize, height: gaugeSize)
    }

    var gaugeProgress: some View {
        Circle()
            .inset(by: gaugeLineWidth / 2)
            .trim(from: 0, to: progress / 2)
            .stroke(
                Color.main,
                style: StrokeStyle(lineWidth: gaugeLineWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(180))
            .frame(width: gaugeSize, height: gaugeSize)
            .animation(.easeOut(duration: 0.8), value: progress)
    }

    var percentageText: some View {
        (
            Text("\(Int(progress * 100))")
                .font(ModyTypography.h1.token.swiftUIFont)
            + Text("%")
                .font(ModyTypography.b1.token.swiftUIFont)
        )
        .foregroundStyle(Color.gray10)
        .contentTransition(.numericText(value: progress))
        .animation(.easeOut(duration: 0.8), value: progress)
    }

    var progress: Double {
        guard let status, status.targetStepCount > 0 else { return 0 }

        return min(
            max(Double(status.currentStepCount) / Double(status.targetStepCount), 0),
            1
        )
    }

    var gaugeSize: CGFloat {
        max(deviceWidth - (hPadding * 2), 0)
    }
}
