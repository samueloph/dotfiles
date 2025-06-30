# sbuild.conf: sbuild settings.                                    -*- Perl -*-
# Default settings are commented out.
# Note that all possible settings are listed here.  Many may be set on
# the command-line, and do not normally need setting here,
# e.g. $verbose.  Others need setting by each individual user in their
# ~/.sbuildrc, but are listed here for completeness.


##
## Build environment
##

# PATH
# Type: STRING
# PATH to set when running dpkg-buildpackage.
# See also related command line options in sbuild(1):
#   --use-snapshot
#$path =
#'/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games';

# LD_LIBRARY_PATH
# Type: STRING
# Library search path to use inside the chroot.
# See also related command line options in sbuild(1):
#   --use-snapshot
#$ld_library_path = undef;



##
## Build options
##

# DISTRIBUTION
# Type: STRING
# Default distribution.  By default, no distribution is defined, and the
# user must specify it with the -d option.  However, a default may be
# configured here if desired.  Users must take care not to upload to the
# wrong distribution when this option is set, for example experimental
# packages will be built for upload to unstable when this is not what is
# required. In unshare mode, this setting controls how the chroot tarball
# is created as rules like $unshare_mmdebstrap_extra_args and
# $unshare_mmdebstrap_distro_mangle use the value of the distribution and
# not the chroot name.
# See also related command line options in sbuild(1):
#   -d
#   --dist
#$distribution = undef;

# HOST_ARCH
# Type: STRING
# Host architecture (Arch we are building for)
# See also related command line options in sbuild(1):
#   --arch
#   --host
#host_arch = ...;

# BUILD_ARCH
# Type: STRING
# Build architecture (Arch we are building on).
# See also related command line options in sbuild(1):
#   --arch
#   --build
#build_arch = ...;

# BUILD_ARCH_ALL
# Type: BOOL
# Build architecture: all packages by default.
# See also related command line options in sbuild(1):
#   --arch-all
#   --no-arch-all
#$build_arch_all = undef;

# BUILD_ARCH_ANY
# Type: BOOL
# Build architecture: any packages by default.
# See also related command line options in sbuild(1):
#   --arch-any
#   --no-arch-any
#$build_arch_any = 1;

# BUILD_PROFILES
# Type: STRING
# Build profiles. Separated by spaces. Defaults to the value of the
# DEB_BUILD_PROFILES environment variable when building natively and to the
# cross and nocheck profiles when cross-building.
# See also related command line options in sbuild(1):
#   --profiles
#$build_profiles = undef;

# ENABLE_NETWORK
# Type: STRING
# By default network access is blocked during build (only implemented for
# the unshare mode). This lifts the restriction.
# See also related command line options in sbuild(1):
#   --enable-network
#$enable_network = 0;

# BUILD_ENV_CMND
# Type: STRING
# This command is run with the dpkg-buildpackage command line passed to it
# (in the chroot, if doing a chrooted build).  It is used by the sparc
# buildd (which is sparc64) to call the wrapper script that sets the
# environment to sparc (32-bit).  It could be used for other build
# environment setup scripts.  Note that this is superseded by schroot's
# 'command-prefix' option
#$build_env_cmnd = '';

# PGP_OPTIONS
# Type: ARRAY:STRING
# Additional signing options for dpkg-buildpackage
#$pgp_options = [
#		  '-us',
#		  '-uc'
#		];

# TOOLCHAIN_REGEX
# Type: ARRAY:STRING
# Regular expressions identifying toolchain packages.  Note that for
# backward compatibility, this is also settable using the array
# @toolchain_regex (deprecated), rather than an array reference.
#$toolchain_regex = [
#		      'binutils$',
#		      'dpkg-dev$',
#		      'gcc-[\\d.]+$',
#		      'g\\+\\+-[\\d.]+$',
#		      'libstdc\\+\\+',
#		      'libc[\\d.]+-dev$',
#		      'linux-kernel-headers$',
#		      'linux-libc-dev$',
#		      'gnumach-dev$',
#		      'hurd-dev$',
#		      'kfreebsd-kernel-headers$'
#		    ];

# CLEAN_APT_CACHE
# Type: BOOL
# Run apt-get distclean before the build to clean the apt package cache if
# the command is available. This makes sure that the build environment is
# not polluted by extra information but means that you need to run apt
# update before manually installing packages for debugging. You can disable
# this to save the extra call but remember to not use the information from
# the apt cache. Also note that this silently files when the command is not
# available to be compatible with older releases.
#$clean_apt_cache = 0;

# CHECK_SPACE
# Type: BOOL
# Check free disk space prior to starting a build.  sbuild requires the
# free space to be at least twice the size of the unpacked sources to allow
# a build to proceed.  Can be disabled to allow building if space is very
# limited, but the threshold to abort a build has been exceeded despite
# there being sufficient space for the build to complete.
#$check_space = 1;

# BUILD_PATH
# Type: STRING
# This option allows one to specify a custom path where the package is
# built inside the chroot. The sbuild user in the chroot must have
# permissions to create the path. Common writable locations are
# subdirectories of /tmp or /build. Using /tmp might be dangerous, because
# (depending on the chroot backend) the /tmp inside the chroot might be a
# world writable location that can be accessed by processes outside the
# chroot. The directory /build can only be accessed by the sbuild user and
# group and should be a safe location. The buildpath must be an empty
# directory because the last component of the path will be removed after
# the build is finished. Notice that depending on the chroot backend (see
# CHROOT_MODE), some locations inside the chroot might be bind mounts that
# are shared with other sbuild instances. You must avoid using these shared
# locations as the build path or otherwise concurrent runs of sbuild will
# likely fail. With the default schroot chroot backend, the directory
# /build is shared between multiple schroot sessions. You can change this
# behaviour in /etc/schroot/sbuild/fstab. The behaviour of other chroot
# backends will vary. To let sbuild choose a random build location of the
# format /build/packagename-XXXXXX/packagename-version/ where XXXXXX is a
# random ascii string, set this variable to the empty string.
# See also related command line options in sbuild(1):
#   --build-path
#$build_path = '/build/reproducible-path';

# DSC_DIR
# Type: STRING
# By default the package is built in a path of the following format
# /build/packagename-XXXXXX/packagename-version/ where packagename-version
# are replaced by the values in debian/changelog. This option allows one to
# specify a custom packagename-version path where the package is built
# inside the chroot. This is useful to specify a static path for different
# versions for example for ccache.
# See also related command line options in sbuild(1):
#   --dsc-dir
#$dsc_dir = undef;

