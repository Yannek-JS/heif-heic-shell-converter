# heiforc-convert.sh
A Bash script that simplifies converting HEIF/HEIC images into JPG/PNG format.

The script can work recursively through the subdirectories and mirror the directory tree at the output.

```Bash
./heiforc-convert.sh --help

usage: heiforc-convert.sh [-i | --input-directory <path>] [-o | --output-directory <path>] [-f | --output-format <JPG|PNG>] [-q | --quality <0..100>] [-r | --recursive] [-k | --keep-directory-tree] [-h | --help]

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
    -h | --help                : shows this info. 


    If some of the arguments below has not been specified, the script will run
    with the following defaults
        --input-directory  = current directory 
        --output directory = current directory
        --output-format    = JPG
        --quality          = 100 (the best)

    Usage example:
        ./heiforc-convert.sh -i ~/Pictures/to_convert \
                             -o ~/Pictures/output \
                             -f JPG \
                             -q 100 \
                             -k
```
---
# Requirements

The script should run on most of the modern Linux distros with Bash and the following tools installed
* GNU grep
* GNU sed
* GNU awk
* **heif-convert** 

---
# Testing

Environment used for testing the script:

* Linux 4.18.0-553.109.1.el8_10.x86_64 #1 SMP, PRETTY_NAME="Rocky Linux 8.10 (Green Obsidian)"
* GNU bash, version 4.4.20(1)-release (x86_64-redhat-linux-gnu)
* grep (GNU grep) 3.1
* sed (GNU sed) 4.5
* GNU Awk 4.2.1, API: 2.0 (GNU MPFR 3.1.6-p2, GNU MP 6.1.2)
* heif-convert from libheif-1.7.0