FROM maven:alpine

# 改动自  https://github.com/idoop/docker-apollo

MAINTAINER foxwho <foxiswho@gmail.com>

ENV VERSION=1.1.0 \
    PORTAL_PORT=8070 \
    ADMIN_DEV_PORT=8090 \
    ADMIN_FAT_PORT=8091 \
    ADMIN_UAT_PORT=8092 \
    ADMIN_PRO_PORT=8093 \
    CONFIG_DEV_PORT=8080 \
    CONFIG_FAT_PORT=8081 \
    CONFIG_UAT_PORT=8082 \
    CONFIG_PRO_PORT=8083

ARG APOLLO_URL=https://github.com/ctripcorp/apollo/archive/v${VERSION}.tar.gz


COPY docker-entrypoint /usr/local/bin/docker-entrypoint

RUN cd / && \
    wget https://github.com/ctripcorp/apollo/releases/download/v${VERSION}/apollo-portal-${VERSION}-github.zip -O apollo-portal-${VERSION}-github.zip && \
    wget https://github.com/ctripcorp/apollo/releases/download/v${VERSION}/apollo-configservice-${VERSION}-github.zip -O apollo-configservice-${VERSION}-github.zip && \
    wget https://github.com/ctripcorp/apollo/releases/download/v${VERSION}/apollo-adminservice-${VERSION}-github.zip -O apollo-adminservice-${VERSION}-github.zip
# 如果使用 上面的远程下载，下面的需要注释掉。
#ADD apollo-portal-${VERSION}-github.zip /
#ADD apollo-adminservice-${VERSION}-github.zip /
#ADD apollo-configservice-${VERSION}-github.zip /


RUN cd / && \
    mkdir /apollo-admin/dev /apollo-admin/fat /apollo-admin/uat /apollo-admin/pro -p && \
    mkdir /apollo-config/dev /apollo-config/fat /apollo-config/uat /apollo-config/pro -p && \
    mkdir /apollo-portal -p && \
    unzip -o /apollo-adminservice-${VERSION}-github.zip -d /apollo-admin/dev && \
    unzip -o /apollo-configservice-${VERSION}-github.zip -d /apollo-config/dev && \
    unzip -o /apollo-portal-${VERSION}-github.zip -d /apollo-portal && \
    sed -e "s/db_password=/db_password=root/g"  \
            -e "s/^local\.meta.*/local.meta=http:\/\/localhost:${PORTAL_PORT}/" \
            -e "s/^dev\.meta.*/dev.meta=http:\/\/localhost:${CONFIG_DEV_PORT}/" \
            -e "s/^fat\.meta.*/fat.meta=http:\/\/localhost:${CONFIG_FAT_PORT}/" \
            -e "s/^uat\.meta.*/uat.meta=http:\/\/localhost:${CONFIG_UAT_PORT}/" \
            -e "s/^pro\.meta.*/pro.meta=http:\/\/localhost:${CONFIG_PRO_PORT}/" -i /apollo-portal/config/apollo-env.properties && \
    cp -rf /apollo-admin/dev/* /apollo-admin/fat/  && \
    cp -rf /apollo-admin/dev/* /apollo-admin/uat/  && \
    cp -rf /apollo-admin/dev/* /apollo-admin/pro/  && \
    cp -rf /apollo-config/dev/* /apollo-config/fat/  && \
    cp -rf /apollo-config/dev/* /apollo-config/uat/  && \
    cp -rf /apollo-config/dev/* /apollo-config/pro/ && \
    #rm -rf *zip && \
    chmod +x  /usr/local/bin/docker-entrypoint

EXPOSE 8070 8080 8081 8082 8083 8090 8091 8092 8093
# EXPOSE 80-60000

ENTRYPOINT ["docker-entrypoint"]