# FORCE_ORIG_SOURCE
# Type: BOOL
# By default, the -s option only includes the .orig.tar.gz when needed
# (i.e. when the Debian revision is 0 or 1).  By setting this option to 1,
# the .orig.tar.gz will always be included when -s is used.
# See also related command line options in sbuild(1):
#   --force-orig-source
#$force_orig_source = 0;

# BUILD_SOURCE
# Type: BOOL
# By default, do not build a source package (binary only build).  Set to 1
# to force creation of a source package, but note that this is
# inappropriate for binary NMUs, where the option will always be disabled.
# See also related command line options in sbuild(1):
#   -s
#   --source
#   --no-source
$build_source = 1;

# BIN_NMU
# Type: STRING
# Binary NMU changelog entry.
# See also related command line options in sbuild(1):
#   --make-binNMU
#$bin_nmu = undef;

# BIN_NMU_VERSION
# Type: STRING
# Binary NMU version number.
# See also related command line options in sbuild(1):
#   --binNMU
#   --make-binNMU
#$bin_nmu_version = undef;

# BIN_NMU_TIMESTAMP
# Type: STRING
# Binary NMU timestamp. The timestamp is either given as n integer in Unix
# time or as a string in the format compatible with Debian changelog
# entries (i.e. as it is generated by date -R). If set to the default
# (undef) the date at build time is used.
# See also related command line options in sbuild(1):
#   --binNMU-timestamp
#$bin_nmu_timestamp = undef;

# APPEND_TO_VERSION
# Type: STRING
# Suffix to append to version number.  May be useful for derivative
# distributions.
# See also related command line options in sbuild(1):
#   --append-to-version
#$append_to_version = undef;

# BIN_NMU_CHANGELOG
# Type: STRING
# The content of a binary-only changelog entry. Leading and trailing
# newlines will be stripped.
# See also related command line options in sbuild(1):
#   --binNMU-changelog
#$bin_nmu_changelog = undef;

# GCC_SNAPSHOT
# Type: BOOL
# Build using current GCC snapshot?
# See also related command line options in sbuild(1):
#   --use-snapshot
#$gcc_snapshot = 0;

# CLEAN_SOURCE
# Type: BOOL
# When running sbuild from within an unpacked source tree, run the 'clean'
# target before generating the source package. This might require some of
# the build dependencies necessary for running the 'clean' target to be
# installed on the host machine. Only disable if you start from a clean
# checkout and you know what you are doing.
# See also related command line options in sbuild(1):
#   --clean-source
#   --no-clean-source
$clean_source = 0;

# SOURCE_ONLY_CHANGES
# Type: BOOL
# Also produce a changes file suitable for a source-only upload.
# See also related command line options in sbuild(1):
#   --source-only-changes
#$source_only_changes = 0;

# BUILD_AS_ROOT_WHEN_NEEDED
# Type: BOOL
# Build packages as root when Rules-Requires-Root: binary-targets.
#$build_as_root_when_needed = 0;



##
## Build timeouts
##

# STALLED_PKG_TIMEOUT
# Type: NUMERIC
# Time (in minutes) of inactivity after which a build is terminated.
# Activity is measured by output to the log file.
#$stalled_pkg_timeout = 150;

# MAX_LOCK_TRYS
# Type: NUMERIC
# Number of times to try waiting for a lock.
#$max_lock_trys = 120;

# LOCK_INTERVAL
# Type: NUMERIC
# Lock wait interval (seconds).  Maximum wait time is (max_lock_trys x
# lock_interval).
#$lock_interval = 5;

# INDIVIDUAL_STALLED_PKG_TIMEOUT
# Type: HASH:NUMERIC
# Some packages may exceed the general timeout (e.g. redirecting output to
# a file) and need a different timeout.  This has is a mapping between
# source package name and timeout.  Note that for backward compatibility,
# this is also settable using the hash %individual_stalled_pkg_timeout
# (deprecated) , rather than a hash reference.
#    $individual_stalled_pkg_timeout->{'llvm-toolchain-3.8'} = 300;
#    $individual_stalled_pkg_timeout->{'kicad-packages3d'} = 90;
#$individual_stalled_pkg_timeout = {};



##
## Build validation
##

# LINTIAN
# Type: STRING
# Path to lintian binary
#$lintian = 'lintian';

# RUN_LINTIAN
# Type: BOOL
# Run lintian?
# See also related command line options in sbuild(1):
#   --run-lintian
#   --no-run-lintian
#$run_lintian = 1;

# LINTIAN_OPTIONS
# Type: ARRAY:STRING
# Options to pass to lintian.  Each option is a separate arrayref element. 
# For example, ['-i', '-v'] to add -i and -v.
# See also related command line options in sbuild(1):
#   --lintian-opt
#   --lintian-opts
$lintian_opts = ['-i', '-I', '-E', '--pedantic'];

# LINTIAN_REQUIRE_SUCCESS
# Type: BOOL
# Let sbuild fail if lintian fails.
#$lintian_require_success = 0;

# PIUPARTS
# Type: STRING
# Path to piuparts binary
# See also related command line options in sbuild(1):
#   --piuparts-opt
#   --piuparts-opts
#$piuparts = 'piuparts';

# RUN_PIUPARTS
# Type: BOOL
# Run piuparts
# See also related command line options in sbuild(1):
#   --run-piuparts
#   --no-run-piuparts
#$run_piuparts = 0;

# PIUPARTS_OPTIONS
# Type: ARRAY:STRING
# Options to pass to piuparts.	Each option is a separate arrayref element.
#  For example, ['-b', '<chroot_tarball>'] to add -b and <chroot_tarball>.
#$piuparts_opts = undef;

# PIUPARTS_ROOT_ARGS
# Type: ARRAY:STRING
# Preceding arguments to launch piuparts as root. With the default value
# (the empty array) "sudo --" will be used as a prefix unless sbuild is run
# in unshare mode. If the first element in the array is the empty string,
# no prefixing will be done. If the value is a scalar, it will be prefixed
# by that string. If the scalar is an empty string, no prefixing will be
# done.
# See also related command line options in sbuild(1):
#   --piuparts-root-arg
#   --piuparts-root-args
#    # prefix with "sudo --":
#    $piuparts_root_args = [];
#    $piuparts_root_args = ['sudo', '--'];
#    # prefix with "env":
#    $piuparts_root_args = ['env'];
#    $piuparts_root_args = 'env';
#    # prefix with nothing:
#    $piuparts_root_args = '';
#    $piuparts_root_args = [''];
#    $piuparts_root_args = ['', 'whatever'];
#$piuparts_root_args = [];

