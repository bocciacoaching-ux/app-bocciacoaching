#!/bin/bash
# Compila el modo demo (lib/demo/demo_main.dart) y arma el paquete del artefacto.
# Uso: demo-tools/build_demo.sh [carpeta_salida]   (por defecto ./build/demo-artifact)
set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$REPO/build/demo-artifact}"
export PATH=/opt/flutter/bin:$PATH
cd "$REPO"
flutter build web --release --no-tree-shake-icons --no-web-resources-cdn -t lib/demo/demo_main.dart 2>&1 | grep -E "Built|Error|error:" | head -20
# La compilación con Flutter nuevo modifica estos archivos; se descartan.
git checkout -q -- analysis_options.yaml macos windows pubspec.lock 2>/dev/null || true
rm -rf "$OUT" && cp -r build/web "$OUT" && cd "$OUT"
find . -name '*.symbols' -delete; find . -name .DS_Store -delete
rm -rf canvaskit/skwasm* canvaskit/wimp* canvaskit/webparagraph flutter.js.map flutter_service_worker.js assets/NOTICES .last_build_id assets/AssetManifest.bin
sed -i 's#<base href="/">##; s|<title>boccia_coaching_app</title>|<title>Boccia Coaching Demo</title>\n  <style>html,body{margin:0;height:100%;background:#2f5470}</style>|' index.html
python3 -c "
import re;p='flutter_bootstrap.js';s=open(p).read();s=re.sub(r'_flutter\.loader\.load\(\{.*?\}\);\s*$','_flutter.loader.load({config:{renderer:\"canvaskit\"}});\n',s,flags=re.S);open(p,'w').write(s)"
mv index.html app.html && cp "$REPO/demo-tools/viewer.html" index.html
echo "paquete listo en $OUT ($(du -sh . | cut -f1))"
