FROM alpine:3.19.1

LABEL maintainer="chenxu.mail@icloud.com"

ENV TZ="Asia/Shanghai"
ENV PGID=100
ENV PUID=99
ENV UMASK=022

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update
RUN apk add --no-cache --update tzdata bash bash-completion shadow runuser pngquant jpegoptim libwebp libwebp-tools libavif libavif-apps parallel util-linux coreutils imagemagick findutils imagemagick-heic imagemagick-jpeg imagemagick-webp file

RUN mkdir -p ~/.parallel
RUN touch ~/.parallel/will-cite
RUN sed -i 's/ash/bash/g' /etc/passwd
RUN echo "${TZ}" > /etc/timezone

RUN groupmod -g ${PGID} users
RUN useradd -u ${PUID} -g users -d /app -s /bin/bash docker

VOLUME /app/data
WORKDIR /app/data

COPY img_compress.sh /bin/img_compress.sh
COPY compress.sh /bin/compress.sh
COPY img_convert.sh /bin/img_convert.sh
COPY convert.sh /bin/convert.sh
COPY size_sort.sh /bin/size_sort.sh
COPY root.bashrc /root/.bashrc
COPY docker.bashrc /app/.bashrc

RUN chmod a+x /bin/img_compress.sh
RUN chmod a+x /bin/compress.sh
RUN chmod a+x /bin/img_convert.sh
RUN chmod a+x /bin/convert.sh
RUN chmod a+x /bin/size_sort.sh

ENTRYPOINT ["tail", "-f", "/dev/null"]