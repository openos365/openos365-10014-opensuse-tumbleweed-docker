#
# (c) System csh.cshrc for tcsh, Werner Fink '93
#                           and Jörg Stadler '94
#
# This file sources /(usr/)etc/profile.d/complete.tcsh and
# /(usr/)etc/profile.d/bindkey.tcsh used especially by tcsh.
# For Midnight Commander (mc) also /etc/profile.d/mc.csh
# or /usr/share/mc/mc.csh is sourced.
#
# PLEASE DO NOT CHANGE /etc/csh.cshrc. There are chances that your changes
# will be lost during system upgrades. Instead use /etc/csh.cshrc.local for
# your local settings, favourite global aliases, VISUAL and EDITOR
# variables, etc ...
# USERS may write their own $HOME/.csh.expert to skip sourcing of
# /(usr/)etc/profile.d/complete.tcsh and most parts oft this file.
#

#
# Just in case the user excutes a command with ssh or sudo
#
if ((${?loginsh} || ${?SSH_CONNECTION} || ${?SUDO_COMMAND}) && ! ${?CSHRCREAD}) then
    set _SOURCED_FOR_SSH=true
    source /etc/csh.login >& /dev/null
    unset _SOURCED_FOR_SSH
endif
#
onintr -
set noglob
#
# Call common progams from /bin or /usr/bin only
#
alias path 'if ( -x /bin/\!^ ) /bin/\!*; if ( -x /usr/bin/\!^ ) /usr/bin/\!*'
if ( -x /bin/id ) then
    set id=/bin/id
else if ( -x /usr/bin/id ) then
    set id=/usr/bin/id
endif

#
# Default echo style
#
set echo_style=both

#
# In case if not known
#
if (! ${?UID}  ) set -r  UID=${uid}
if (! ${?EUID} ) set -r EUID="`${id} -u`"
unset id

#
# Avoid trouble with Emacs shell mode
#
if ($?EMACS) then
  setenv LS_OPTIONS '-N --color=none -T 0'
endif

#
# Only for interactive shells
#
if (! ${?prompt}) goto done

#
# Avoid trouble with Emacs shell mode
#
if ($?EMACS || $?MC_SID) then
  path tset -I -Q
  path stty cooked pass8 dec nl -echo
endif

#
# Let root watch its system
#
if ( "$uid" == "0" ) then
    set who=( "%n has %a %l from %M." )
    set watch=( any any )
endif

#
# This is an interactive session
#
# Now read in the key bindings of the tcsh
#
if ($?tcsh) then
    if ( -r /etc/profile.d/bindkey.tcsh ) then
	source /etc/profile.d/bindkey.tcsh
    else if ( -r /usr/etc/profile.d/bindkey.tcsh ) then
	source /usr/etc/profile.d/bindkey.tcsh
    endif
endif

#
# Some useful settings
#
set autocorrect=1
set listmaxrows=23
# set cdpath = ( /var/spool )
# set complete=enhance
# set correct=all
set correct=cmd
set fignore=(.o \~)
# set histdup=erase
set histdup=prev
set history=1000
set listjobs=long
set notify=1
set nostat=( /afs )
set rmstar=1
set savehist=( $history merge lock )
set showdots=1
set symlinks=ignore
#
unset autologout
unset ignoreeof

foreach _s (ls.tcsh alias.tcsh mc.csh)
    if (-r /etc/profile.d/$_s) then
	source /etc/profile.d/$_s
	continue
    endif
    if (-r /usr/etc/profile.d/$_s) source /usr/etc/profile.d/$_s
    if (-r /usr/share/mc/$_s) source /usr/share/mc/$_s
end
unset _s

