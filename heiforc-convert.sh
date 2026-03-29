#! /bin/bash

# This script simplifies a bit converting the files from HEIF/HEIC format into another picture formats (JPG, PNG).

###############################################################################
# This script uses Yannek-JS Bash library; 
# it checks whether this library (bash-scripts-lib.sh) is present; 
# if not, the script is quitted.
# You can download it from https://github.com/Yannek-JS/bash-scripts-lib
###############################################################################
SCRIPT_PATH=$(dirname $(realpath $0))    # An absolute path leading to this script

if [ -f ${SCRIPT_PATH}/bash-scripts-lib.sh ]
then
    source ${SCRIPT_PATH}/bash-scripts-lib.sh
else
    echo -e "\n Failure ! 'bash-scripts-lib.sh' is missing. Download it from 'https://github.com/Yannek-JS/bash-scripts-lib' into directory where this script is located.\n"
    exit
fi
###############################################################################


function print_help() {
    echo -e "\n usage: heiforc-convert.sh [-i | --input-directory <path>] [-o | --output-directory <path>] [-f | --output-format <JPG|PNG>] [-q | --quality <0..100>] [-r | --recursive] [-k | --keep-directory-tree] [-h | --help]

    -i | --input-directory     : a directory where the HEIF/HEIC files are
                                 located. The script also processes hidden
                                 directories and files.
    -o | --output-directory    : a directory where the converted files will be
                                 put in
    -f | --output-format       : a format that the HEIF/HEIC file will be 
                                 converted to (JPG or PNG)
    -q | --quality             : convertion quality within a range 0..100; 
                                 0 => the worst, 100 => the best
    -r | --recursive           : tells the script to look for the HEIF/HEIC
                                 files in all subdirectories of 
                                 the --input-directory
    -k | --keep-directory-tree : the same as --recursive but mirrors the input
                                 directory tree in the --output-directory
    -h | --help                : shows this info. \n

    If some of the arguments below has not been specified, the script will run
    with the following defaults
        --input-directory  = current directory 
        --output directory = current directory
        --output-format    = JPG
        --quality          = 100 (the best)

    Usage example:
        ./heiforc-convert.sh -i ~/Pictures/to_convert \\
                             -o ~/Pictures/output \\
                             -f JPG \\
                             -q 100 \\
                             -k
    "
}


function set_default_env_vars() {
    export INPUT_DIRECTORY=$(pwd)
    export OUTPUT_DIRECTORY=$(pwd)
    export OUTPUT_FORMAT='JPG'
    export QUALITY=100
    export RECURSIVE=0
    export KEEP_DIRECTORY_TREE=0
}

function consume_arguments() {
    arg_count=$#
    item=1
    while [ $item -le $arg_count ]; do
        case "$1" in
            -i | --input-directory)
                shift 1
                item=$((item + 1))
                if ! [ -d "$1" ]; then
                    echo -e "\n The input directory $1 does not exist !\n"
                    exit
                fi
                export INPUT_DIRECTORY="$(echo -e -n $1 | sed 's/\/$//')"
                ;;
            -o | --output-directory)
                shift 1
                item=$((item + 1))
                if ! [ -d "$1" ]; then
                    echo -e "\n The output directory $1 does not exist !\n"
                    echo 'This directory will be created now...'
                    yes_or_not
                    mkdir --parent "$1"
                    if [ $? -gt 0 ]; then
                        echo -e "\nError - $1 directory could not be created !"
                        exit
                    else
                        echo -e "\nInfo - $1 directory has been created."
                    fi
                fi
                export OUTPUT_DIRECTORY="$(echo -e -n $1 | sed 's/\/$//')"
                ;;
            -f | --output-format)
                case "$1" in
                    JPG | jpg)
                        export OUTPUT_FORMAT='jpg'
                        ;;
                    PNG | png)
                        export OUTPUT_FORMAT='png'
                        ;;
                    *)
                        echo -e "\nUnrecognised output format: $1\n"
                        exit
                        ;;
                esac
                shift 1
                item=$((item + 1))
                ;;
            -q | --quality)
                shift 1
                item=$((item + 1))
                if ! $(echo $1 | grep --quiet --extended-regex '^[0-9]{1,2}$|^100$'); then
                    echo -e "\nUnrecognised --quality value: $1 . It should be from the range 0..100\n"
                    exit
                fi
                export QUALITY="$1"
                ;;
            -r | --recursive)
                export RECURSIVE=1
                ;;
            -k | --keep-directory-tree)
                export KEEP_DIRECTORY_TREE=1
                ;;

            -h | --help)
                print_help
                exit
                ;;
            *)
                echo -e '\nIncorrect syntax !\n'
                print_help
                exit
                ;;
        esac
        shift 1
        item=$((item + 1))
    done
}

function get_dirs() {
    if [ $RECURSIVE -ne 1 ] && [ $KEEP_DIRECTORY_TREE -ne 1 ]; then
        echo -e -n $INPUT_DIRECTORY | base64
        exit
    fi
    dirs=()
    find $INPUT_DIRECTORY -type d 2>/dev/null | while read line; do
        echo "$(echo $line | base64 --wrap=0) "
    done
}

###################################
### The actions start from here ###
###################################

set_default_env_vars

consume_arguments "$@"

input_dirs=("$(get_dirs)") # get an array of the directories to work through

for in_dir_b64 in ${input_dirs[@]}; do
    in_dir="$(echo -e -n $in_dir_b64 | base64 --decode)"
    out_path=$OUTPUT_DIRECTORY
    if [ $KEEP_DIRECTORY_TREE -eq 1 ]; then
        # gets the directory tree to mirror it at output
        out_dir=$(echo $in_dir \
                  | gawk --field-separator "$INPUT_DIRECTORY" '{print $NF}' \
                  | sed 's/^\///')
        # for the parent directory, out_dir will be empty string
        if [ "$out_dir" != '' ]; then out_path="$out_path/$out_dir"; fi 
    fi
    
    if [ $(find "$in_dir" -type f -maxdepth 1 -iname '*.heif' -or -iname '*.heic' 2>/dev/null | wc --lines) -gt 0 ]; then
        # process only directories that contain the HEIF files
        draw_line
        echo -e "\nInfo - processing the HEIF files in $in_dir ..."
    else
        continue
    fi
    find "$in_dir" -type f -maxdepth 1 -iname '*.heif' -or -iname '*.heic' 2>/dev/null \
    | while read full_in_path; do
        if ! [ -d "$out_path" ]; then
            mkdir --parent "$out_path"
            if [ $? -ne 0 ]; then
                echo -e "\nWarning - $out_path directory could not be created ! Skipping..."
                continue
            else
                echo -e "Info - $out_path directory has been created."
            fi
        fi
        # to build the output full path, get the filename without the extension
        filename=$(echo -e -n "$full_in_path" \
                    | gawk --field-separator "$in_dir" '{print $NF}' \
                    | sed 's/^\///' \
                    | sed -E 's/\.[hH]{1}[eE]{1}[iI]{1}([fF]|[cC]){1}$//')
        echo -e "\n$filename"
        heif-convert -q $QUALITY "$full_in_path" "$out_path/$filename.$OUTPUT_FORMAT"
    done
done
echo # make a one-row space quitting
