# del — a safer rm

`rm -i` prompts once per file, which is unusable for a batch. The habit it
produced was `ls <glob>`, eyeball the list, then `'rm' <glob>` — verify, then
repeat the glob and hope it still matches the same things. `del` collapses that
into one command: show what matched, ask once, move it somewhere recoverable.

## The pieces

| | |
|---|---|
| `del` | this directory. Preview, protected paths, one confirmation, retention notice. |
| `gomi` | [gomi](https://github.com/babarot/gomi), a prebuilt binary in `~/bin`. The trash: moving files in, restoring them, expiring them. |
| `gomi.yaml` | gomi's config, symlinked to `$XDG_CONFIG_HOME/gomi/config.yaml`. Pins the store and owns the protected-path list. |

`rm` is aliased to `del`. `\rm` or `command rm` gets the real thing.

```sh
del *.json           # preview, confirm once, move to trash
del -n *.json        # preview only
del --permanent big/ # skip the trash, actually unlink
del --purge          # empty what has aged past 30 days
undel                # gomi's restore browser
```

Trash lives in `$XDG_DATA_HOME/gomi`. `DEL_RETENTION_DAYS` changes the 30-day
window, `DEL_WARN_KB` the 1 GiB size warning.

## Why it is built this way

**Why `del` exists at all.** gomi already has a `forbidden_paths` check, so this
wrapper looks redundant. It is not, and this is the thing not to "simplify"
away:

- gomi compares the **literal argument** against that list without resolving it
  first, so `cd /; gomi etc` walks straight past the `/etc` guard. `del`
  resolves every argument to an absolute path before comparing, which catches
  `.`, `..`, trailing slashes and any relative spelling.
- gomi deletes what it can and reports the rest. Given one bad path in a batch,
  the others still go. `del` checks everything up front, so a typo'd glob fails
  whole instead of half-applying.

Batch confirmation is the third piece: gomi's `-i` prompts per file, which is
the `rm -i` problem this exists to solve.

**Why the config owns the protected list.** One list, two enforcers — `del`
does it correctly, gomi's own check is a backstop for direct calls. If `del`
cannot read that list it refuses to run rather than falling back to a built-in
copy, which would silently drift out of sync.

**Why short command flags**, against the rule in `../CLAUDE.md`: BSD userland
has no long-flag spelling for `du -sh` and friends, and this runs on macOS.

**Why retention only reports.** The trash grows forever, so something has to
mention it, but nothing is deleted without being asked. An unattended `del` can
never be why something is gone for good. The notice fires after a burial, at
most once a day.

## Things that could bite

- **gomi resolves the user directory from the OS, not `$HOME`.** Without
  `gomi_dir` pinned in the config it scatters a store into the real home, even
  in a sandbox that sets `$HOME` elsewhere.
- **Never run `gomi completions zsh`.** Bare words are paths to gomi, so that
  tries to delete files named `completions` and `zsh`. There is no completion
  generator; `_del` is hand-written and must be updated alongside the script's
  flags.
- **Protected paths are exact matches**, not prefixes. `del ~/projects` is
  refused, `del ~/projects/old` is not — deliberately, since these are
  directories worth emptying but never removing.
- **Moving to the trash is a rename, so space is not freed** until it is
  emptied. `del` warns above 1 GiB and suggests `--permanent`.
- **The retention notice needs `jq`** and is skipped silently without it.
- **`--purge` is the only thing here that destroys data.** Everything else
  moves files; that empties them for good. It lists what it would take and
  asks first, and honours `--dry-run`, because it originally did neither and
  took 80 files that were only meant to be listed.
