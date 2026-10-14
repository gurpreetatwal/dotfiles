# del — a safer rm

`rm -i` prompts once per file, which is unusable for a batch. The habit it
produced was `ls <glob>`, eyeball the list, then `'rm' <glob>` — verify, then
repeat the glob and hope it still matches the same things. `del` collapses that
into one command: show what matched, ask once, move it somewhere recoverable.

## The pieces

| | |
|---|---|
| `del` | this directory. Preview, protected paths, one confirmation, retention. |
| `gomi` | [gomi](https://github.com/babarot/gomi), a prebuilt binary in `~/bin`. Moves files into the trash and restores them. |
| `gomi.yaml` | gomi's config, symlinked to `$XDG_CONFIG_HOME/gomi/config.yaml`. Selects the per-volume trash and owns the protected subtrees. |
| `test` | the regression suite. Run it after any change; CI runs it too. |

`rm` is aliased to `del`. `\rm` or `command rm` gets the real thing.

```sh
del *.json           # preview, confirm once, move to trash
del -n *.json        # preview only
del --permanent big/ # skip the trash, actually unlink
del --purge          # list what has aged past 30 days, then empty it
undel                # gomi's restore browser
```

The trash follows the XDG spec, one per volume: `~/.local/share/Trash` for the
home filesystem, and `.Trash-$UID` at the top of any other volume that has one.
A file is always renamed into the trash on its own volume, never copied to
another. `DEL_RETENTION_DAYS` changes the 30-day window, `DEL_WARN_KB` the
1 GiB size warning.

## Why it is built this way

**Why `del` exists at all.** gomi already moves files to a trash and refuses
`forbidden_paths`, so this wrapper looks redundant. It is not, and this is the
thing not to "simplify" away:

- gomi treats every protected path as a subtree. It cannot say "never delete
  `~` or `~/projects` itself, but their contents are fine"; `del` can.
- gomi works through a batch in order and stops at the first file it cannot
  trash, after moving the ones before it. `del` checks every path first —
  existence, protection, and whether its volume has a trash — so a batch
  either goes whole or not at all.
- gomi's `-i` prompts per file, the `rm -i` problem this exists to solve.

**Why the config owns the subtree list.** gomi enforces it on direct calls and
`del` reads the same list. If `del` cannot read it, it refuses to run rather
than fall back to a built-in copy, which would silently drift.

**Why one trash per volume.** Copying across filesystems is slow and can fill
the destination; `~/projects` lives on a different disk from `~`. With
`home_fallback: false`, gomi refuses rather than copies, and `del` finds that
out before it asks for confirmation.

**Why short command flags**, against the rule in `../CLAUDE.md`: BSD userland
has no long-flag spelling for `du -sh` and friends, and this runs on macOS.

**Why retention only reports.** The trash grows forever, so something has to
mention it, but nothing is deleted without being asked. An unattended `del` can
never be why something is gone for good. The notice fires after a deletion, at
most once a day.

## Things that could bite

- **`--purge` is the only thing here that destroys data.** It lists exactly
  what it would take, asks first, honours `--dry-run`, and then deletes those
  entries and nothing else. It does not call `gomi --prune`, which acts on every
  volume's trash by its own reckoning. An early version did neither check and
  took 80 files that were only meant to be listed.
- **A volume with no trash is refused.** `/tmp` is on a filesystem without one,
  for instance. Use `--permanent`, or create one as the error says. gomi also
  ignores tmpfs and read-only filesystems, and so does `del`.
- **Symlinks are removed, not trashed.** gomi would route a link by the device
  its target is on and fail. A link holds no data; the preview shows where it
  pointed.
- **del acts on the name it is given, never on what it points at.** Trailing
  slashes are stripped, because `rm -rf link/` empties the directory a symlink
  points to.
- **Options must come before paths, and a file named like an option is
  refused.** `rm *` passes every name in the directory as an argument, so a
  file called `--force` or `--permanent` would otherwise switch that mode on.
  Delete such a file with `del -- --force`.
- **There are two kinds of protection.** `forbidden_paths` in `gomi.yaml` are
  subtrees: nothing at or below them can be deleted, including anything in
  `~/dotfiles` (use `git rm` or `\rm` there). `PROTECTED_NAMES` in `del` are
  directories that cannot be deleted themselves but whose contents can, such as
  `~` and `~/projects`. Both are matched however a path is reached: as typed,
  through symlinks, or as `.` from inside.
- **Restoring never overwrites.** If something new now sits at a trashed
  file's original path, gomi refuses the restore.
- **Moving to the trash is a rename, so space is not freed** until it is
  emptied. `del` warns above 1 GiB and suggests `--permanent`.
- **Never run `gomi completions zsh`.** Bare words are paths to gomi, so that
  tries to delete files named `completions` and `zsh`. `_del` is hand-written
  and must be updated alongside the script's flags.
- **The test suite runs on Linux only.** It uses GNU `date`, `sed -i` and
  `script`. The volume rename test needs a spare non-tmpfs volume; CI makes
  one, and `DEL_TEST_VOLUME=<mount>` runs it locally.
