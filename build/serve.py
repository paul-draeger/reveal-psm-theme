#!/usr/bin/env python3
"""The static server behind `serve.sh`, with caching turned off.

A deck is edited and reloaded dozens of times in a sitting, and `shared_data.js`
is regenerated behind the browser's back whenever `variables.tex` or
`literatur.bib` change. A cached copy of it shows the old symbols and turns a
newly added citation into `[?]` — which reads as a bug in the deck rather than
in the cache, and costs an hour to find. Nothing served here is worth caching,
so nothing is cached.

    S00_main/build/serve.py --port 8000 --directory ../..
"""

import argparse
import functools
import http.server


class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

    def log_message(self, fmt, *args):
        # One line per request is useful; the date prefix is not.
        print(f"  {self.address_string()} {fmt % args}", flush=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8000)
    parser.add_argument("--bind", default="127.0.0.1")
    parser.add_argument("--directory", default=".")
    args = parser.parse_args()

    handler = functools.partial(NoCacheHandler, directory=args.directory)
    server = http.server.ThreadingHTTPServer((args.bind, args.port), handler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nstopped")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
