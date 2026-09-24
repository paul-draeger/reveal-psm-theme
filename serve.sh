#!/usr/bin/env bash
# Serve this repository over HTTP so a browser can open the example deck.
#
#   ./serve.sh                 # http://127.0.0.1:8000/
#   PORT=8010 ./serve.sh
#
# A deck has to be served rather than opened as a file:// page — the runtime
# fetches the theme, the fonts and MathJax, and a file:// origin blocks that.
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
port=${PORT:-8000}
host=${HOST:-127.0.0.1}

echo "Serving $repo_dir on http://$host:$port/"
echo
echo "  append ?print-pdf and print to PDF from the browser for a handout"
echo "  press S in the deck for the speaker view, ESC for the overview"
echo
exec python3 "$repo_dir/build/serve.py" --port "$port" --bind "$host" --directory "$repo_dir"