# PIUPARTS_REQUIRE_SUCCESS
# Type: BOOL
# Let sbuild fail if piuparts fails.
#$piuparts_require_success = 0;

# AUTOPKGTEST
# Type: STRING
# Path to autopkgtest binary
# See also related command line options in sbuild(1):
#   --autopkgtest-opt
#   --autopkgtest-opts
#$autopkgtest = 'autopkgtest';

# RUN_AUTOPKGTEST
# Type: BOOL
# Run autopkgtest
# See also related command line options in sbuild(1):
#   --run-autopkgtest
#   --no-run-autopkgtest
#$run_autopkgtest = 0;

# AUTOPKGTEST_OPTIONS
# Type: ARRAY:STRING
# Options to pass to autopkgtest.  Each option is a separate arrayref
# element.  For example, ['-b', '<chroot_tarball>'] to add -b and
# <chroot_tarball>.
#$autopkgtest_opts = undef;

# AUTOPKGTEST_ROOT_ARGS
# Type: ARRAY:STRING
# Preceding arguments to launch autopkgtest as root. With the default value
# (the empty array) "sudo --" will be used as a prefix unless sbuild is run
# in unshare mode. If the first element in the array is the empty string,
# no prefixing will be done. If the value is a scalar, it will be prefixed
# by that string. If the scalar is an empty string, no prefixing will be
# done.
# See also related command line options in sbuild(1):
#   --autopkgtest-root-arg
#   --autopkgtest-root-args
#    # prefix with "sudo --":
#    $autopkgtest_root_args = [];
#    $autopkgtest_root_args = ['sudo', '--'];
#    # prefix with "env":
#    $autopkgtest_root_args = ['env'];
#    $autopkgtest_root_args = 'env';
#    # prefix with nothing:
#    $autopkgtest_root_args = '';
#    $autopkgtest_root_args = [''];
#    $autopkgtest_root_args = ['', 'whatever'];
#$autopkgtest_root_args = [];

# AUTOPKGTEST_REQUIRE_SUCCESS
# Type: BOOL
# Let sbuild fail if autopkgtest fails.
#$autopkgtest_require_success = 0;



##
## Chroot options
##

# CHROOT
# Type: STRING
# Default chroot (defaults to distribution[-arch][-sbuild]). In unshare
# mode, this setting is used to decide the name of the tarball in
# ~/.cache/sbuild. This setting does not influence what options are used to
# create the chroot in unshare mode (unless as the very last fallback for
# $unshare_mmdebstrap_extra_args). Use the distribution name (either in
# debian/changelog or by using --dist) for that.
# See also related command line options in sbuild(1):
#   -c
#   --chroot
#$chroot = undef;

# PACKAGE_CHECKLIST
# Type: STRING
# Where to store list currently installed packages inside chroot
#$package_checklist = '/var/lib/sbuild/package-checklist';

# PURGE_BUILD_DEPS
# Type: STRING
# When to purge the build dependencies after a build; possible values are
# "never", "successful", and "always"
# See also related command line options in sbuild(1):
#   -p
#   --purge
#   --purge-deps
#$purge_build_deps = 'always';

# PURGE_BUILD_DIRECTORY
# Type: STRING
# When to purge the build directory after a build; possible values are
# "never", "successful", and "always"
# See also related command line options in sbuild(1):
#   -p
#   --purge
#   --purge-build
#$purge_build_directory = 'always';

# PURGE_SESSION
# Type: STRING
# Purge the schroot session following a build.	This is useful in
# conjunction with the --purge and --purge-deps options when using snapshot
# chroots, since by default the snapshot will be deleted. Possible values
# are "always" (default), "never", and "successful"
# See also related command line options in sbuild(1):
#   -p
#   --purge
#   --purge-session
#$purge_session = 'always';

# CHROOT_MODE
# Type: STRING
# Mechanism to use for chroot virtualisation.  Possible value are "schroot"
# (default), "sudo", "autopkgtest" and "unshare".
# See also related command line options in sbuild(1):
#   --chroot-mode
$chroot_mode = 'unshare';

# CHROOT_ALIASES
# Type: HASH:STRING
# A mapping of distribution names to their aliases which will be used to
# look up chroots. This is similar to the "aliases" schroot configuration
# option. With the unshare backend, this has a similar effect as placing a
# symlink into ~/.cache/sbuild. Use the $unshare_mmdebstrap_distro_mangle
# option instead of this option if you want to declare a mapping from an
# "overlay" distribution (like experimental or backcports) to its base.
# This option is a hash because the order of its entries does not matter.
# Note, that if you are using unshare mode, you might still need an entry
# in $unshare_mmdebstrap_distro_mangle in addition to an entry in this
# option because this option only influences the chroot lookup. The
# distribution name passed to mmdebstrap is not influenced by this option.
#$chroot_aliases = {
#		     'UNRELEASED' => 'unstable',
#		     'rc-buggy' => 'experimental'
#		   };

# CHROOT_SPLIT
# Type: BOOL
# Run in split mode?  In split mode, apt-get and dpkg are run on the host
# system, rather than inside the chroot.
#$chroot_split = 0;

# CHROOT_SETUP_SCRIPT
# Type: STRING
# Script to run to perform custom setup tasks in the chroot.
# See also related command line options in sbuild(1):
#   --setup-hook
#$chroot_setup_script = undef;

# APT_CLEAN
# Type: BOOL
# APT clean.  1 to enable running "apt-get clean" at the start of each
# build, or 0 to disable.
# See also related command line options in sbuild(1):
#   --apt-clean
#   --no-apt-clean
#$apt_clean = 0;

# APT_KEEP_DOWNLOADED_PACKAGES
# Type: BOOL
# Keep downloaded packages in cache by APT. Controls
# APT::Keep-Downloaded-Packages option used when downloading dependencies.
# This option only makes sense if /var/cache/apt/archive inside the chroot
# is made persistent between multiple sbuild invocations. 1 to keep
# downloaded packages in cache, or 0 to delete them after installation.
#$apt_keep_downloaded_packages = 0;

