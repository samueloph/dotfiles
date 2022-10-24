# shellcheck shell=bash
# This bashrc script is generated from the setup script of samueloph's
# dotfiles, the script swaps the placeholders "${.*-PLACEHOLDER}" with
# their values (eg.: debian stable release codename, email address...).

# DEBEMAIL="${EMAIL-PLACEHOLDER}"
# DEBFULLNAME="${NAME-PLACEHOLDER}"
# export DEBEMAIL DEBFULLNAME

export EDITOR=vim

# Aliases to build packages:
# bp = build source-only package
# bp-new = source-build-package = build package and add binaries to dsc (sourceful).

# Use release defined in d/changelog, can be used for unstable and stable-security builds, for example.
alias bp-new="gbp buildpackage --git-builder=sbuild -v --no-clean-source --force-orig-source"
alias bp="bp-new --source-only-changes"

# For stable backports.
# alias bp-new-${STABLE-PLACEHOLDER}-bpo="gbp buildpackage --git-builder=sbuild -v -d ${STABLE-PLACEHOLDER}-backports --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${STABLE-PLACEHOLDER}-backports main\" --no-clean-source"
# alias bp-${STABLE-PLACEHOLDER}-bpo="bp-new-${STABLE-PLACEHOLDER}-bpo --source-only-changes"

# For oldstable backports.
# alias bp-new-${OLDSTABLE-PLACEHOLDER}-bpo="gbp buildpackage --git-builder=sbuild -v -d ${OLDSTABLE-PLACEHOLDER}-backports --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${OLDSTABLE-PLACEHOLDER}-backports main\" --no-clean-source"
# alias bp-${OLDSTABLE-PLACEHOLDER}-bpo="bp-new-${OLDSTABLE-PLACEHOLDER}-bpo --source-only-changes"

# For oldstable sloppy backports.
# alias bp-new-${OLDSTABLE-PLACEHOLDER}-bpo-sloppy="gbp buildpackage --git-builder=sbuild -v -d ${OLDSTABLE-PLACEHOLDER}-backports-sloppy --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${OLDSTABLE-PLACEHOLDER}-backports main\" --extra-repository=\"deb http://deb.debian.org/debian ${OLDSTABLE-PLACEHOLDER}-backports-sloppy main\" --no-clean-source"
# alias bp-${OLDSTABLE-PLACEHOLDER}-bpo-sloppy="bp-new-${OLDSTABLE-PLACEHOLDER}-bpo-sloppy --source-only-changes"

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
