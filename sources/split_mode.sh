
split_mode() {
    local input_file
    local is_overwrite
    local out_dir
    local tagged_files
    input_file="$1"
    is_overwrite="$2"
    out_dir="$3"

    if [[ ! -f "${input_file}" ]]; then
        echo "File does not exist: ${input_file}"
        exit 1
    fi
    if [[ ! -d "${out_dir}" ]]; then
        echo "Directory does not exist: ${out_dir}"
        exit 1
    fi

    echo "Split mode input file: '${input_file}'"
    echo "Split mode output directory: '${out_dir}'"

    # Get only file paths from begin tags
    tagged_files=$(sed -n "s/^${TAG_BEGIN}\(.*\)/\1/p" "${input_file}")
    for tagged_file in ${tagged_files}
    do
        # Tags should not have paths but just in case get the file name only
        # shellcheck disable=2155
        local tagged_file_path=$(basename "${tagged_file}")
        tagged_file_path="${out_dir}/${tagged_file_path}"
        echo "--Creating: ${tagged_file_path}"
        # If file exists and no overwrite then do not do anything and process the next file
        if [[ -f "${tagged_file_path}" && "${is_overwrite}" == "NO" ]]; then
            echo "File exists: ${tagged_file_path}"
            echo "Provide --overwrite to overwrite files."
            continue
        fi

        # Prepare tags for awk
        # Replace all: '/' -> '\/'
        tagged_file="${tagged_file//\//\\/}"
        # Replace all: '.' -> '\.'
        tagged_file="${tagged_file//./\\.}"

        # Take lines between tags from input file then write to output file
        awk "/${TAG_BEGIN}${tagged_file}/{is_to_print=1;next}/${TAG_END}${tagged_file}/{is_to_print=0}is_to_print" "${input_file}" > "${tagged_file_path}"
        echo "--Created."
    done

    echo "Split is done!"
}
