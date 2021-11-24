#!/bin/bash

# Regenerate with "argbash --strip user-content -o install-parsing.sh install-parsing.sh"
# ARG_OPTIONAL_SINGLE([version],[v],[The version of mambaforge to install.],[latest])
# ARG_OPTIONAL_SINGLE([filepath],[f],[The full filepath to the mambaforge installer script],[])
# ARG_DEFAULTS_POS([])
# ARG_HELP([Installs the specified version of mambaforge.])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.10.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info


die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='vfh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_version="latest"
_arg_filepath=


print_help()
{
	printf '%s\n' "Installs the specified version of mambaforge."
	printf 'Usage: %s [-v|--version <arg>] [-f|--filepath <arg>] [-h|--help]\n' "$0"
	printf '\t%s\n' "-v, --version: The version of mambaforge to install. (default: 'latest')"
	printf '\t%s\n' "-f, --filepath: The full filepath to the mambaforge installer script (no default)"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-v|--version)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_version="$2"
				shift
				;;
			--version=*)
				_arg_version="${_key##--version=}"
				;;
			-v*)
				_arg_version="${_key##-v}"
				;;
			-f|--filepath)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_filepath="$2"
				shift
				;;
			--filepath=*)
				_arg_filepath="${_key##--filepath=}"
				;;
			-f*)
				_arg_filepath="${_key##-f}"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
				;;
		esac
		shift
	done
}

parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
