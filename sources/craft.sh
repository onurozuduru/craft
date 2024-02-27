
# Modes are function names to call
MODE_CURRENT=""
MODE_GLUE="glue_mode"
MODE_SPLIT="split_mode"

SHEBANG='#!/bin/bash'

IS_PERMANENT="NO"
IS_OVERWRITE="NO"

GLUE_OUT_FILE=""
GLUE_INPUT_FILES=""

SPLIT_OUT_DIR="."
SPLIT_INPUT_FILE=""

print_help() {
    echo "Usage: $0 [ -g | --glue <FILE> [ -p | --permanent ] [ --shebang <SHEBANG> ] <FILES> ] [ -s | --split <FILE> [ -o | --out <DIR> ] ] [ --overwrite ] [ -h | --help ]"
    echo -e "Craft new scripts. Glue script pieces together or split previously glued script."
    echo -e "\t-h,--help\tDisplay help."
    echo -e "\t--overwrite\tOverwrite files."
    echo -e "\t-g,--glue <FILE> Glue mode, copy contents of given files to <FILE>:"
    echo -e "\t\t-p,--permanent\t\tDo not put tags, files generated with this flag cannot be used for split mode."
    echo -e "\t\t--shebang <SHEBANG>\tShebang to use for generated files, default: '#!/bin/bash'"
    echo -e "\t\tExample: $0 -g output.sh -p -s \"#!/bin/sh\" -i input_first_part.sh input_second_part.sh"
    echo -e "\t-s,--split <FILE> Split mode, split <FILE> that has glue tags:"
    echo -e "\t\t-o,--out <DIR>\tGenerate files under <DIR>, default: '.'"
    echo -e "\t\tExample: $0 -s input.sh -o output_dir/"
}

# Validate mandatory arguments, conditions:
# - At least one mode should be given, 'glue' OR 'split'.
# - Both modes cannot be given at the same time.
# - If 'split' then one input file must be given.
# - If 'glue' then one output file name and at least one input file must be given.
validate_args() {
    local is_failed
    is_failed=""
    if [[ -z "${MODE_CURRENT}" ]]; then
        echo "Prove either --glue OR --split!"
        is_failed="YES"
    fi
    if [[ "${MODE_CURRENT}" != "${MODE_GLUE}" ]] && [[ "${MODE_CURRENT}" != "${MODE_SPLIT}" ]]; then
        echo "Modes --glue and --split cannot be used at the same time!"
        is_failed="YES"
    fi
    if [[ "${MODE_CURRENT}" == "${MODE_SPLIT}" ]] && [[ -z "${SPLIT_INPUT_FILE}" ]]; then
        echo "Missing arguments for --split!"
        is_failed="YES"
    fi
    if [[ "${MODE_CURRENT}" == "${MODE_GLUE}" ]] && [[ -z "${GLUE_OUT_FILE}"  ||  -z "${GLUE_INPUT_FILES}" ]]; then
        echo "Missing arguments for --glue!"
        is_failed="YES"
    fi
    if [[ -n "$is_failed" ]]; then
        exit 1
    fi
}

### Get params
# -l long options (--help)
# -o short options (-h)
# : options takes argument (--option1 arg1)
# $@ pass all command line parameters.
set -e
params=$(getopt -l "help,glue:,permanent,shebang:,split:,out:,overwrite" -o "hg:ps:o:" -- "$@")

eval set -- "$params"

### Run
while true
do
    case $1 in
        -h|--help)
            print_help
            exit 0
            ;;
        -g|--glue)
            shift
            GLUE_OUT_FILE="$1"
            MODE_CURRENT="${MODE_CURRENT}${MODE_GLUE}"
            ;;
        -p|--permanent)
            IS_PERMANENT="YES"
            ;;
        --shebang)
            shift
            SHEBANG="$1"
            ;;
        -s|--split)
            shift
            SPLIT_INPUT_FILE="$1"
            # Add mode next to existing one
            #   to detect if 'split' and 'glue' are provided at the same time.
            MODE_CURRENT="${MODE_CURRENT}${MODE_SPLIT}"
            ;;
        -o|--out)
            shift
            SPLIT_OUT_DIR="$1"
            ;;
        --overwrite)
            IS_OVERWRITE="YES"
            ;;
        --)
            shift
            break ;;
        *)
            print_help
            exit 0
            ;;
    esac
    shift
done
# Assuming that whatever left is list of files for 'glue'
# shellcheck disable=2124
GLUE_INPUT_FILES="$@"

validate_args

# If this file is executed as standalone then try to find needed files from script location.
if [[ $(type -t ${MODE_CURRENT}) != function ]]; then
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    COMMON_FILE="${SCRIPT_DIR}/common.sh"
    MODE_FILE="${SCRIPT_DIR}/${MODE_CURRENT}.sh"
    echo "Craft is able to craft itself!"
    echo "Sourcing: ${COMMON_FILE}"
    echo "Sourcing: ${MODE_FILE}"
    # shellcheck disable=1090
    if ! source "${COMMON_FILE}"; then
        echo "Could not be found: ${COMMON_FILE}"
        exit 1
    fi
    # shellcheck disable=1090
    if ! source "${MODE_FILE}"; then
        echo "Could not be found: ${MODE_FILE}"
        exit 1
    fi
fi

if [[ "${MODE_CURRENT}" == "${MODE_GLUE}" ]]; then
    ${MODE_GLUE} "${GLUE_OUT_FILE}" "${IS_OVERWRITE}" "${IS_PERMANENT}" "${SHEBANG}" "${GLUE_INPUT_FILES}"
elif [[ "${MODE_CURRENT}" == "${MODE_SPLIT}" ]]; then
    ${MODE_SPLIT} "${SPLIT_INPUT_FILE}" "${IS_OVERWRITE}" "${SPLIT_OUT_DIR}"
fi
