
#!/usr/bin/env bash
set -e

echo "Installation de Flutter..."

git clone https://github.com/flutter/flutter.git \
  --depth 1 -b stable "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release

echo "Compilation Flutter terminée !"
