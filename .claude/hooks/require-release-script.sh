#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash). Blocks raw iOS release builds so they always go
# through scripts/build_ios_release.sh, which enforces the RevenueCat key. Exit 2
# blocks the command and shows stderr to Claude.
set -uo pipefail

command_text=$(jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[[ -z "$command_text" ]] && exit 0

# A heredoc usually carries text (commit messages, PR bodies, docs), not a build.
[[ "$command_text" == *"<<"* ]] && exit 0

# A build command only counts when it starts a shell command (line start or after ; & | ( ).
start='(^|[;&|(])[[:space:]]*([^[:space:]]+/)?flutter[[:space:]]+build[[:space:]]+'

blocked=0
if printf '%s\n' "$command_text" | grep -Eq "${start}ipa([[:space:]]|$)"; then
  blocked=1
elif printf '%s\n' "$command_text" | grep -Eq "${start}ios([[:space:]]|$)"; then
  # Simulator, debug and profile builds are not App Store uploads.
  if ! printf '%s\n' "$command_text" | grep -Eq -- '--(simulator|debug|profile)([[:space:]]|$)'; then
    blocked=1
  fi
fi

if [[ "$blocked" -eq 1 ]]; then
  cat >&2 <<'MSG'
Blocked: do not run `flutter build ipa` / a release `flutter build ios` directly.

Use scripts/build_ios_release.sh instead. It refuses to run without
REVENUECAT_IOS_API_KEY, always passes it via --dart-define, and verifies the key
is inside the compiled app. A build without it falls back to
NoopMoodEntitlementsRepository and caused the Apple rejection (Guideline 2.1(b)).

  REVENUECAT_IOS_API_KEY=appl_xxx STORE_VERIFIED=1 scripts/build_ios_release.sh

See CLAUDE.md > "Build de release de iOS".
MSG
  exit 2
fi

exit 0
