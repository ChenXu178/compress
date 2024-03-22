export HISTTIMEFORMAT="%d/%m/%y %T "
alias ll='ls -alF'
alias ls='ls --color=auto'
umask ${UMASK}
MUID=`id docker | sed 's/uid=//g' | sed 's/(docker)//g' | sed 's/gid=//g' | sed 's/groups=//g'| sed 's/,/ /g' | sed 's/(users)/ /g' | awk '{print $(1)}'`
MGID=`id docker | sed 's/uid=//g' | sed 's/(docker)//g' | sed 's/gid=//g' | sed 's/groups=//g'| sed 's/,/ /g' | sed 's/(users)/ /g' | awk '{print $(2)}'`
if [ $MUID -ne ${PUID} ]; then
	usermod -u ${PUID} docker
fi
if [ $MGID -ne ${PGID} ]; then
	groupmod -g ${PGID} users
fi
su docker