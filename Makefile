FLUTTER ?= fvm flutter
DART ?= fvm dart
ENV_FILE ?= .env
ENV_FLAG = --dart-define-from-file=$(ENV_FILE)

.PHONY: help setup env get gen analyze test format format-check clean run run-release build-apk build-bundle build-ios check

help:
	@echo ====================================================================
	@echo  Sadhu Ram and Sons - Kisan Mitra App (Development Makefile)
	@echo ====================================================================
	@echo  make setup         - Configure FVM SDK, env file, dependencies, l10n
	@echo  make env           - Create .env from .env.example template
	@echo  make get           - Install Flutter dependencies (pub get)
	@echo  make gen           - Generate ARB multilingual localization classes
	@echo  make analyze       - Run Dart and Flutter static analysis
	@echo  make test          - Run full unit and widget test suite
	@echo  make format        - Auto-format all Dart code in lib/ and test/
	@echo  make format-check  - Verify code formatting without modifying files
	@echo  make check         - Run format-check, analyze, and test in sequence
	@echo  make clean         - Clear Flutter build caches and ephemeral files
	@echo  make run           - Run debug app with .env configuration
	@echo  make run-release   - Run release app on device (performance testing)
	@echo  make build-apk     - Build release APK split-per-abi (target size under 18MB)
	@echo  make build-bundle  - Build Android App Bundle (AAB for Google Play)
	@echo  make build-ios     - Build iOS release bundle (no codesign)
	@echo ====================================================================

env:
	@if not exist .env copy .env.example .env

setup: env
	fvm use 3.47.5
	$(FLUTTER) pub get
	$(FLUTTER) gen-l10n

get:
	$(FLUTTER) pub get

gen:
	$(FLUTTER) gen-l10n

analyze:
	$(FLUTTER) analyze

test:
	$(FLUTTER) test

format:
	$(DART) format lib test

format-check:
	$(DART) format --output=none --set-exit-if-changed lib test

check: format-check analyze test

clean:
	$(FLUTTER) clean

run:
	$(FLUTTER) run $(ENV_FLAG)

run-release:
	$(FLUTTER) run --release $(ENV_FLAG)

build-apk:
	$(FLUTTER) build apk --release --split-per-abi $(ENV_FLAG)

build-bundle:
	$(FLUTTER) build appbundle --release $(ENV_FLAG)

build-ios:
	$(FLUTTER) build ios --release --no-codesign $(ENV_FLAG)
