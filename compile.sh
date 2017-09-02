#!/bin/bash
set -u
tmpdir=$(mktemp -d )
containername="smenu"
imagename="smenu"

cat >${tmpdir}/Dockerfile  <<"EOF"

FROM debian:9

ENV SMENUVERSION "v0.9.9"


RUN apt-get update && \
        apt-get -y install wget git build-essential libncurses5-dev 
RUN groupadd --gid 1000 user && \
        useradd --uid 1000 --gid 1000 --create-home user
USER user
RUN cd && \
    FILE=${SMENUVERSION}.tar.gz && \
    URL="https://github.com/p-gen/smenu/archive/$FILE" && \
    wget $URL && \
    mkdir smenu && \
    tar zxvf "$FILE" -C smenu --strip-components=1 && \
    cd smenu && \
    ./build.sh && \
    ls -al smenu  smenu.1
CMD /bin/sleep 99999
EOF

docker build -t $imagename $tmpdir

docker run -d  --rm --name $containername $imagename

docker cp smenu:/home/user/smenu/smenu  smenu
docker cp smenu:/home/user/smenu/smenu.1  smenu.1

docker stop smenu

echo "Install with"
echo " /usr/bin/install -c smenu /usr/local/bin"
echo " mkdir -p /usr/local/share/man/man1"
echo " /usr/bin/install -c -m 644 smenu.1 /usr/local/share/man/man1"
