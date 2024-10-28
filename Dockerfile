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

FROM ubuntu:latest

RUN apt-get update
RUN apt-get -y install git build-essential automake pkgconf dotnet-sdk-8.0 wget

ENV USER=ubuntu:ubuntu
ENV CONFIG=/usr/local/etc/sokgo.config
ENV TCP_PORT=1080
ENV UDP_PORT_MIN=50000
ENV UDP_PORT_MAX=50399

WORKDIR /home/ubuntu
COPY --chown=$USER --chmod=0755 bin/ bin/
ADD --chown=$USER --keep-git-dir=true https://github.com/xgerbier/sokgo.git sokgo/
COPY --chown=$USER etc/ etc/

USER $USER
RUN bin/sokgo-config.sh

USER root
RUN bin/sokgo-install.sh

EXPOSE ${TCP_PORT}/tcp
EXPOSE ${UDP_PORT_MIN}-${UDP_PORT_MAX}/udp
ENTRYPOINT [ "bin/sokgo-run.sh" ]
