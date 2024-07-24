#!/bin/bash
# sudo apt-get install dmenu exifprobe exiv2 feh
# feh --scale-down --auto-zoom --recursive
#tmp_dir=$(mktemp -d)
tmp_dir="/tmp/feh" # keeping it static till cleanup exists
mkdir -p "$tmp_dir/feh"
# ~/.config/feh/keys
cat << EOF > "$tmp_dir/feh/keys"
render n
next_img j Right space
prev_img k Left BackSpace

remove     d   Delete
delete   C-d C-Delete

toggle_actions   l
toggle_filenames f

action_1 m
action_2 r
action_3 s
EOF

help () {
    # if arguments, print them
    [ $# == 0 ] || echo $*

    echo "Usage: $0 FILENAME..."
    echo "       $0 --from-feh ACTION FILENAME"
    echo "sort filenames"
    echo "  -h, --help                          display this help and exit"
    echo "  -s, --slideshow-dir=SLIDESHOW_DIR   use this dir for slideshow operations"
    echo "  --from-feh                          script is being called from feh, do ACTION on FILENAME"

    # if args, exit 1 else exit 0
    [ $# == 0 ] || exit 1
    exit 0
}

# getopt short options go together, long options have commas
TEMP=`getopt -o hs: --long help,from-feh,slideshow-dir: -n "$0" -- "$@"`
if [ $? != 0 ] ; then
    echo "Something wrong with getopt" >&2
    exit 1
fi
eval set -- "$TEMP"

fromFeh=false
slideshow_dir=""
while true ; do
    case "$1" in
        -h|--help) help; exit 0; shift ;;
        -s|--slideshow-dir) slideshow_dir=$2 ; shift 2 ;;
        --from-feh) fromFeh=true ; shift ;;
        --) shift ; break ;;
        *) echo "Internal error, unexpected argument '$1'!" ; exit 1 ;;
    esac
done



# if not called from feh, run feh and exit
if [ "$fromFeh" = false ]; then
    # pass XDG_CONFIG_HOME to a place that has the feh config for this script
    XDG_CONFIG_HOME="$tmp_dir" feh --scale-down --auto-zoom --action1 "$0 --from-feh dir %F" --action2 "$0 --from-feh rename %F" --action3 "$0 --slideshow-dir='$slideshow_dir' --from-feh add-slideshow %F" --info "$0 --from-feh info %F" "$@"
    exit $?
fi

#called from feh, parse action/filename
action=$1
file=$2

if [ "$action" == "add-slideshow" ]; then
    if [ -z "$slideshow_dir" ]; then
        echo "Can't move stuff to an unset directory" >/dev/stderr
        exit 1
    fi

    if [ -d "$slideshow_dir" ]; then
        # count is number of files in the dir
        #assuming all files are XX-filename.ext
        count=$(ls -1 "$slideshow_dir" | wc -l | xargs printf "%02d")
        base=$(basename "$file")
        cp "$file" "$slideshow_dir/$count-$base"
    else
        echo "slideshow dir '$slideshow_dir' is not a directory" >/dev/stderr
        exit 1
    fi

fi
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
    if [ $? -ne 1 ]; then # not aborted
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
        while read keyword; do
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

if [ "$action" == "info" ]; then
    comment=$(exiv2 -Pt -g Exif.Photo.UserComment $file)
    date=$(exiv2 -Pt -g Exif.Image.DateTime $file)
    exiv2 -Pt -g Iptc.Application2.Keywords $file > /tmp/._image_keywords.txt

    echo -e "help: toggle actions: l; toggle filenames: f; move: m; rename: r; s: add to slideshow\n"
    echo -n "$date = Comment: $comment, Keywords: "
    first=true
    while read keyword; do
        if [ $first == "false" ]; then
            echo -n ", "
        fi
        echo -n $keyword
        first="false"
    done < /tmp/._image_keywords.txt
    echo
    rm /tmp/._image_keywords.txt
fi
