//
//  TargetScript+.swift
//  AppManifests
//
//  Created by 김동준 on 7/28/26
//

import ProjectDescription

extension TargetScript {
    static var pre: TargetScript {
        .pre(
            path: .relativeToRoot("Scripts/Shell/select_google_service_info.sh"),
            name: "Select GoogleService-Info.plist",
            basedOnDependencyAnalysis: false
        )
    }
    
    static var post: TargetScript {
        .post(
            script: """
            CRASHLYTICS_SCRIPT="${SRCROOT}/../../.build/checkouts/firebase-ios-sdk/Crashlytics/run"

            if [ ! -f "$CRASHLYTICS_SCRIPT" ]; then
                echo "error: [Crashlytics] Script not found: $CRASHLYTICS_SCRIPT"
                echo "Run 'tuist install' before generating the project."
                exit 1
            fi

            echo "[Crashlytics] Validating and scheduling dSYM upload..."
            "$CRASHLYTICS_SCRIPT"
            echo "[Crashlytics] Validation completed; dSYM upload started."
            """,
            name: "Upload dSYM to Crashlytics",
            inputPaths: [
                "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
                "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
                "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
                "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
                "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"
            ],
            basedOnDependencyAnalysis: false
        )
    }
}
