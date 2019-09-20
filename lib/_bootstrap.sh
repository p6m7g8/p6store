p6_p6store_bootstrap() {
  local dir="${1:-$P6_DFZ_SRC_P6M7G8_DIR/p6store}"

  local file
  for file in $(p6_dirs_list "$dir/lib"); do
    p6_file_load "$file"
  done
}
