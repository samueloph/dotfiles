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

# Use release defined in d/changelog, can be used for unstable and stable-security builds, for example.
alias bp="gbp buildpackage --git-builder=sbuild -v --no-clean-source --source-only-changes"
alias bp-new="gbp buildpackage --git-builder=sbuild -v --no-clean-source --force-orig-source"

# For stable backports.
# shellcheck disable=SC2139
alias "bp-new-$stable_codename-bpo"="gbp buildpackage --git-builder=sbuild -v -d ${stable_codename}-backports --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${stable_codename}-backports main\" --no-clean-source"
# shellcheck disable=SC2139
alias "bp-$stable_codename-bpo"="bp-new-${stable_codename}-bpo --source-only-changes"

# For oldstable backports.
# shellcheck disable=SC2139
alias "bp-new-$oldstable_codename-bpo"="gbp buildpackage --git-builder=sbuild -v -d ${oldstable_codename}-backports --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${oldstable_codename}-backports main\" --no-clean-source"
# shellcheck disable=SC2139
alias "bp-$oldstable_codename-bpo"="bp-new-${oldstable_codename}-bpo --source-only-changes"

# For oldstable sloppy backports.
# shellcheck disable=SC2139
alias "bp-new-$oldstable_codename-bpo-sloppy"="gbp buildpackage --git-builder=sbuild -v -d ${oldstable_codename}-backports-sloppy --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${oldstable_codename}-backports main\" --extra-repository=\"deb http://deb.debian.org/debian ${oldstable_codename}-backports-sloppy main\" --no-clean-source"
# shellcheck disable=SC2139
alias "bp-$oldstable_codename-bpo-sloppy"="bp-new-${oldstable_codename}-bpo-sloppy --source-only-changes"

# Command to manually update all chroots, in case it's updates are not in a cronjob.
alias update-schroots="sudo /usr/share/doc/sbuild/examples/sbuild-debian-developer-setup-update-all"

# This is copied from:
# https://salsa.debian.org/ruby-team/meta/-/blob/da3f8ebc58853d2706e8ef07679d8389ae09f366/new-upstream
function import-new-release {
    gbp import-orig --pristine-tar ${1:-'--uscan'}
    upstream_version=$(git tag | grep upstream/ | sort -V | tail -1 | cut -d / -f 2)
    epoch=$(dpkg-parsechangelog -SVersion | sed -e '/:/!d; s/:.*/:/')
    gbp dch --new-version="${epoch}${upstream_version}-1"
    debcommit -a
}

export QUILT_PATCHES=debian/patches
export QUILT_DIFF_ARGS="--no-timestamps --no-index -pab"
export QUILT_REFRESH_ARGS="--no-timestamps --no-index -pab"
