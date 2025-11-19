#!/bin/bash
set -e

TEMPLATE_DIR="templates"

# all the subfolders of templates
find "$TEMPLATE_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
    echo "Create symlinks on $dir"
    # create symbolic links
    #ln -sf ../../iso "$dir/iso"
    #ln -sf ../../scripts "$dir/scripts"
    #find "$dir" -type l -exec rm -f {} \;
    ln -sf ../../main.pkr.hcl "$dir/main.pkr.hcl"
    ln -sf ../../variables.auto.pkrvars.hcl "$dir/variables.auto.pkrvars.hcl"
done

echo "All symbolic links has been created."
