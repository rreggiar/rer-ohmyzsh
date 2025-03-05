mdToDocx() {
# TODO FIXME hardcoded path to lua
path_to_filter=/Users/rreggiar/Documents/proposals/NIDDK_K00/zotero.lua
if command -v pandoc &> /dev/null
then
	pandoc -s \
		-o ${2} \
		-f markdown \
		-t docx \
		--lua-filter=$path_to_filter \
		${1}
else
	echo "pandoc not found"
	exit 1
fi
}

mdToNIH() {
# TODO FIXME hardcoded path to lua
path_to_filter=/Users/rreggiar/Documents/proposals/NIDDK_K00/zotero.lua
path_to_library=/Users/rreggiar/Documents/proposals/NIDDK_K00/NIH-proposal-template
if command -v pandoc &> /dev/null
then
  output=$(echo ${1} | sed 's/.md*$/.docx/g')
	pandoc -s \
		-o ${output} \
		-f markdown \
		-t docx \
		--reference-doc=$path_to_library/nih-reference.docx \
		--csl=$path_to_library/council-of-science-editors.csl \
		--lua-filter=$path_to_filter \
		${1}
else
	echo "pandoc not found"
	exit 1
fi
}

mkProjectDir() {
  projectDir=/Users/rreggiar/Documents/projects
  case ${1} in 
    "") echo "provide valid path"; 
      ;;
    *)
      mkdir ${projectDir}/${1} && cd ${projectDir}/${1}

      touch README.md \
        LICENSE.md \
        NOTES.md \
        TODO.md \
        .gitignore

      mkdir quarto \
        R \
        manuscript \
        figures 
        
      git init
      ;;
  esac
}

iterm(){
  PROFILE="${1-rer_mbp_term}"
  CMD="${2-echo "I, \$(whoami), am here at \$PWD"}"

  osascript -e "tell application \"iTerm\"
    set newWindow to (create window with profile \"$PROFILE\")
    tell current session of newWindow
      write text \"$CMD\"
    end tell
  end tell"
}

filePath(){
  FILE="$1"

  ls -d $PWD/$FILE
}

vim(){
  uv run nvim "$@"
}
