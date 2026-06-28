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
