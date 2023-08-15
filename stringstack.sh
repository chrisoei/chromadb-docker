# Set up the string stack if it isn't set already
[[ -v sS ]] || export sS=()

# Set up the OS variable if it isn't set already
[[ -v O31_OS ]] || export O31_OS="`/usr/bin/uname -o`"

# Push arguments onto the string stack. If no arguments, then push
# the clipboard onto the string stack.
pS () {
  local x
  if [ ${#@} -eq 0 ]
  then
    case "$O31_OS" in
      Cygwin)
        export sS=("`/usr/bin/cat /dev/clipboard`" "${sS[@]}")
        ;;
      FreeBSD)
        ;;
      GNU/Linux)
        export sS=("`/usr/bin/xclip -out -selection clipboard`" "${sS[@]}")
        ;;
      *)
        echo "Unknown operating system"
        ;;
    esac
  else
    for x in "$@"
    do
      export sS=("$x" "${sS[@]}")
    done
  fi
  if [[ -n "$O31_VERBOSE" ]]
  then
    declare -p sS
  fi
}

delsS () {
  if [ -z "$1" ]
  then
    /usr/bin/printf "Usage: delsS <n>\n"
  else
    /usr/bin/printf "Deleting sS[$1]\n"
    unset sS[$1]
    export sS=("${sS[@]}")
    declare -p sS
  fi
}

case "$O31_OS" in
  Cygwin)
    alias cS='/usr/bin/printf "${sS[0]}" > /dev/clipboard'
    ;;
  FreeBSD)
    ;;
  GNU/Linux)
    [ -e /usr/bin/xclip ] && alias cS='/usr/bin/printf "${sS[0]}" | /usr/bin/xclip -selection clipboard'
    ;;
  *)
    echo "Unknown operating system: $O31_OS"
    ;;
esac
[ -e /usr/bin/atril ] && alias atrilS='/usr/bin/atril "${sS[0]}"'
alias basenameS='pS "`basename \"${sS[0]}\"`"'
alias catS='/usr/bin/cat "${sS[0]}"'
alias cdS='cd "${sS[0]}"'
if [ -e /usr/bin/ci ]
then
  alias ciS='/usr/bin/ci -l "${sS[0]}"'
  alias ciCS='/usr/bin/ci -l -m"$COMMENTS1" "${sS[0]}"'
  alias ciSS='/usr/bin/ci -l -m"Snapshot on `stardate.pl`." "${sS[0]}"'
fi
alias fileS='/usr/bin/file "${sS[0]}"'
alias gC='git commit -m"$COMMENTS1"'
if [ -e /usr/bin/gpg2 ]
then
  alias gpgV='gpg2 --verify "${sS[0]}.asc"'
fi
alias gpz.s='git_pull.pl --zfs "${sS[0]}"'
alias lessS='/usr/bin/less "${sS[0]}"'
alias lslS='/usr/bin/ls -l "${sS[0]}"'
alias nvim.st='nvim "${sS[0]}.txt"'
alias rIS='rcs_init.pl "${sS[0]}"'
[ -e /usr/bin/rcsdiff ] && alias rDS='/usr/bin/rcsdiff "${sS[0]}"'
[ -e /usr/bin/ristretto ] && alias ristrettoS='/usr/bin/ristretto "${sS[0]}"'
[ -e /usr/bin/rlog ] && alias rLS='/usr/bin/rlog "${sS[0]}" | less'
alias shaS='sha256sum "${sS[0]}"'
alias sS='declare -p sS'
alias unspace.sS='pS `/usr/bin/printf "${sS[0]}" | /usr/bin/perl -pe "s/\&/_and_/g;s/[\!_\s]+/_/g;"`'
alias vim.st='vim "${sS[0]}.txt"'
alias vS='/usr/bin/vim "${sS[0]}"'
[ -e /usr/bin/vlc ] && alias vVS='/usr/bin/vlc --advanced --play-and-exit "${sS[0]}"'

# vim: set et ff=unix ft=sh nocp sts=2 sw=2 ts=2:
