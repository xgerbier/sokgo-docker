#!/bin/bash

#	Copyright (C) 2024 X.Gerbier
#
#	This file is part of Sokgo Docker.
#
#	Sokgo is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	Sokgo is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with Sokgo.  If not, see <https://www.gnu.org/licenses/>.

cd `dirname $0`/..

function getPublicIPv4()
{
	ipQueries=( 							\
		'https://api.ipify.org/'			\
		'https://ip4.me/api'				\
		'https://ifconfig.co/ip'			\
		'https://api.my-ip.io/v2/ip.txt'	\
		'https://ifconfig.me/ip'			\
		'https://ipinfo.io/ip'				\
		'https://ipapi.co/ip'				\
	)

	for q in ${ipQueries[*]}; do
		ip=`wget -4 $q -q -t 3 -O - | grep -o -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' -m 1`
		if [[ -n $ip ]]; then
			echo Success: query public IP from $q resulted with $ip > /dev/stderr
			echo $ip
			return 0
		fi
	done
	echo Failed to retrieve public IP > /dev/stderr
	return 1
}

publicIP=`getPublicIPv4`

# config public host & tcp/udp ports
sed -e "s/@TCP_PORT@/$TCP_PORT/"			\
	-e "s/@UDP_PORT_MIN@/$UDP_PORT_MIN/"	\
	-e "s/@UDP_PORT_MAX@/$UDP_PORT_MAX/"	\
	-e "s/@PUBLIC_IP@/$publicIP/"			\
	etc/sokgo.config.in > $CONFIG

echo Config \($CONFIG\) :
cat $CONFIG

# top -b
sokgo --daemon
