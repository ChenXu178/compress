FROM alpine:3.19.1

LABEL maintainer="chenxu.mail@icloud.com"

ENV TZ="Asia/Shanghai"
ENV PGID=100
ENV PUID=99
ENV UMASK=022

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update
RUN apk add --no-cache --update tzdata bash bash-completion shadow runuser pngquant jpegoptim libwebp libwebp-tools libavif libavif-apps parallel util-linux coreutils imagemagick imagemagick-static findutils imagemagick-heic imagemagick-jpeg imagemagick-webp file

RUN sed -i 's/ash/bash/g' /etc/passwd
RUN echo "${TZ}" > /etc/timezone

RUN groupmod -g ${PGID} users
RUN useradd -u ${PUID} -g users -d /app -s /bin/bash docker

VOLUME /app/data
WORKDIR /app/data

RUN mkdir -p /app/.parallel
RUN touch /app/.parallel/will-cite

COPY img_compress.sh /bin/icompress.sh
COPY compress.sh /bin/compress.sh
COPY img_convert.sh /bin/iconvert.sh
COPY convert.sh /bin/convert.sh
COPY size_sort.sh /bin/size_sort.sh
COPY root.bashrc /root/.bashrc
COPY docker.bashrc /app/.bashrc

RUN chown -R docker:users /app/.parallel
RUN chown docker:users /app/.bashrc
RUN chmod a+x /bin/icompress.sh
RUN chmod a+x /bin/compress.sh
RUN chmod a+x /bin/iconvert.sh
RUN chmod a+x /bin/convert.sh
RUN chmod a+x /bin/size_sort.sh

ENTRYPOINT ["tail", "-f", "/dev/null"]