#!/bin/bash

export EDITOR=vim

while IFS="," read -r _version _codename series _created release _eol _eol_lts _eol_elts
do
  if [[ ${stable_codename:-} ]]; then
    oldstable_codename="$series"
    break
  fi
  if [[ ${release:-} ]]; then
    stable_codename="$series"
    continue
  fi
done < <(grep -Ev "Sid|Experimental" /usr/share/distro-info/debian.csv | tac)

# Aliases to build packages:
# bp = build source-only package
# bp-new = source-build-package = build package and add binaries to dsc (sourceful).

# Use release defined in d/changelog, can be used for unstable and
# stable-security builds, for example.
# For non-parallel builds (in case of debugging), you can run:
# export DEB_BUILD_OPTIONS="parallel=1" && bp
alias bp="gbp buildpackage --git-builder=sbuild -v --source-only-changes"
alias bp-new="gbp buildpackage --git-builder=sbuild -v --force-orig-source"

# For stable backports.
# shellcheck disable=SC2139
alias "bp-new-$stable_codename-bpo"="gbp buildpackage --git-builder=sbuild -v -d ${stable_codename}-backports --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${stable_codename}-backports main\" --force-orig-source"
# shellcheck disable=SC2139
alias "bp-$stable_codename-bpo"="bp-new-${stable_codename}-bpo --source-only-changes"

# For oldstable backports.
# shellcheck disable=SC2139
alias "bp-new-$oldstable_codename-bpo"="gbp buildpackage --git-builder=sbuild -v -d ${oldstable_codename}-backports --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${oldstable_codename}-backports main\" --force-orig-source"
# shellcheck disable=SC2139
alias "bp-$oldstable_codename-bpo"="bp-new-${oldstable_codename}-bpo --source-only-changes"

# For oldstable sloppy backports.
# shellcheck disable=SC2139
alias "bp-new-$oldstable_codename-bpo-sloppy"="gbp buildpackage --git-builder=sbuild -v -d ${oldstable_codename}-backports-sloppy --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${oldstable_codename}-backports main\" --extra-repository=\"deb http://deb.debian.org/debian ${oldstable_codename}-backports-sloppy main\" --force-orig-source"
# shellcheck disable=SC2139
alias "bp-$oldstable_codename-bpo-sloppy"="bp-new-${oldstable_codename}-bpo-sloppy --force-orig-source --source-only-changes"

# Command to manually update all chroots, in case it's updates are not in a cronjob.
alias update-schroots="sudo sh /usr/share/doc/sbuild/examples/sbuild-debian-developer-setup-update-all"

# Commit the final changelog changes.
function commit-changelog {
  # Start a subshell so we can set bash's strict mode, this way the function
  # stops at any error.
  (
    # bash strict mode.
    set -euo pipefail
    # Assume we are at the source of the packaging repo, if it fails, assume we
    # are inside the debian folder.
    git add debian/changelog || git add changelog
    # Commit.
    git commit -m "Finalize changelog for $(dpkg-parsechangelog --show-field Version) $(dpkg-parsechangelog --show-field Distribution) upload"
    # Show latest commit, so we can confirm that it's ok.
    git show HEAD
  )
}

# This is copied from:
# https://salsa.debian.org/ruby-team/meta/-/blob/da3f8ebc58853d2706e8ef07679d8389ae09f366/new-upstream
function import-new-release {
  (
    set -euo pipefail
    gbp import-orig --pristine-tar ${1:-'--uscan'}
    upstream_version=$(git tag | grep upstream/ | sort -V | tail -1 | cut -d / -f 2)
    epoch=$(dpkg-parsechangelog -SVersion | sed -e '/:/!d; s/:.*/:/')
    gbp dch --new-version="${epoch}${upstream_version}-1"
    debcommit -a
  )
}

export QUILT_PATCHES=debian/patches
export QUILT_DIFF_ARGS="--no-timestamps --no-index -pab"
export QUILT_REFRESH_ARGS="--no-timestamps --no-index -pab"
