.PHONY: module generate clean firebase-demo-app

module:
	bash ./Scripts/Shell/create_module.sh

generate:
	tuist install
	tuist generate

clean:
	rm -rf Projects/**/*.xcodeproj
	rm -rf Projects/**/Derived
	rm -rf Projects/**/**/*.xcodeproj
	rm -rf Projects/**/**/Derived
	rm -rf *.xcworkspace

firebase-demo-app:
	@if [ -z "$(DEMO)" ]; then \
		echo "Usage: make firebase-demo-app DEMO=SignInDemo FIREBASE_PROJECT=<firebase-project-id>"; \
		exit 1; \
	fi
	@if [ -z "$(FIREBASE_PROJECT)" ]; then \
		echo "Usage: make firebase-demo-app DEMO=$(DEMO) FIREBASE_PROJECT=<firebase-project-id>"; \
		exit 1; \
	fi
	@command -v firebase >/dev/null 2>&1 || { \
		echo "firebase CLI is required. Install firebase-tools and run firebase login first."; \
		exit 1; \
	}
	$(eval FIREBASE_DEMO_BUNDLE_ID ?= com.jagsim-demo-$(DEMO))
	$(eval FIREBASE_DEMO_SECRET_NAME := FIREBASE_APP_ID_$(shell printf '%s' "$(DEMO)" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9]/_/g'))
	firebase apps:create ios "$(DEMO)" \
		--bundle-id "$(FIREBASE_DEMO_BUNDLE_ID)" \
		--project "$(FIREBASE_PROJECT)"
	@echo "Add the created Firebase App ID to GitHub Secrets:"
	@echo "$(FIREBASE_DEMO_SECRET_NAME)=<created firebase app id>"
