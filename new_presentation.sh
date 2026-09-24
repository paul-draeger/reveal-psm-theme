#!/usr/bin/env bash
# Create a new deck beside this repo's theme, reached through relative
# symbolic links so a change to theme/, lib/ or reveal/ reaches every deck at
# once.
#
#   decks/new_presentation.sh my_talk "My talk title"
#
# Run from anywhere; the deck is created under decks/<name>/.
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

usage() {
  echo "Usage: $0 name \"Full title\"" >&2
  echo "       e.g. $0 my_talk \"My talk title\"" >&2
  exit 2
}

[ "$#" -eq 2 ] || usage
project_name=$1
presentation_title=$2

project_dir="$repo_dir/decks/$project_name"
if [ -e "$project_dir" ]; then
  echo "Refusing to overwrite existing presentation: $project_dir" >&2
  exit 1
fi

mkdir -p "$project_dir"
for linked in theme lib reveal; do
  ln -s "../../$linked" "$project_dir/$linked"
done

entry="$project_dir/index.html"
sed -e "s|__PRESENTATION_TITLE__|${presentation_title//|/\\|}|g" \
    -e "s|__PRESENTATION_DATE__|$(date +'%-d %B %Y')|g" \
    "$repo_dir/template/presentation.html.in" > "$entry"

echo "Created $project_dir"
echo "Serve it with: $repo_dir/serve.sh, then open decks/$project_name/"
