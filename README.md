# Pr1nted/homebrew-tap

A Homebrew tap for [OpenDoctrines](https://github.com/Pr1nted/Open-Doctrines) — a
free, open-source grand strategy game.

```bash
brew tap Pr1nted/tap
brew trust --cask Pr1nted/tap/opendoctrines
brew install --cask opendoctrines
xattr -dr com.apple.quarantine /Applications/OpenDoctrines.app
```

All four lines are needed, and each one is there because leaving it out fails in
a specific way:

- **`brew trust`** — a third-party tap refuses to load a cask until trusted.
  Without it: *"Refusing to load cask ... from untrusted tap"*, and nothing
  installs.
- **`xattr -dr`** — see below.

## Why the `xattr` line is not optional

The macOS builds are not signed with an Apple Developer ID, because the project
does not pay for one. Homebrew attaches the same quarantine attribute a browser
download gets, so without that last line you have installed an app macOS then
refuses to open — stuck at *"cannot be opened because the developer cannot be
verified"*.

There is no way to prevent it through brew. Checked on Homebrew 6.0.22 rather
than assumed:

- there is no `quarantine` stanza a cask author can set;
- `--no-quarantine` **no longer exists** — it is rejected as an invalid option
  and appears nowhere in `brew install --help`;
- `HOMEBREW_CASK_OPTS="--no-quarantine"` is accepted and **silently ignored**;
  the install succeeds and `xattr` still shows `com.apple.quarantine`.

So it is cleared afterwards instead. That command is the same one the
[main README](https://github.com/Pr1nted/Open-Doctrines#macos--the-first-launch-needs-one-extra-step)
already gives for the zip download, and it is you making the same call that
right-click → Open makes.

Requires macOS 11 (Big Sur) or later. Apple Silicon and Intel both work; the
cask picks the right build.

## Updating

```bash
brew update && brew upgrade --cask opendoctrines
```

## Maintainer notes

`Casks/opendoctrines.rb` is mirrored from `packaging/macos/opendoctrines.rb` in
the main repository — change it there and copy, so the two never drift. Per
release, bump `version` and both `sha256` values:

```bash
for a in arm64 x64; do
  curl -sL "https://github.com/Pr1nted/Open-Doctrines/releases/download/v<VERSION>/OpenDoctrines-macos-$a.zip" \
    | shasum -a 256 | sed "s/-/$a/"
done
```
