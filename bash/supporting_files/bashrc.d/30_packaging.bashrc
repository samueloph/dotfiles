#!/bin/bash

# Set variables with codenames for debian stable and oldstable.
set_release_codename_variables () {
    # This has to be a function to allow the variables from the
    # while loop to be local.

    # If the values are already set, skip.
    if [[ -n ${OLDSTABLE_CODENAME:-} ]] && [[ ${STABLE_CODENAME:-} ]]; then
        return 0
    fi
    # Iterate over the /usr/share/distro-info/debian.csv file in reverse
    # order. Skip processing sid and experimental, look for the first two
    # versions which were already released and assumed they are stable and
    # oldstable.
    local _version _codename series _created release _eol _eol_lts _eol_elts
    while IFS="," read -r _version _codename series _created release _eol _eol_lts _eol_elts
    do
        # Check if this version has the "release" field set.
        if [[ $release ]]; then
            release_date_timestamp=$(date -d "$release" +%s)
            current_date=$(date +%s)
            # Check if we are iterating over an already released version
            # that's not sid or experimental.
            if [[ $current_date -ge $release_date_timestamp ]] && \
            [[ $series != "sid" ]] && \
            [[ $series != "experimental" ]]
            then
                # Have we already found the stable release?, then the very
                # next one in line will be oldstable.
                # We have to check using the ${variable:-} pattern because
                # we set the "nounset" bash flag and not doing so would trigger
                # an error.
                if [[ -n ${STABLE_CODENAME:-} ]]; then
                    OLDSTABLE_CODENAME="$series"
                    break
                # If STABLE_CODENAME is not set yet, the first match will be it.
                else
                    STABLE_CODENAME="$series"
                fi
            fi
        fi
    done < <(grep -Ev "Sid|Experimental" /usr/share/distro-info/debian.csv | tac)
}
set_release_codename_variables

# Aliases to build packages:
# bp = build source-only package

# Use release defined in d/changelog, can be used for unstable and
# stable-security builds, for example.
#
# For non-parallel builds (in case of debugging), you can run:
# export DEB_BUILD_OPTIONS="parallel=1" && bp
#
# For debugging, you can get into the chroot shell with:
# --build-failed-commands='%SBUILD_SHELL'
# --finished-build-commands='%SBUILD_SHELL'
# The first one only puts you in the shell if the build fails,
# the second one will do it always (on success too).
#
alias bp="gbp buildpackage --git-builder=sbuild -v"

# For stable backports.
# shellcheck disable=SC2139
alias "bp-$STABLE_CODENAME-bpo"="gbp buildpackage --git-builder=sbuild -v -d ${STABLE_CODENAME}-backports --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${STABLE_CODENAME}-backports main\""

# For oldstable backports.
# shellcheck disable=SC2139
alias "bp-$OLDSTABLE_CODENAME-bpo"="gbp buildpackage --git-builder=sbuild -v -d ${OLDSTABLE_CODENAME}-backports --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${OLDSTABLE_CODENAME}-backports main\""

# For oldstable sloppy backports.
# shellcheck disable=SC2139
alias "bp-$OLDSTABLE_CODENAME-bpo-sloppy"="gbp buildpackage --git-builder=sbuild -v -d ${OLDSTABLE_CODENAME}-backports-sloppy --build-dep-resolver=aptitude --extra-repository=\"deb http://deb.debian.org/debian ${OLDSTABLE_CODENAME}-backports main\" --extra-repository=\"deb http://deb.debian.org/debian ${OLDSTABLE_CODENAME}-backports-sloppy main\" --force-orig-source"

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

# This is based on:
# https://salsa.debian.org/ruby-team/meta/-/blob/da3f8ebc58853d2706e8ef07679d8389ae09f366/new-upstream
function import-new-release {
    # Start a subshell so we can set bash's strict mode, this way the function
    # stops at any error.
    (
        # bash strict mode.
        set -euo pipefail
        gbp import-orig --pristine-tar ${1:-'--uscan'}
        upstream_version=$(git tag | grep upstream/ | sort -V | tail -1 | cut -d / -f 2)
        epoch=$(dpkg-parsechangelog --show-field Version | sed -e '/:/!d; s/:.*/:/')
        gbp dch --new-version="${epoch}${upstream_version}-1"
        debcommit -a
    )
}

export QUILT_PATCHES=debian/patches
export QUILT_DIFF_ARGS="--no-timestamps --no-index -pab"
export QUILT_REFRESH_ARGS="--no-timestamps --no-index -pab"
