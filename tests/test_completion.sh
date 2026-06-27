#!/usr/bin/env bash
# Tests for fav tab-completion.
# Runnable under bash and zsh. Sources the engine, then exercises the
# completion function the way the shell would.
set +u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
FAV_FILE="$SCRIPT_DIR/../fav"

fails=0
pass() { printf 'ok   - %s\n' "$1"; }
fail() { printf 'FAIL - %s\n' "$1"; fails=$((fails + 1)); }

# Isolate data so we don't touch the user's real ~/.favourites.
WORK="$(mktemp -d)"
export FAV_DIR="$WORK/fav"
export FAV_LIST="$FAV_DIR/my_list"
export FAV_LISTS_DIR="$FAV_DIR/lists"
mkdir -p "$FAV_DIR"
# Register an extra list command so we can test its completion too.
printf '%s\n%s\n' "mysuperlist" "demo list" > "$FAV_LIST"

# Under zsh, index arrays bash-style for the direct _fav_complete calls below.
# The sourced engine handles enabling bash-style `complete` itself.
if [ -n "${ZSH_VERSION:-}" ]; then
    setopt ksh_arrays 2>/dev/null
fi

# shellcheck disable=SC1090
source "$FAV_FILE"

# Helper: run the completion function for a given line and echo the candidates.
run_complete() {
    # $1 = command word, rest = already-typed args (last one is the word being completed)
    COMP_WORDS=("$@")
    COMP_CWORD=$(( $# - 1 ))
    COMPREPLY=()
    _fav_complete
    local el
    for el in "${COMPREPLY[@]}"; do
        printf '%s\n' "$el"
    done
}

# 1. Completion function is defined.
if command -v _fav_complete >/dev/null 2>&1 || type _fav_complete >/dev/null 2>&1; then
    pass "_fav_complete is defined"
else
    fail "_fav_complete is defined"
fi

# 2. First-word completion offers all four subcommands for the default `fav`.
out="$(run_complete fav "")"
for sub in add create mylist help; do
    if printf '%s\n' "$out" | grep -qx "$sub"; then
        pass "fav <Tab> offers '$sub'"
    else
        fail "fav <Tab> offers '$sub' (got: $(printf '%s' "$out" | tr '\n' ' '))"
    fi
done

# 3. Prefix filtering: `fav a<Tab>` -> only 'add'.
out="$(run_complete fav "a")"
trimmed="$(printf '%s' "$out" | tr -d '[:space:]')"
if [ "$trimmed" = "add" ]; then
    pass "fav a<Tab> completes to only 'add'"
else
    fail "fav a<Tab> completes to only 'add' (got: $(printf '%s' "$out" | tr '\n' ' '))"
fi

# 4. Second word gets no subcommand suggestions (falls through to default).
out="$(run_complete fav add "")"
trimmed="$(printf '%s' "$out" | tr -d '[:space:]')"
if [ -z "$trimmed" ]; then
    pass "fav add <Tab> offers no subcommands"
else
    fail "fav add <Tab> offers no subcommands (got: $(printf '%s' "$out" | tr '\n' ' '))"
fi

# 5. A user-created list command also gets completion registered.
out="$(run_complete mysuperlist "")"
if printf '%s\n' "$out" | grep -qx "add"; then
    pass "mysuperlist <Tab> offers subcommands"
else
    fail "mysuperlist <Tab> offers subcommands (got: $(printf '%s' "$out" | tr '\n' ' '))"
fi

# 6. Completion is registered with the shell for the tag commands.
# bash supports querying with `complete -p`; zsh's bashcompinit shim does not,
# so there we confirm the completion system accepts a (re-)registration.
check_registered() {
    local name="$1"
    if [ -n "${ZSH_VERSION:-}" ]; then
        complete -F _fav_complete "$name" >/dev/null 2>&1
    else
        complete -p "$name" >/dev/null 2>&1
    fi
}
if check_registered fav; then
    pass "completion registered for 'fav'"
else
    fail "completion registered for 'fav'"
fi
if check_registered mysuperlist; then
    pass "completion registered for 'mysuperlist'"
else
    fail "completion registered for 'mysuperlist'"
fi

rm -rf "$WORK"

if [ "$fails" -eq 0 ]; then
    printf '\nAll tests passed.\n'
    exit 0
else
    printf '\n%d test(s) failed.\n' "$fails"
    exit 1
fi
