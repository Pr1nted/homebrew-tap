# Homebrew cask for OpenDoctrines.
#
# WHERE THIS BELONGS. Not homebrew/cask -- that repository has notability
# requirements a young indie game does not meet, and a rejected pull request
# there is a week spent for nothing. This is written for YOUR OWN TAP:
#
#     github.com/Pr1nted/homebrew-tap   ->   Casks/opendoctrines.rb
#
# A tap is a plain git repository with a Casks/ directory. No review, no
# waiting, and moving to homebrew/cask later costs nothing.
#
# QUARANTINE CANNOT BE AVOIDED THROUGH BREW AT ALL. Verified by running it on
# Homebrew 6.0.22, not by reading the Cookbook:
#
#   - There is no `quarantine` stanza. Homebrew gives cask authors no way to
#     decide this for the user.
#   - `--no-quarantine` NO LONGER EXISTS. It is rejected outright --
#     "Error: invalid option" -- and appears nowhere in `brew install --help`.
#   - `HOMEBREW_CASK_OPTS="--no-quarantine"` is accepted and silently ignored:
#     the install succeeds and the app still carries com.apple.quarantine.
#
# These builds are unsigned, so the installed app is quarantined and macOS
# refuses to open it. One line clears it, and it is the same command README.md
# already documents for the zip. The four lines to publish:
#
#     brew tap Pr1nted/tap
#     brew trust --cask Pr1nted/tap/opendoctrines
#     brew install --cask opendoctrines
#     xattr -dr com.apple.quarantine /Applications/OpenDoctrines.app
#
# `brew trust` is required too: a third-party tap refuses to load a cask until
# trusted. Publish all four or this packaging helps nobody.
cask "opendoctrines" do
  # Matches the published asset names: OpenDoctrines-macos-{arm64,x64}.zip
  arch arm: "arm64", intel: "x64"

  version "1.3.1b"
  sha256 arm:   "88e8e89b775c276eeab9158775af1b300180ecf7973816c49b584c0d8ec56c45",
         intel: "8265abd50826dcd514013970afb31f263ad7199f500f2a3093063970cb6781f9"

  url "https://github.com/Pr1nted/Open-Doctrines/releases/download/v#{version}/OpenDoctrines-macos-#{arch}.zip"
  name "OpenDoctrines"
  desc "Grand strategy game about running a country"
  homepage "https://github.com/Pr1nted/Open-Doctrines"

  # GIT TAGS, NOT THE RELEASES API, AND THE REASON IS THE ALPHA.
  #
  # Every game release here is marked pre-release while the game is in alpha.
  # :github_latest takes the newest release that is NOT a pre-release, so it
  # skipped all of them and returned gearbox-v1.2 -- the mod SDK, a different
  # product. :github_releases is no better: it filters drafts and pre-releases
  # out before the regex is ever applied, leaving nothing at all to match.
  #
  # Git tags carry no such flag, so they list regardless. The anchored regex is
  # what keeps the three release lines apart: the game is vN.N.Na, the SDK is
  # gearbox-vN.N, the dedicated server is server-vN.N.Na. Only the first matches.
  livecheck do
    url "https://github.com/Pr1nted/Open-Doctrines.git"
    regex(/^v(\d+(?:\.\d+)+[a-z]?)$/i)
    strategy :git
  end

  # Bare symbol, not ">= :big_sur" — the string-comparison form is deprecated
  # and brew warns on every invocation. A bare symbol already means "or newer".
  depends_on macos: :big_sur

  # Both archives wrap the bundle in a directory named after the architecture.
  # Everything the game needs is inside the bundle -- data/ included, 1113 files
  # of it under Contents/ -- so the app alone is a complete install.
  app "OpenDoctrines-macos-#{arch}/OpenDoctrines.app"

  # Deliberately short. The game keeps its config, saves and AI model INSIDE the
  # bundle (m_dataDir is appDir + "../data/", so Contents/data), which means
  # removing the app already removes them. Only macOS's own leftovers remain.
  zap trash: [
    "~/Library/Saved Application State/com.opendoctrines.app.savedState",
  ]
end
