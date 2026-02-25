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

  osascript -e "tell application \"com.googlecode.iterm2\"
    set newWindow to (create window with profile \"$PROFILE\")
    tell current session of newWindow
      write text \"$CMD\"
    end tell
  end tell"
}

# Open remote tmux session(s) in com.googlecode.iterm22 using separate windows.
# Usage:
#   iterm_remote_tmux [HOST_ALIAS] [PROFILE_NAME] [which] [CODING_SESSION] [MONITOR_SESSION]
# Defaults:
#   HOST_ALIAS=ramp-box
#   PROFILE_NAME="Remote Tmux"
#   which=both   # options: coding | monitor | both
#   CODING_SESSION=coding
#   MONITOR_SESSION=monitor
# Open the single "work" tmux session in iTerm2 using -CC.
# Usage:
#   iterm_remote_tmux_work [HOST_ALIAS] [PROFILE_NAME] [WORK_SESSION]
# Defaults:
#   HOST_ALIAS=ramp-box, PROFILE_NAME="ramp-box", WORK_SESSION=work
ramp() {
  local SESSION="${1:-}"
  local HOST_ALIAS="${2:-ramp-box}"
  local PROFILE_NAME="${3:-ramp-box}"

  if [[ -z "$SESSION" ]]; then
    echo "Active sessions on ${HOST_ALIAS}:"
    ssh "${HOST_ALIAS}" 'ramp-status'
    return
  fi

  local CMD="ssh -t ${HOST_ALIAS} tmux -CC new -A -s ${SESSION}"

  osascript \
    -e 'tell application id "com.googlecode.iterm2" to activate' \
    -e "tell application id \"com.googlecode.iterm2\" to create window with profile \"$PROFILE_NAME\" command \"$CMD\""
}

ramp-dep2() {
  local HOST_ALIAS="${1:-ramp-box}"
  local PROFILE_NAME="${2:-ramp-box}"
  local WORK_SESSION="${3:-work}"

  # Ensure your alias is loaded, then forward your agent and attach/create tmux session
  local WORK_CMD='ssh -t '"${HOST_ALIAS}"' tmux -CC new -A -s '"${WORK_SESSION}"

  osascript \
    -e 'tell application id "com.googlecode.iterm2" to activate' \
    -e "tell application id \"com.googlecode.iterm2\" to create window with profile \"$PROFILE_NAME\" command \"$WORK_CMD\""
}

ramp-dep() {
  local HOST_ALIAS="${1:-ramp-box}"
  local PROFILE_NAME="${2:-ramp-box}"
  local WHICH="${3:-both}"
  local CODING_SESSION="${4:-coding}"
  local MONITOR_SESSION="${5:-monitor}"
  local WORK_SESSION="${6:-work}"

  # Use new -A to attach or create if missing (more robust than attach -t)
  local CODING_CMD="ssh -t ${HOST_ALIAS} tmux -CC new -A -s ${CODING_SESSION}"
  local MONITOR_CMD="ssh -t ${HOST_ALIAS} tmux -CC new -A -s ${MONITOR_SESSION}"
  local WORK_CMD="ssh -t ${HOST_ALIAS} tmux -CC new -A -s ${WORK_SESSION}"

  case "$WHICH" in
    work)
      osascript \
        -e 'tell application id "com.googlecode.iterm2" to activate' \
        -e "tell application id \"com.googlecode.iterm2\" to create window with profile \"$PROFILE_NAME\" command \"$WORK_CMD\""
      ;;
    coding)
      osascript \
        -e 'tell application id "com.googlecode.iterm2" to activate' \
        -e "tell application id \"com.googlecode.iterm2\" to create window with profile \"$PROFILE_NAME\" command \"$CODING_CMD\""
      ;;
    monitor)
      osascript \
        -e 'tell application id "com.googlecode.iterm2" to activate' \
        -e "tell application id \"com.googlecode.iterm2\" to create window with profile \"$PROFILE_NAME\" command \"$MONITOR_CMD\""
      ;;
    both|*)
      osascript \
        -e 'tell application id "com.googlecode.iterm2" to activate' \
        -e "tell application id \"com.googlecode.iterm2\" to create window with profile \"$PROFILE_NAME\" command \"$CODING_CMD\"" \
        -e "tell application id \"com.googlecode.iterm2\" to create window with profile \"$PROFILE_NAME\" command \"$MONITOR_CMD\""
      ;;
  esac
}

filePath(){
  FILE="$1"

  ls -d $PWD/$FILE
}

vim(){
  uv run nvim "$@"
}

syncToRamp() {
 local recursive=0
 local src=""
 local dest=""

 # Parse arguments
 while [[ $# -gt 0 ]]; do
   case "$1" in
     -r)
        recursive=1
        shift
        ;;
      *)
        if [[ -z "$src" ]]; then
          src="$1"
        elif [[ -z "$dest" ]]; then
          dest="$1"
        else
          echo "Error: Too many arguments provided"
          echo "Usage: syncToRamp [-r] source destination"
          return 1
        fi
        shift
        ;;
    esac
  done

  # Check if source and destination are provided
  if [[ -z "$src" || -z "$dest" ]]; then
    echo "Error: Both source and destination must be specified"
    echo "Usage: syncToRamp [-r] source destination"
    return 1
  fi

  # Set rsync options based on recursive flag
  local opts="-aavv"
  if [[ ! $recursive -eq 0 ]]; then
    opts="-aavvr"
  fi

  # Execute rsync command
  echo "Syncing to ramp server..."
  #echo '$opts "$src" 10.10.237.212:"$dest"'
  rsync $opts "$src" 10.10.237.212:"$dest"
}



syncFromRamp() {
 local recursive=0
 local src=""
 local dest=""

 # Parse arguments
 while [[ $# -gt 0 ]]; do
   case "$1" in
     -r)
        recursive=1
        shift
        ;;
      *)
        if [[ -z "$src" ]]; then
          src="$1"
        elif [[ -z "$dest" ]]; then
          dest="$1"
        else
          echo "Error: Too many arguments provided"
          echo "Usage: syncFromRamp [-r] source destination"
          return 1
        fi
        shift
        ;;
    esac
  done

  # Check if source and destination are provided
  if [[ -z "$src" || -z "$dest" ]]; then
    echo "Error: Both source and destination must be specified"
    echo "Usage: syncFromRamp [-r] source destination"
    return 1
  fi

  # Set rsync options based on recursive flag
  local opts="-aavv"
  if [[ ! $recursive -eq 0 ]]; then
    opts="-aavvr"
  fi

  # Execute rsync command
  echo "Syncing to ramp server..."
  #echo '$opts "$src" 10.10.237.212:"$dest"'
  rsync $opts 10.10.237.212:"$src" "$dest"
}