# APT_UPDATE
# Type: BOOL
# APT update.  1 to enable running "apt-get update" at the start of each
# build, or 0 to disable. This option only applies to the default
# repositories of the chroot: the internal sbuild apt repository, the
# repository for extra packages (see EXTRA_PACKAGES) and any repositories
# set via EXTRA_REPOSITORIES are always updated. It is not recommended to
# set this option to 0 because you should build using the latest available
# packages in each distribution. If you do disable updates you need to
# ensure that the chroot contains downloaded package lists or apt will be
# unable to install any packages. If you are using the
# unshare chroot mode you can add "--skip=cleanup/apt/lists" to
# UNSHARE_MMDEBSTRAP_EXTRA_ARGS to retain the package lists inside the
# chroot taball.
# See also related command line options in sbuild(1):
#   --apt-update
#   --no-apt-update
#$apt_update = 1;

# APT_UPDATE_ARCHIVE_ONLY
# Type: BOOL
# Update local temporary APT archive directly (1, the default) or set to 0
# to disable and do a full apt update (not recommended in case the mirror
# content has changed since the build started).
#$apt_update_archive_only = 1;

# APT_UPGRADE
# Type: BOOL
# APT upgrade.	1 to enable running "apt-get upgrade" at the start of each
# build, or 0 to disable.
# See also related command line options in sbuild(1):
#   --apt-upgrade
#   --no-apt-upgrade
#$apt_upgrade = 0;

# APT_DISTUPGRADE
# Type: BOOL
# APT distupgrade.  1 to enable running "apt-get dist-upgrade" at the start
# of each build, or 0 to disable.
# See also related command line options in sbuild(1):
#   --apt-distupgrade
#   --no-apt-distupgrade
#$apt_distupgrade = 1;

# APT_ALLOW_UNAUTHENTICATED
# Type: BOOL
# Force APT to accept unauthenticated packages.  By default,
# unauthenticated packages are not allowed.  This is to keep the build
# environment secure, using apt-secure(8).  By setting this to 1,
# APT::Get::AllowUnauthenticated is set to "true" when running apt-get.
# This is disabled by default: only enable it if you know what you are
# doing.
#$apt_allow_unauthenticated = 0;

# EXTERNAL_COMMANDS
# Type: HASH:ARRAY:STRING
# External commands to run at various stages of a build. Commands are held
# in a hash of arrays of arrays data structure. There is no equivalent for
# the --anything-failed-commands command line option. All percent escapes
# mentioned in the sbuild man page can be used.
# See also related command line options in sbuild(1):
#   --setup-hook
#   --pre-build-commands
#   --chroot-setup-commands
#   --chroot-update-failed-commands
#   --build-deps-failed-commands
#   --build-failed-commands
#   --anything-failed-commands
#   --starting-build-commands
#   --finished-build-commands
#   --chroot-cleanup-commands
#   --post-build-commands
#   --post-build-failed-commands
#    # general format
#    $external_commands = {
#        "pre-build-commands" => [
#            ['foo', 'arg1', 'arg2'],
#            ['bar', 'arg1', 'arg2', 'arg3'],
#        ],
#        "chroot-setup-commands" => [
#            ['foo', 'arg1', 'arg2'],
#            ['bar', 'arg1', 'arg2', 'arg3'],
#        ],
#        "chroot-update-failed-commands" => [
#            ['foo', 'arg1', 'arg2'],
#            ['bar', 'arg1', 'arg2', 'arg3'],
#        ],
#        "build-deps-failed-commands" => [
#            ['foo', 'arg1', 'arg2'],
#            ['bar', 'arg1', 'arg2', 'arg3'],
#        ],
#        "build-failed-commands" => [
#            ['foo', 'arg1', 'arg2'],
#            ['bar', 'arg1', 'arg2', 'arg3'],
#        ],
#        "starting-build-commands" => [
#            ['foo', 'arg1', 'arg2'],
#            ['bar', 'arg1', 'arg2', 'arg3'],
#        ],
#        "finished-build-commands" => [
#            ['foo', 'arg1', 'arg2'],
#            ['bar', 'arg1', 'arg2', 'arg3'],
#        ],
#        "chroot-cleanup-commands" => [
#            ['foo', 'arg1', 'arg2'],
#            ['bar', 'arg1', 'arg2', 'arg3'],
#        ],
#        "post-build-commands" => [
#            ['foo', 'arg1', 'arg2'],
#            ['bar', 'arg1', 'arg2', 'arg3'],
#        ],
#        "post-build-failed-commands" => [
#            ['foo', 'arg1', 'arg2'],
#            ['bar', 'arg1', 'arg2', 'arg3'],
#        ],
#    };
#    # the equivalent of specifying --anything-failed-commands=%SBUILD_SHELL on the
#    # command line
#    $external_commands = {
#        "chroot-update-failed-commands" => [ [ '%SBUILD_SHELL' ] ],
#        "build-deps-failed-commands" => [ [ '%SBUILD_SHELL' ] ],
#        "build-failed-commands" => [ [ '%SBUILD_SHELL' ] ],
#    };
#$external_commands = {
#			'build-deps-failed-commands' => [],
#			'build-failed-commands' => [],
#			'chroot-cleanup-commands' => [],
#			'chroot-setup-commands' => [],
#			'chroot-update-failed-commands' => [],
#			'finished-build-commands' => [],
#			'post-build-commands' => [],
#			'pre-build-commands' => [],
#			'starting-build-commands' => []
#		      };

# LOG_EXTERNAL_COMMAND_OUTPUT
# Type: BOOL
# Log standard output of commands run by sbuild?
# See also related command line options in sbuild(1):
#   --log-external-command-output
#$log_external_command_output = 1;

# LOG_EXTERNAL_COMMAND_ERROR
# Type: BOOL
# Log standard error of commands run by sbuild?
# See also related command line options in sbuild(1):
#   --log-external-command-error
#$log_external_command_error = 1;

# PURGE_EXTRA_PACKAGES
# Type: BOOL
# Try to remove all additional packages that are not strictly required for
# the build right after build dependencies were installed. This currently
# works best with the aspcud resolver. The apt resolver will not make as
# much effort to remove all unneeded packages and will keep all providers
# of a virtual package and all packages from any dependency alternative
# that happen to be installed. The aptitude and xapt resolver do not
# implement this feature yet. The removed packages are not yet added again
# after the build finished. This can have undesirable side effects like
# lintian not working (because there is no apt to install its dependencies)
# or bare chroots becoming totally unusable after apt was removed from
# them. Thus, this option should only be used with throw-away chroots like
# schroot provides them where the original state is automatically restored
# after each build.
# See also related command line options in sbuild(1):
#   --purge-extra-packages
#$purge_extra_packages = 0;



