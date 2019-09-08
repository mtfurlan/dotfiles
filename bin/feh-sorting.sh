#!/bin/bash
# sudo apt-get install dmenu exifprobe exiv2 feh
# feh --scale-down --auto-zoom --action1 "feh-sorting.sh dir %F" --action2 "feh-sorting.sh rename %F" --info "feh-sorting.sh show %F"
# ~/.config/feh/keys
#    render n
#    next_img j Right space
#    prev_img k Left BackSpace
#
#    remove     d   Delete
#    delete   C-d C-Delete
#
#    toggle_actions   l
#    toggle_filenames f
#
#    action_1 m
#    action_2 r

if [ $# -lt 2 ]
then
    echo -e usage: "$0 <action> <filename>\n actions: edit-comment, edit-tags"
    exit -1
fi

action=$1
file=$2

if [ "$action" == "dir" ]; then
    TAG="$(find -type d -printf '%f\n' | dmenu -p "move file to dir")"
    if [ ! -e "$TAG" ]; then
        mkdir "$TAG"
    fi

    if [ -d "$TAG" ]; then
        mv "$file" "$TAG"
    else
        echo "$TAG is not a directory/tag" >/dev/stderr
        exit 1
    fi

fi
if [ "$action" == "rename" ]; then
    newFile="$(echo | dmenu -p "rename to what")"
    extension=$(echo "$file" | awk -F . '{print $NF}')
    dir=$(dirname "$file")
    mv "$file" "$dir/$newFile.$extension"

fi
if [ "$action" == "edit-comment" ]; then
    commentText=$(echo "$(exiv2 -Pt -g Exif.Photo.UserComment $file)" | dmenu)
    if [ $? -ne 1 ] # not aborted
    then
        if [ -z "$commentText" ]; then
            exiv2 -M"del Exif.Photo.UserComment" $file
        else
            exiv2 -M"set Exif.Photo.UserComment $commentText" $file
        fi
    fi
fi

if [ "$action" == "edit-tags" ]; then
    exiv2 -Pt -g Iptc.Application2.Keywords $file > /tmp/._image_keywords.txt

    selection=$(exiv2 -Pt -g Iptc.Application2.Keywords $file | dmenu -l 10)
    if [ -n "$selection" ]; then
        exiv2 -M "del Iptc.Application2.Keywords" $file
        while read keyword
        do
            if [ "$selection" != "$keyword" ]; then
                exiv2 -M "add Iptc.Application2.Keywords String $keyword" $file
            else
                deleted=true
            fi
        done < /tmp/._image_keywords.txt

        if [ -z $deleted ]; then
            exiv2 -M "add Iptc.Application2.Keywords String $selection" $file
        fi
    fi
    rm /tmp/._image_keywords.txt
fi

if [ "$action" == "show" ]; then
    comment=$(exiv2 -Pt -g Exif.Photo.UserComment $file)
    date=$(exiv2 -Pt -g Exif.Image.DateTime $file)
    exiv2 -Pt -g Iptc.Application2.Keywords $file > /tmp/._image_keywords.txt
    echo -n "$date = Comment: $comment, Keywords: "
    first=true
    while read keyword
    do
        if [ $first == "false" ]
        then
            echo -n ", "
        fi
        echo -n $keyword
        first="false"
    done < /tmp/._image_keywords.txt
    echo
    rm /tmp/._image_keywords.txt
fi
