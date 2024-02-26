
glue_mode() {
    local out_file
    local is_overwrite
    local is_permanent
    local shebang
    local input_files
    out_file="$1"
    is_overwrite="$2"
    is_permanent="$3"
    shebang="$4"
    input_files="$5"

    echo "Glue mode input files: '${input_files}'"
    echo "Glue mode output file: '${out_file}'"

    # If file exists then cannot continue without overwriting
    if [[ -f "${out_file}" && "${is_overwrite}" == "NO" ]]; then
        echo "File exists: ${out_file}"
        echo "Provide --overwrite to overwrite files."
        exit 1
    fi

    # 1. Create/Overwrite a file then write the shebang as the first line
    echo "${shebang}" > "${out_file}"

    # 2. Write input files to output file in given order
    for input_file in ${input_files}
    do
        # shellcheck disable=2155
        local basename_input_file=$(basename "${input_file}")
        # 2.1. If needed, before writing input file's content, write a begin tag and note the file name
        if [[ "${is_permanent}" == "NO" ]]; then
            echo "${TAG_BEGIN}${basename_input_file}" >> "${out_file}"
        fi

        # 2.2. Write input file content to output file
        cat "${input_file}" >> "${out_file}"

        # 2.1. If needed, after writing input file's content, write an end tag and note the file name
        if [[ "${is_permanent}" == "NO" ]]; then
            echo "${TAG_END}${basename_input_file}" >> "${out_file}"
        fi
    done
    echo "Glue is done!"
}