##
## Chroot options (unshare)
##

# UNSHARE_TMPDIR_TEMPLATE
# Type: STRING
# Template used to create the temporary unpack directory for the unshare
# chroot mode. Uses $TMPDIR if set and /tmp otherwise. In unshare mode, all
# components of the path need to be accessible by the unshared user (world
# execute permissions). In unshare mode, the unshared user needs to have
# write permissions to this directory.
#    # Choose /var/tmp if /tmp is too small
#    $unshare_tmpdir_template = '/var/tmp/tmp.sbuild.XXXXXXXXXX'
#$unshare_tmpdir_template = '/tmp/tmp.sbuild.XXXXXXXXXX';

# UNSHARE_BIND_MOUNTS
# Type: ARRAY
# Bind mount directories from the outside to a mountpoint inside the chroot
# in unshare mode.
#    $unshare_bind_mounts = [ { directory => "/home/path/outside", mountpoint => "/path/inside" } ];
#$unshare_bind_mounts = [];

# UNSHARE_MMDEBSTRAP_AUTO_CREATE
# Type: BOOL
# This is an experimental feature. In unshare mode, if the desired chroot
# tarball does not exist or if it is too old (see
# UNSHARE_MMDEBSTRAP_MAX_AGE), run mmdebstrap to create a new chroot that
# will be used for the build. Refer to UNSHARE_MMDEBSTRAP_EXTRA_ARGS to
# learn how to customize the mmdebstrap invocation for your chroots.
#$unshare_mmdebstrap_auto_create = 1;

# MMDEBSTRAP
# Type: STRING
# Path to mmdebstrap binary
#$mmdebstrap = 'mmdebstrap';

# UNSHARE_MMDEBSTRAP_KEEP_TARBALL
# Type: BOOL
# This is an experimental feature. In unshare mode and only if
# UNSHARE_MMDEBSTRAP_AUTO_CREATE is true, write the created tarball back to
# its appropriate location in ~/.cache/sbuild/${release}-${arch}.tar. If a
# chroot tarball was given explicitly by passing a path with the --chroot
# option, that chroot will never be updated by sbuild. But if the chroot
# tarball was outdated (see UNSHARE_MMDEBSTRAP_MAX_AGE), it will still get
# re-created and used but not saved back to the given path.
$unshare_mmdebstrap_keep_tarball = 1;

# UNSHARE_MMDEBSTRAP_EXTRA_ARGS
# Type: HASH:STRING
# This is an experimental feature. In unshare mode, when mmdebstrap is run
# because UNSHARE_MMDEBSTRAP_AUTO_CREATE was set to true, pass these extra
# arguments to the mmdebstrap invocation. The option array is given as
# key/value pairs. Each key will be matched against strings created from
# sbuild configuration variables, namely: DISTRIBUTION,
# DISTRIBUTION-BUILD_ARCH, DISTRIBUTION-BUILD_ARCH-HOST_ARCH as well as
# against the name of the chroot itself (defined if you use --chroot). If a
# key matches one of these strings, the value, containing extra mmdebstrap
# arguments is appended to the mmdebstrap argument list. A key can be a
# plain string, in which case glob-style expressions can be used. If the
# key is a plain string, it has to fully match. If the key is a plain
# string, percentage escapes %a and %r will be replaced by host
# architecture and distribution of the current build, respectively. A key
# can also be a precompiled qr// regular expression but match groups cannot
# be referenced in the extra arguments. The value is an array of extra
# arguments which are appended to the end of the mmdebstrap exec array.
#    
#    $unshare_mmdebstrap_extra_args = [
#       "*-%a-arm64" => [ ... ] # options for cross-builds with arm64 as the host architecture
#       "debcargo-unstable-%a" => ["--include=dh-cargo,cargo"], # %a will be replaced by the host architecture
#       "ubuntu-*" => [ "--components=main,universe,multiverse" ], # add universe and multiverse for ubuntu
#       "/srv/custom-chroot.tar" => [ "--variant=apt", --arch="i386,ppc64el" ],
#       qr/(jessie|stretch)-amd64/ => [ ... ] # do something special for jessie and stretch
#       "{jessie,stretch}-amd64"   => [ ... ] # the same as above but with a glob instead of a regex
#    ];
#$unshare_mmdebstrap_extra_args = [
#				    '*-{backports}',
#				    [
#				      '--setup-hook=echo "deb
#http://deb.debian.org/debian %r main" >
#"$1"/etc/apt/sources.list.d/%r.list'
#				    ],
#				    qr/^(experimental|rc-buggy)$/,
#				    [
#				      '--setup-hook=echo "deb
#http://deb.debian.org/debian experimental main" >
#"$1"/etc/apt/sources.list.d/experimental.list'
#				    ]
#				  ];

# UNSHARE_MMDEBSTRAP_ENV_CMND
# Type: ARRAY
# This is an experimental feature. In unshare mode, when mmdebstrap is used
# to create the chroot environment, prefix that command with this option
# array.
#    $unshare_mmdebstrap_env_cmnd = [ "env", "TMPDIR=/dev/shm/" ];
#$unshare_mmdebstrap_env_cmnd = [];

# UNSHARE_MMDEBSTRAP_MAX_AGE
# Type: NUMERIC
# This is an experimental feature. In unshare mode, with
# UNSHARE_MMDEBSTRAP_AUTO_CREATE=1, consider tarballs as outdated if they
# are older than the number of seconds given by this option. A negative
# value completely disables this check.
#$unshare_mmdebstrap_max_age = 604800;

# UNSHARE_MMDEBSTRAP_DISTRO_MANGLE
# Type: ARRAY:STRING
# The distribution you want to build for might be an "overlay" for another
# distribution. For example if you build for stable-backports, you want to
# create a chroot for stable and then add backports or to build for
# experimental you want to build for unstable and then add experimental on
# top. This option allows one to perform this name mangling from
# distribution name to desired base distribution. The option array is given
# as substitution pairs. The first regex which matches is applied and the
# remaining regexes are skipped. If instead you want to define an alias of
# one name to another like the "aliases" schroot configuration option or
# symlinks in unshare mode, use the $chroot_aliases option instead. This
# option is an array instead of a hash because the order of entries
# matters.
#    $unshare_mmdebstrap_distro_mangle = [qr/(.*)-armhf$/ => '$1-arm64']
#$unshare_mmdebstrap_distro_mangle = [
#				      
#qr/^(experimental|rc-buggy|UNRELEASED.*)$/,
#				       'unstable',
#				       qr/^(.*)-backports$/,
#				       '$1',
#				       qr/^(.*)-security$/,
#				       '$1'
#				     ];



