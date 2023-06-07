on: push
name: Test, Build and Release apk
jobs:
build:
name: Build APK
runs-on: ubuntu-latest
steps:
- uses: actions/checkout@v1
- uses: actions/setup-java@v1
with:
java-version: '12.x'
- uses: subosito/flutter-action@v1
with:
flutter-version: '1.7.8+hotfix.4'
- run: flutter pub get
- run: flutter test
- run: flutter build apk --debug --split-per-abi
- name: Create a Release APK
uses: ncipollo/release-action@v1
with:
artifacts: "build/app/outputs/apk/debug/*.apk"
token: ${{ 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 }}