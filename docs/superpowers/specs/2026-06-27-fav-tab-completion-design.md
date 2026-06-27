# Fav — Tab completion design

## Goal

Make `fav` (and every list command / tag) support `<Tab>` autocompletion in
both bash and zsh, limited to:

1. **Command-name completion** — typing a prefix of a list command (`m`, `my`,
   `mysu`) and pressing Tab completes to the full command name
   (`mysuperlist`).
2. **Subcommand completion** — after a tag command, completing the first
   argument offers the built-in subcommands: `add`, `create`, `mylist`, `help`
   (e.g. `mysuperlist a<Tab>` → `mysuperlist add`).

Explicitly **out of scope**: suggesting or running the commands stored inside a
list. Completion never touches list contents.

## Approach

- Add one completion function, `_fav_complete`, to the `fav` engine. It returns
  the four subcommands only when completing the **first** word after the tag
  command. For any later word it returns nothing, letting the shell fall back to
  its default (file) completion.
- Register the completion for every tag command from inside `_fav_define`, right
  after the function is defined, so newly created lists get completion
  immediately:
  - **bash**: `complete -F _fav_complete <tag>`.
  - **zsh**: enable `bashcompinit` once at load time, after which the same
    `complete -F` call works unchanged. This keeps a single cross-shell code
    path.
- Registration is guarded so it is a no-op if `complete` is unavailable (e.g. a
  non-interactive minimal shell), avoiding errors on source.

## Command-name completion

Each tag is a defined shell function, and both bash and zsh complete defined
function/command names on the first word of the line out of the box. So
requirement 1 needs no extra code — it is provided by the shell once the
functions are defined (which `_fav_load_lists` already does). This will be
verified during implementation.

## Components

- `_fav_complete` — completion generator (subcommands, first word only).
- `_fav_define` — extended to also register completion for the tag.
- Load-time bootstrap — enable `bashcompinit` under zsh once.

## Testing

- bash: source the file, confirm `complete -p fav` shows the function, and that
  `fav <Tab>` offers `add create mylist help`.
- zsh: same checks under zsh with `bashcompinit` active.
- Confirm a freshly `create`d list command also has completion registered.
- Confirm later words fall through to default completion (no subcommands
  offered).

## Docs

Add a short "Tab completion" note to `README.md`.
