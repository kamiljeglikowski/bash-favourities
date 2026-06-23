# fav — favourite-commands tool for bash

A tiny bash tool to save your favourite shell commands and quickly recall, edit,
and run them by number.

This repository folder holds a **copy** of the working files for reference and
backup. The live tool runs from `~/.fav/` (see [Installation](#installation)).

---

## Files

| File             | Purpose                                                              |
|------------------|----------------------------------------------------------------------|
| `fav`            | All the logic — a bash function meant to be **sourced**, not executed |
| `favourites.txt` | Your saved commands, one raw command per line                        |
| `README.md`      | This document                                                        |

On a working machine these live at:

- `~/.fav/fav`
- `~/.fav/favourites.txt`

---

## What it does

| Command            | Action                                                                                                 |
|--------------------|--------------------------------------------------------------------------------------------------------|
| `fav`              | Lists your favourites numbered. Pick a number → the command appears on an **editable** prompt → edit if you want, then Enter to run (empty/Ctrl-C cancels). |
| `fav add <command>`| Adds an inline command, e.g. `fav add ls -la`.                                                         |
| `fav add`          | Prompts you to type/paste a command. Use this for commands with quotes or pipes, e.g. `grep foo *.txt \| wc -l`. |
| `fav help`         | Shows usage.                                                                                            |

The list is read **live** from `favourites.txt` every time you run `fav`, so new
commands show up immediately after `fav add` — no reloading required.

---

## Installation

1. **Copy the files into `~/.fav/`:**

   ```bash
   mkdir -p ~/.fav
   cp fav ~/.fav/fav
   cp favourites.txt ~/.fav/favourites.txt   # optional: brings your saved commands
   ```

2. **Load the tool from your `~/.bash_profile`.** Add this line:

   ```bash
   # Load the fav favourite-commands tool
   [ -f ~/.fav/fav ] && source ~/.fav/fav
   ```

   You can append it safely with:

   ```bash
   printf '\n# Load the fav favourite-commands tool\n[ -f ~/.fav/fav ] && source ~/.fav/fav\n' >> ~/.bash_profile
   ```

3. **Reload your shell** (or open a new terminal):

   ```bash
   source ~/.bash_profile
   ```

That's it — type `fav` to start.

### What that load line means

```bash
[ -f ~/.fav/fav ] && source ~/.fav/fav
```

- `[ -f ~/.fav/fav ]` — test whether the file exists and is a regular file.
- `&&` — only run the next part if that test succeeded.
- `source ~/.fav/fav` — read the file into your **current** shell so the `fav`
  function becomes available. (Sourcing, not executing, is what keeps the
  function defined after the file finishes.)

The `-f` guard means a new terminal still opens cleanly even if the file is
missing or renamed.

---

## Notes

- **Why no file extension?** `fav` is *sourced*, so the extension is irrelevant
  to bash. Keeping it extensionless matches the other dotfiles it lives beside
  (`.bashrc`, `.bash_profile`) and mirrors the `fav` command name.
- **Custom location:** set `FAV_FILE` before sourcing to point at a different
  favourites file, e.g. `export FAV_FILE=~/mystuff/cmds.txt`.
- **Quotes & pipes:** when adding a command inline, the shell parses quotes and
  pipes before `fav` sees them. For anything fancy, use interactive `fav add`
  (no arguments) and paste the full command, or single-quote it inline.
- **macOS / bash:** this assumes bash is your login shell. `~/.bash_profile` is
  read by login shells; if `fav` ever fails to load in a new interactive
  terminal, you may need to source `.bash_profile` from `.bashrc`.
