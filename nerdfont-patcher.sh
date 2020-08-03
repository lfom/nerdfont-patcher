#!/bin/bash

# Constants #
VERSION=""
VER="master"
SRCFOLDER="src/glyphs"
PATCHER="font-patcher"
GITURL="https://github.com/ryanoasis/nerd-fonts/blob/${VER}"
HACKFONT="src/glyphs/Hack-Regular.ttf"
EXTRAGLYPHS="src/glyphs/SomeExtraSymbols.otf"
LOGFILE="patcher.log"

DOWNLOADFILES=(
    src/glyphs/FontAwesome.otf
    src/glyphs/NerdFontsSymbols%201000%20EM%20Nerd%20Font%20Complete%20Blank.sfd
    src/glyphs/NerdFontsSymbols%202048%20EM%20Nerd%20Font%20Complete%20Blank.sfd
    src/glyphs/Pomicons.otf
    src/glyphs/PowerlineExtraSymbols.otf
    src/glyphs/PowerlineSymbols.otf
    src/glyphs/Symbols%20Template%201000%20em.ttf
    src/glyphs/Symbols%20Template%202048%20em.ttf
    src/glyphs/Symbols-1000-em%20Nerd%20Font%20Complete.ttf
    src/glyphs/Symbols-2048-em%20Nerd%20Font%20Complete.ttf
    src/glyphs/Unicode_IEC_symbol_font.otf
    src/glyphs/devicons.ttf
    src/glyphs/font-awesome-extension.ttf
    src/glyphs/font-logos.ttf
    src/glyphs/materialdesignicons-webfont.ttf
    src/glyphs/octicons.ttf
    src/glyphs/original-source.otf
    src/glyphs/weathericons-regular-webfont.ttf
    src/unpatched-fonts/Hack/Regular/Hack-Regular.ttf
)

SAVEFILES=(
    src/glyphs/FontAwesome.otf
    "src/glyphs/NerdFontsSymbols 1000 EM Nerd Font Complete Blank.sfd"
    "src/glyphs/NerdFontsSymbols 2048 EM Nerd Font Complete Blank.sfd"
    src/glyphs/Pomicons.otf
    src/glyphs/PowerlineExtraSymbols.otf
    src/glyphs/PowerlineSymbols.otf
    "src/glyphs/Symbols Template 1000 em.ttf"
    "src/glyphs/Symbols Template 2048 em.ttf"
    "src/glyphs/Symbols-1000-em Nerd Font Complete.ttf"
    "src/glyphs/Symbols-2048-em Nerd Font Complete.ttf"
    src/glyphs//Unicode_IEC_symbol_font.otf
    src/glyphs/devicons.ttf
    src/glyphs/font-awesome-extension.ttf
    src/glyphs/font-logos.ttf
    src/glyphs/materialdesignicons-webfont.ttf
    src/glyphs/octicons.ttf
    src/glyphs/original-source.otf
    src/glyphs/weathericons-regular-webfont.ttf
    src/glyphs/Hack-Regular.ttf
)

# Functions #
pf() {
    printf "${@}\n"
    [ -f "$LOGFILE" ] && printf "${@}\n" >> $LOGFILE || printf "Internal error: log file not found!\n"
}

get_url() {
    echo "${GITURL}/${1}?raw=true"
}

quit() {
    printf "Please check README or http://github.com/lfom/nerdfontepatcher for more info.\n"
    exit 1
}

check_bin() {
    [ ! -x "$(command -v "$1")" ] && pf "$1 cannot be executed!" && quit
    pf "'${1}' found, continuing…"
}

download_file() {
    if [ "$1" == "" ] || [ "$2" == "" ]; then pf "Internal error: missing argument for curl!" && quit; fi
    curl -L --silent $(get_url $1) --output "$2"
    res=$? && [ "$res" != "0" ] && pf "Download failed!" && quit
    #pf "File '$2' saved successfully"
}

download_patcher() {
    [ "$curlfound" == "0" ] && check_bin "curl" && curlfound=1
    pf "Downloading latest Nerd Fonts pacher script…"
    download_file $PATCHER $PATCHER
}

download_glyphs() {
    [ "$curlfound" == "0" ] && check_bin "curl" && curlfound=1
    pf "Downloading glyphs…"
    i=0
    for item in "${DOWNLOADFILES[@]}"
    do
        download_file $item "${SAVEFILES[$i]}"
        ((i++))
    done
}

generate_extra() {
    pf "Generating extra glyphs…"
    [ ! -f "$HACKFONT" ] && pf "Required Hack font missing!" && quit
    fontforge --quiet -lang=ff -script extract-extra-glyphs 2>/dev/null
}