#
# Prompting and Xterm title
#
set prompt="%B%m%b %C2%# "
if ( -o /dev/$tty && -c /dev/$tty ) then
  if ( ! -r $HOME/.csh.expert ) alias cwdcmd '(echo "Directory: $cwd" > /dev/$tty)'
  if ( -x /usr/bin/biff ) /usr/bin/biff y
  # If we're running under X11
  if ( ${?DISPLAY} ) then
    if ( ${?TERM} && ${?EMACS} == 0 && ${?MC_SID} == 0 && ${?STY} == 0 && ! -r $HOME/.csh.expert ) then
      if ( { tput hs >& /dev/null } || { ( tput -T $TERM+sl hs >& /dev/null ) } \
	  || $TERM =~ xterm* || $TERM =~ gnome* || $TERM =~ konsole* || $TERM =~ xfce* ) then
	if ( $TERM =~ xterm* || $TERM =~ gnome* || $TERM =~ konsole* || $TERM =~ xfce* ) then
	  # https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Miscellaneous
	  set _tsl=`echo -n '\033]2;'`
	  set _isl=`echo -n '\033]1;'`
	  set _fsl=`echo -n '\007'`
	else if ( { ( tput -T $TERM+sl tsl >& /dev/null ) } ) then
	  set _tsl=`tput -T $TERM+sl tsl`
	  set _isl=''
	  set _fsl=`tput -T $TERM+sl fsl`
	else
	  set _tsl=`tput tsl`
	  set _isl=''
	  set _fsl=`tput fsl`
	endif
	set _sc=`tput sc`
	set _rc=`tput rc`
	if ( ${%_tsl} > 0 && ${%_isl} > 0 && ${%_fsl} > 0 ) then
	  alias cwdcmd '(echo -n "'$_sc$_tsl'$USER on ${HOST}: $cwd'$_fsl$_isl'$HOST'$_fsl$_rc'">/dev/$tty)'
	else if (${%_tsl} > 0 && ${%_fsl} > 0 ) then
	  alias cwdcmd '(echo -n "'$_sc$_tsl'$USER on ${HOST}: $cwd'$_fsl$_rc'">/dev/$tty)'
	endif
      endif
      unset _isl _tsl _fsl _sc _rc
      cd .
    endif
    if ( -x /usr/bin/biff ) /usr/bin/biff n
    set prompt="%C2%# "
  endif
endif
#
# tcsh help system does search for uncompressed helps file
# within the cat directory system of a old manual page system.
# Therefore we use whatis as alias for this helpcommand
#
alias helpcommand whatis

#
# Expert mode: if we find $HOME/.csh.expert we skip our settings
# used for interactive completion and read in the expert file.
#
if (-r $HOME/.csh.expert) then
    unset noglob
    source $HOME/.csh.expert
    goto done
endif

#
# Source the completion extension of the tcsh
#
if ($?tcsh) then
    set _rev=${tcsh:r}
    set _rel=${_rev:e}
    set _rev=${_rev:r}
    if ($_rev > 6 || ($_rev == 6 && $_rel > 1)) then
	if (-r /etc/profile.d/complete.tcsh) then
	    source /etc/profile.d/complete.tcsh
	else if (-r /usr/etc/profile.d/complete.tcsh) then
	    source /usr/etc/profile.d/complete.tcsh
	endif
    endif
    #
    # Enable editing in multibyte encodings for the locales
    # where this make sense, but not for the new tcsh 6.14.
    #
    if ($_rev < 6 || ($_rev == 6 && $_rel < 14)) then
	switch ( `/usr/bin/locale charmap` )
	case UTF-8:
	    set dspmbyte=utf8
            breaksw
	case BIG5:
	    set dspmbyte=big5
            breaksw
	case EUC-JP:
	    set dspmbyte=euc
            breaksw
	case EUC-KR:
	    set dspmbyte=euc
            breaksw
	case GB2312:
	    set dspmbyte=euc
	    breaksw
	case SHIFT_JIS:
	    set dspmbyte=sjis
            breaksw
	default:
            breaksw
	endsw
    endif
    #
    unset _rev _rel
endif

#
# Set GPG_TTY for curses pinentry
# (see man gpg-agent and bnc#619295)
#
if ( -o /dev/$tty && -c /dev/$tty ) setenv GPG_TTY /dev/$tty

done:
onintr
unset noglob

#
# Local configuration
#
if ( -r /etc/csh.cshrc.local ) source /etc/csh.cshrc.local

#
# End of /etc/csh.cshrc
#
