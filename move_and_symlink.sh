#!/bin/bash

mkdir_mod() {
    mod=$1
    dir=$2
    if [[ "$dir" == /* ]]; then
        current_path="/"
    else
        current_path=""
    fi
    IFS='/' read -ra DIR_COMPONENTS <<< "$dir"
    for component in "${DIR_COMPONENTS[@]}"; do
        if [ -n "$component" ]; then
            if [ "$current_path" == "/" ]; then
                current_path="/$component"
            else
                current_path="$current_path/$component"
            fi
            if [ ! -d "$current_path" ]; then
                mkdir "$current_path"
                chmod "$mod" "$current_path"
            fi
        fi
    done
}





move_folder() {
    userinput="$1"
    prefix="/share/CACHEDEV1_DATA/nas_home/"
    
    # Check if userinput starts with the prefix
    if [[ "$userinput" == "$prefix"* ]]; then
        # echo "Input starts with the prefix."
        true
    else
        echo "Input does not start with the prefix."
        exit 1
    fi
    
    # Remove the prefix from the userinput
    trimmed_input="${userinput#$prefix}"

    username=$(echo "$trimmed_input" | cut -d'/' -f1)
    dirname=$(basename "$trimmed_input")
    
    # Extracting relative_path if it's present
    if [[ "$trimmed_input" == */*/* ]]; then
        relative_path=/$(dirname "$trimmed_input")
        relative_path=/${relative_path#"/$username/"}
    else
        relative_path=""
    fi
    
    dirname_dst=$dirname
    
    
    target_path="/share/CACHEDEV1_DATA/nas_data/$username/moved_from_home$relative_path"
    target_path_full="/share/CACHEDEV1_DATA/nas_data/$username/moved_from_home$relative_path/$dirname_dst"

    # Check if target_path_full already exists
    if [ ! -d "$target_path_full" ]; then
        target_path_full=$target_path_full
    else
        count=1
        while [ -d "${target_path_full}_${count}" ]; do
            ((count++))
        done
        target_path_full="${target_path_full}_${count}"
        dirname_dst="${dirname_dst}_${count}"
    fi
    
    echo "##### Debug for $userinput #####"
    echo username=$username
    echo relative_path=$relative_path
    echo dirname=$dirname
    echo dirname_dst=$dirname_dst
    echo target_path=$target_path
    echo target_path_full=$target_path_full

    # Create the target directory
    echo mkdir_mod "0755" "$target_path"
    mkdir_mod "0755" "$target_path"

    # Move the folder
    echo mv "$userinput" "$target_path_full"
    mv "$userinput" "$target_path_full"
    
    # Create symbolic link
    echo ln -s "/data/nas05/$username/moved_from_home${relative_path}/$dirname_dst" "$userinput"
    ln -s "/data/nas05/$username/moved_from_home${relative_path}/$dirname_dst" "$userinput"
    echo "moved from $userinput" > "$target_path/$dirname_dst.txt"
    chmod 755 "$target_path/$dirname_dst.txt"
}

move_folder "/share/CACHEDEV1_DATA/nas_home/karos/espnet/egs"