save_font() {
    [ "$1" == "" ] && pf "Internal error: missing argument for cleanup!" && return 1
    filename="$1" && fontname="$2" && fontstyle="$3"
    [ -r "$filename" ] && fontforge cleanup-font --input "$filename" --output "$filename" \
            --name "${fontname}" --style "${fontstyle}" --version "$VERSION" &>> $LOGFILE || \
            pf "Error patching font: '${filename}' not found!"
    [ -f "$filename" ] && pf "Patched successful: $filename" || return 1
    return 0
}

patch_mono() {
    [ "$1" == "" ] && pf "Internal error: missing argument for patch mono!" && return
    name="$1" && ext="$2"
    fontforge -script font-patcher --careful -c --custom SomeExtraSymbols.otf -ext "$ext" \
            --quiet --no-progressbars --mono "$name" &>> $LOGFILE
}

patch() {
    [ "$1" == "" ] && pf "Internal error: missing argument for patch!" && return
    name="$1" && ext="$2"
    fontforge -script font-patcher --careful -c --custom SomeExtraSymbols.otf -ext "$ext" \
            --quiet --no-progressbars "$name" &>> $LOGFILE
}

patch_font() {
    [ "$1" == "" ] && pf "Internal error: patch_font requires an argument!" && return 1
    [ ! -r "$1" ] && pf "Error! Could not open supplied file: $1" && return 1
    fontfile="$1" && fname=$(basename "$fontfile") && fext="${fname##*.}"
    fext=${fext,,}
    [ "$fext" == "" ] && pf "Error! Could not find a valid file extension in: $1" && return 1
    OLDIFS=$IFS && IFS=$'\n'
    fontinfo=( # Get font info using 'fc-scan' provided by fontconfig package
        $(fc-scan --format "%{family}\n%{style}" "$fontfile")
    )
    IFS=$OLDIFS
    rcode=0

    [ "${fontinfo[0]}" == "" ] && pf "Skipping file(${fext}): $fontfile" && return 1
    pf "Patching ${fontinfo[0]} ${fontinfo[1]} from file(${fext}): $fontfile"
    inputfile="${fontinfo[0]} ${fontinfo[1]}-NF.$fext"
    inputfile="${inputfile// /}"
    fontforge --quiet prepare-font --input "$fontfile" --output "$inputfile" &>> $LOGFILE

    outputfile="${fontinfo[0]} ${fontinfo[1]} Nerd Font Complete Mono.$fext"
    patch_mono "$inputfile" "$fext"
    save_font "$outputfile" "${fontinfo[0]}" "${fontinfo[1]}"
    rcode=$?

    outputfile="${fontinfo[0]} ${fontinfo[1]} Nerd Font Complete.$fext"
    patch "$inputfile" "$fext"
    save_font "$outputfile" "${fontinfo[0]}" "${fontinfo[1]}"
    [ "$rcode" != "1" ] && rcode=$?

    [ -r "$inputfile" ] && rm "$inputfile" || \
            pf "Internal errors:'${inputfile}' not found during cleanup!"
    return $rcode
}

start_patcher() {
    printf "Nerd Font patcher started, log will be saved to '${LOGFILE}'.\n"
    printf "Nerd Font pacher log - $(date)\n" > $LOGFILE
}

# Start #
start_patcher && fdir="$@" && curlfound=0

# Check for a folder with fonts to be patched
[ "$fdir" == "" ] && pf "Please specify a folder with fonts to be patched." && quit
[ ! -d "$fdir" ] && pf "Folder '${fdir}' not found!" && quit

# Check if fontconfig (fc-scan) is installed
check_bin "fc-scan"

# Check if Fontforge is installed and can be run
check_bin "fontforge"

# Download Nerd Font patcher
[ ! -r "$PATCHER" ] && download_patcher
[ ! -r "$PATCHER" ] && pf "'${PATCHER}' not found!" && quit

# Download glyphs
[ ! -d "$SRCFOLDER" ] && mkdir -p $SRCFOLDER && download_glyphs
[ ! -d "$SRCFOLDER" ] && pf "Cannot find 'src' folder with glyphs!" && quit

# Creating special font with selected glyphs
[ ! -r "$EXTRAGLYPHS" ] && generate_extra
[ ! -r "$EXTRAGLYPHS" ] && pf "Extra glyphs font not found!" && quit

# Patch fonts files found in folder
i=0
for ffile in "$fdir"/*
do
    patch_font "$ffile"
    res=$? && [ "$res" == "0" ] && ((i++))
done

[ "$i" == 0 ] && pf "No fonts patched." || pf "\n${i} fonts patched, enjoy!"