##
## Core options
##

# BUILD_USER
# Type: STRING
# Username used for running dpkg-buildpackage. By default the user running
# sbuild and `sbuild` for the unshare mode is used within the chroot as
# well but that might allow a process from within the chroot to break out
# of the chroot by attaching to a process running outside the chroot with
# eg. gdb and then becoming root inside the chroot through schroot and thus
# be able to leave the chroot.
#build_user = ...;

# BUILD_DIR
# Type: STRING
# Output directory for build artifacts created by dpkg-buildpackage and the
# log file. Defaults to the current directory if unspecified. It is used as
# the location of chroot symlinks (obsolete) and for current build log
# symlinks and some build logs.  There is no default; if unset, it defaults
# to the current working directory.  $HOME/build is another common
# configuration.
# See also related command line options in sbuild(1):
#   --build-dir
#    $build_dir = '/home/pete/build';
#build_dir = ...;

# SBUILD_MODE
# Type: STRING
# sbuild behaviour; possible values are "user" (exit status reports build
# failures) and "buildd" (exit status does not report build failures) for
# use in a buildd setup.  "buildd" also currently implies enabling of
# "legacy features" such as chroot symlinks in the build directory and the
# creation of current symlinks in the build directory.
# See also related command line options in sbuild(1):
#   --sbuild-mode
#$sbuild_mode = 'user';

# ENVIRONMENT_FILTER
# Type: ARRAY:STRING
# Only environment variables matching one of the regular expressions in
# this arrayref will be passed to dpkg-buildpackage and other programs run
# by sbuild. The default value for this configuration setting is the list
# of variable names as returned by Dpkg::BuildInfo::get_build_env_allowed()
# which is also the list of variable names that is whitelisted to be
# recorded in .buildinfo files. Caution: the default value listed below was
# retrieved from the dpkg Perl library version available when this man page
# was generated. It might be different if your dpkg Perl library version
# differs.
#    # Setting the old environment filter
#    $environment_filter = ['^PATH$',
#    			'^DEB(IAN|SIGN)?_[A-Z_]+$',
#    			'^(C(PP|XX)?|LD|F)FLAGS(_APPEND)?$',
#    			'^USER(NAME)?$',
#    			'^LOGNAME$',
#    			'^HOME$',
#    			'^TERM$',
#    			'^SHELL$'];
#    # Appending FOOBAR to the default
#    use Dpkg::BuildInfo;
#    $environment_filter = [(sort (map "^$_\$", Dpkg::BuildInfo::get_build_env_allowed())), '^FOOBAR$'];
#    # Removing FOOBAR from the default
#    use Dpkg::BuildInfo;
#    $environment_filter = [ sort (map /^FOOBAR$/ ? () : "^$_\$", Dpkg::BuildInfo::get_build_env_allowed()) ];
#$environment_filter = [
#			 '^AR$',
#			 '^ARFLAGS$',
#			 '^AS$',
#			 '^ASFLAGS$',
#			 '^ASFLAGS_FOR_BUILD$',
#			 '^AWK$',
#			 '^CC$',
#			 '^CFLAGS$',
#			 '^CFLAGS_FOR_BUILD$',
#			 '^CPP$',
#			 '^CPPFLAGS$',
#			 '^CPPFLAGS_FOR_BUILD$',
#			 '^CXX$',
#			 '^CXXFLAGS$',
#			 '^CXXFLAGS_FOR_BUILD$',
#			 '^DEB_BUILD_OPTIONS$',
#			 '^DEB_BUILD_PROFILES$',
#			 '^DEB_VENDOR$',
#			 '^DFLAGS$',
#			 '^DFLAGS_FOR_BUILD$',
#			 '^DPKG_ADMINDIR$',
#			 '^DPKG_DATADIR$',
#			 '^DPKG_GENSYMBOLS_CHECK_LEVEL$',
#			 '^DPKG_ORIGINS_DIR$',
#			 '^DPKG_ROOT$',
#			 '^FC$',
#			 '^FFLAGS$',
#			 '^FFLAGS_FOR_BUILD$',
#			 '^GNUMAKEFLAGS$',
#			 '^LANG$',
#			 '^LC_ADDRESS$',
#			 '^LC_ALL$',
#			 '^LC_COLLATE$',
#			 '^LC_CTYPE$',
#			 '^LC_IDENTIFICATION$',
#			 '^LC_MEASUREMENT$',
#			 '^LC_MESSAGES$',
#			 '^LC_MONETARY$',
#			 '^LC_NAME$',
#			 '^LC_NUMERIC$',
#			 '^LC_PAPER$',
#			 '^LC_TELEPHONE$',
#			 '^LC_TIME$',
#			 '^LD$',
#			 '^LDFLAGS$',
#			 '^LDFLAGS_FOR_BUILD$',
#			 '^LD_LIBRARY_PATH$',
#			 '^LEX$',
#			 '^M2C$',
#			 '^MAKE$',
#			 '^MAKEFLAGS$',
#			 '^OBJC$',
#			 '^OBJCFLAGS$',
#			 '^OBJCFLAGS_FOR_BUILD$',
#			 '^OBJCXX$',
#			 '^OBJCXXFLAGS$',
#			 '^OBJCXXFLAGS_FOR_BUILD$',
#			 '^PC$',
#			 '^RANLIB$',
#			 '^SOURCE_DATE_EPOCH$',
#			 '^YACC$'
#		       ];

# BUILD_ENVIRONMENT
# Type: HASH:STRING
# Environment to set during the build.	Defaults to setting PATH and
# LD_LIBRARY_PATH only.  Note that these environment variables are not
# subject to filtering with ENVIRONMENT_FILTER.  Example:
#    $build_environment = {
#            'CCACHE_DIR' => '/build/cache'
#    };
#$build_environment = {};

# BATCH_MODE
# Type: BOOL
# Enable batch mode?
# See also related command line options in sbuild(1):
#   -b
#   --batch
#$batch_mode = 0;

