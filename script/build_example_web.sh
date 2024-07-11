flutter --version
flutter pub get
# shellcheck disable=SC2164
cd ./example
flutter build web --wasm --base-href /flutter_obs/
