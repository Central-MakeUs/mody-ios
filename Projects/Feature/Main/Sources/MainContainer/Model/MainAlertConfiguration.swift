//
//  MainAlertConfiguration.swift
//  Main
//
//  Created by 김동준 on 7/5/26
//

import DesignSystem

struct MainAlertConfiguration {
    let title: String
    let contents: String
    let leadingButton: MAlertButton?
    let trailingButton: MAlertButton?
    let dismissOnBackgroundTap: Bool

    init(
        title: String,
        contents: String,
        leadingButton: MAlertButton? = nil,
        trailingButton: MAlertButton? = MAlertButton("확인"),
        dismissOnBackgroundTap: Bool = true
    ) {
        self.title = title
        self.contents = contents
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
    }
}