# CORE_DEPENDS
# Type: ARRAY:STRING
# Packages which must be installed in the chroot for all builds.
#$core_depends = [
#		   'build-essential:native'
#		 ];

# MANUAL_DEPENDS
# Type: ARRAY:STRING
# Additional per-build dependencies.
# See also related command line options in sbuild(1):
#   --add-depends
#$manual_depends = [];

# MANUAL_CONFLICTS
# Type: ARRAY:STRING
# Additional per-build dependencies.
# See also related command line options in sbuild(1):
#   --add-conflicts
#$manual_conflicts = [];

# MANUAL_DEPENDS_ARCH
# Type: ARRAY:STRING
# Additional per-build dependencies.
# See also related command line options in sbuild(1):
#   --add-depends-arch
#$manual_depends_arch = [];

# MANUAL_CONFLICTS_ARCH
# Type: ARRAY:STRING
# Additional per-build dependencies.
# See also related command line options in sbuild(1):
#   --add-conflicts-arch
#$manual_conflicts_arch = [];

# MANUAL_DEPENDS_INDEP
# Type: ARRAY:STRING
# Additional per-build dependencies.
# See also related command line options in sbuild(1):
#   --add-depends-indep
#$manual_depends_indep = [];

# MANUAL_CONFLICTS_INDEP
# Type: ARRAY:STRING
# Additional per-build dependencies.
# See also related command line options in sbuild(1):
#   --add-conflicts-indep
#$manual_conflicts_indep = [];

# ARCHIVE
# Type: STRING
# Archive being built.	Only set in build log.	This might be useful for
# derivative distributions.
# See also related command line options in sbuild(1):
#   --archive
#$archive = undef;

# JOB_FILE
# Type: STRING
# Job status file (only used in batch mode)
#$job_file = 'build-progress';



##
## Dependency resolution
##

# BUILD_DEP_RESOLVER
# Type: STRING
# Build dependency resolver.  The 'apt' resolver is currently the default,
# and recommended for most users.  This resolver uses apt-get to resolve
# dependencies.  Alternative resolvers are 'apt', 'aptitude' and 'aspcud'.
# The 'apt' resolver uses a built-in resolver module while the 'aptitude'
# resolver uses aptitude to resolve build dependencies.  The aptitude
# resolver is similar to apt, but is useful in more complex situations,
# such as where multiple distributions are required, for example when
# building from experimental, where packages are needed from both unstable
# and experimental, but defaulting to unstable. If the dependency situation
# is too complex for either apt or aptitude to solve it, you can use the
# 'aspcud' resolver which (in contrast to apt and aptitude) is a real
# solver (in the math sense) and will thus always find a solution if a
# solution exists. Additionally, the 'null' solver is provided. It is a
# dummy resolver which does not install, upgrade or remove any packages.
# This allows one to completely control package installation via hooks.
# See also related command line options in sbuild(1):
#   --build-dep-resolver
#$build_dep_resolver = 'apt';

# ASPCUD_CRITERIA
# Type: STRING
# Optimization criteria in extended MISC 2012 syntax passed to aspcud
# through apt-cudf.  Optimization criteria are separated by commas, sorted
# by decreasing order of priority and are prefixed with a polarity (+ to
# maximize and - to minimize).	The default criteria is
# '-removed,-changed,-new' which first minimizes the number of removed
# packages, then the number of changed packages (up or downgrades) and then
# the number of new packages. A common task is to minimize the number of
# packages from experimental.  To do this you can add a criteria like
# '-count(solution,APT-Release:=/a=experimental/)' to the default criteria.
#  This will then minimize the number of packages in the solution which
# contain the string 'a=experimental' in the 'APT-Release' field of the
# EDSP output created by apt. See the apt-cudf man page help on the
# --criteria option for more information.
# See also related command line options in sbuild(1):
#   --aspcud-criteria
#$aspcud_criteria = '-removed,-changed,-new';

# RESOLVE_ALTERNATIVES
# Type: BOOL
# Should the dependency resolver use alternatives in Build-Depends,
# Build-Depends-Arch and Build-Depends-Indep?  By default, using 'apt'
# resolver, only the first alternative will be used; all other alternatives
# will be removed.  When using the 'aptitude' resolver, it will default to
# using all alternatives.  Note that this does not include
# architecture-specific alternatives, which are reduced to the build
# architecture prior to alternatives removal.  This should be left disabled
# when building for unstable; it may be useful when building for
# experimental or backports.  Set to undef to use the default, 1 to enable,
# or 0 to disable.
# See also related command line options in sbuild(1):
#   --resolve-alternatives
#   --no-resolve-alternatives
#    $resolve_alternatives = 0;
#$resolve_alternatives = undef;

# EXTRA_PACKAGES
# Type: ARRAY:STRING
# Additional per-build packages available as build dependencies.
# See also related command line options in sbuild(1):
#   --extra-package
#$extra_packages = [];

# EXTRA_REPOSITORY_KEYS
# Type: ARRAY:STRING
# Additional per-build apt repository keys.
# See also related command line options in sbuild(1):
#   --extra-repository-key
#$extra_repository_keys = [];

# EXTRA_REPOSITORIES
# Type: ARRAY:STRING
# Additional per-build apt repositories.
# See also related command line options in sbuild(1):
#   --extra-repository
#$extra_repositories = [];

# BD_UNINSTALLABLE_EXPLAINER
# Type: STRING
# Method to use for explaining build dependency installation failures.
# Possible value are "dose3" (default), "apt" and "none". Set to "none",
# the empty string "" or Perl undef to disable running any explainer.
# See also related command line options in sbuild(1):
#   --bd-uninstallable-explainer
#$bd_uninstallable_explainer = 'dose3';



##
## Logging options
##

# VERBOSE
# Type: NUMERIC
# Verbose logging level
#$verbose = 0;

# DEBUG
# Type: NUMERIC
# Debug logging level
#$debug = 0;

# NOLOG
# Type: BOOL
# Disable use of log file
# See also related command line options in sbuild(1):
#   -n
#   --nolog
#$nolog = 0;

# LOG_DIR
# Type: STRING
# Directory for storing build logs.  This defaults to '.' when SBUILD_MODE
# is set to 'user' (the default), and to '$HOME/logs' when SBUILD_MODE is
# set to 'buildd'.
#$log_dir = undef;

# LOG_FILENAME_TIMESTAMP_FORMAT
# Type: STRING
# Set the format of the timestamp used in the build log filename
# See also related command line options in sbuild(1):
#   --log-filename-ts-format
#$log_filename_timestamp_format = '%FT%TZ';

# LOG_COLOUR
# Type: BOOL
# Add colour highlighting to interactive log messages (informational,
# warning and error messages).	Log files will not be coloured.
#$log_colour = 1;

# LOG_FILTER
# Type: BOOL
# Filter variable strings from log messages such as the chroot name and
# build directory
#$log_filter = 0;

# LOG_HIDDEN_SECTIONS
# Type: ARRAY:STRING
# Log sections to prevent from being printed to standard output. Supported
# section names that can be hidden are: postbuild, cleanup, changes,
# buildinfo, contents and summary.
# See also related command line options in sbuild(1):
#   --hide-log-sections
#$log_hidden_sections = [];

# MAILTO
# Type: STRING
# email address to mail build logs to
# See also related command line options in sbuild(1):
#   --mail-log-to
#$mailto = '';

# MAILTO_HASH
# Type: HASH:STRING
# Like MAILTO, but per-distribution.  This is a hashref mapping
# distribution name to MAILTO.	Note that for backward compatibility, this
# is also settable using the hash %mailto (deprecated), rather than a hash
# reference.
#$mailto_hash = {};

# MAILFROM
# Type: STRING
# email address set in the From line of build logs
# See also related command line options in sbuild(1):
#   --mailfrom
#$mailfrom = 'Source Builder <sbuild>';

# COMPRESS_BUILD_LOG_MAILS
# Type: BOOL
# Should build log mails be compressed?
#$compress_build_log_mails = 1;

# MIME_BUILD_LOG_MAILS
# Type: BOOL
# Should build log mails be MIME encoded?
#$mime_build_log_mails = 1;



##
## Maintainer options
##

# MAINTAINER_NAME
# Type: STRING
# Name to use as override in .changes files for the Maintainer field.  The
# Maintainer field will not be overridden unless set here.
# See also related command line options in sbuild(1):
#   -m
#   --maintainer
#$maintainer_name = undef;

# UPLOADER_NAME
# Type: STRING
# Name to use as override in .changes file for the Changed-By: field.
# See also related command line options in sbuild(1):
#   -e
#   --uploader
#$uploader_name = undef;

# KEY_ID
# Type: STRING
# Key ID to use in .changes for the current upload.  It overrides both
# $maintainer_name and $uploader_name.
# See also related command line options in sbuild(1):
#   -k
#   --keyid
# $key_id='${GPG_KEY-PLACEHOLDER}';



##
## Multiarch support (transitional)
##

# CROSSBUILD_CORE_DEPENDS
# Type: HASH:ARRAY:STRING
# Per-architecture dependencies required for cross-building. By default, if
# a Debian architecture is not found as a key in this hash, the following
# will be added to the Build-Depends:
# crossbuild-essential-${hostarch}:native, libc-dev, libstdc++-dev. The
# latter two are to work around bug #815172.
#    
#    $crossbuild_core_depends = {
#        nios2 => ['crossbuild-essential-nios2:native', 'special-package'],
#        musl-linux-mips => ['crossbuild-essential-musl-linux-mips:native', 'super-special'],
#    }
#$crossbuild_core_depends = {};



##
## Programs
##

# MAILPROG
# Type: STRING
# Program to use to send mail
#$mailprog = '/usr/sbin/sendmail';

# SUDO
# Type: STRING
# Path to sudo binary
#$sudo = 'sudo';

# SU
# Type: STRING
# Path to su binary
#$su = 'su';

# SCHROOT
# Type: STRING
# Path to schroot binary
#$schroot = 'schroot';

# SCHROOT_OPTIONS
# Type: ARRAY:STRING
# Additional command-line options for schroot
#$schroot_options = [
#		      '-q'
#		    ];

# AUTOPKGTEST_VIRT_SERVER
# Type: STRING
# Path to autopkgtest-virt-* binary, selecting the virtualization server.
# See also related command line options in sbuild(1):
#   --autopkgtest-virt-server
#$autopkgtest_virt_server = 'autopkgtest-virt-schroot';

# AUTOPKGTEST_VIRT_SERVER_OPTIONS
# Type: ARRAY:STRING
# Additional command-line options for autopkgtest-virt-*
# See also related command line options in sbuild(1):
#   --autopkgtest-virt-server-opt
#   --autopkgtest-virt-server-opts
#$autopkgtest_virt_server_options = [];

# APT_GET
# Type: STRING
# Path to apt-get binary
#$apt_get = 'apt-get';

# APT_CACHE
# Type: STRING
# Path to apt-cache binary
#$apt_cache = 'apt-cache';

# APTITUDE
# Type: STRING
# Path to aptitude binary
#$aptitude = 'aptitude';

# XAPT
# Type: STRING
#$xapt = 'xapt';

# DPKG_BUILDPACKAGE_USER_OPTIONS
# Type: ARRAY:STRING
# Additional command-line options for dpkg-buildpackage.
# See also related command line options in sbuild(1):
#   --debbuildopt
#   --debbuildopts
#   --jobs
#$dpkg_buildpackage_user_options = [];

# DPKG_FILE_SUFFIX
# Type: STRING
# Suffix to add to filename for files generated by dpkg-buildpackage
# See also related command line options in sbuild(1):
#   --dpkg-file-suffix
#$dpkg_file_suffix = '';

# DPKG_SOURCE
# Type: STRING
# Path to dpkg-source binary
#$dpkg_source = 'dpkg-source';

# DPKG_SOURCE_OPTIONS
# Type: ARRAY:STRING
# Additional command-line options for dpkg-source
# See also related command line options in sbuild(1):
#   --dpkg-source-opt
#   --dpkg-source-opts
#$dpkg_source_opts = [];

# MD5SUM
# Type: STRING
# Path to md5sum binary
#$md5sum = 'md5sum';



##
## Statistics
##

# STATS_DIR
# Type: STRING
# Directory for writing build statistics to
# See also related command line options in sbuild(1):
#   --stats-dir
#stats_dir = ...;
#

# Use apt-cacher-ng
$unshare_mmdebstrap_extra_args = [
    '*' => [ '--aptopt=Acquire::http { Proxy "http://127.0.0.1:3142"; }' ],
];

# Drop in a shell inside the build environment on failures
$external_commands = { "build-failed-commands" => [ [ '%SBUILD_SHELL' ] ] };

1;
