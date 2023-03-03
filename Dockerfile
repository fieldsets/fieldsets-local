FROM debian:bullseye-slim

ARG TIMEZONE

ENV TZ=${TIMEZONE:-America/New_York}
ENV DEBIAN_FRONTEND='noninteractive'

ARG POSTGRES_VERSION

# Install packages
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        debconf-utils \
        curl \
        procps \
        vim \
        autossh \
        openssh-client \
        jq \
        wget \
        gnupg \
        build-essential \
        lsb-release \
        git \
        cmake \
        libpoco-dev \
        libssl-dev \
        libicu-dev \
        openssl \
        gcc \
        libc-dev \
        g++ \
        python3 \
        python3-dev \
        python3-pip \
        zip \
        nasm \
        yasm \
        libisal2 \
        libisal-dev \
        libdeflate0 \
        libdeflate-dev \
        libdeflate-tools \
        autoconf \
        automake \
        groff \
        libpq5 \
        libpq-dev \
        unzip && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null && \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754 && \
    echo "deb https://packages.clickhouse.com/deb stable main" | tee /etc/apt/sources.list.d/clickhouse.list && \
    curl https://packages.fluentbit.io/fluentbit.key | gpg --dearmor | tee /usr/share/keyrings/fluentbit-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/fluentbit-keyring.gpg] https://packages.fluentbit.io/debian/$(lsb_release -cs) $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/fluent-bit.list && \
    update-ca-certificates && \
    apt-get -y update && \
    apt-get install -y --no-install-recommends \
        fluent-bit \
        clickhouse-client \
        postgresql-client-${POSTGRES_VERSION:-15} && \
    ln -s /opt/fluent-bit/bin/fluent-bit /usr/local/bin/fluent-bit && \
    apt-get clean

# Add main work dir to PATH
WORKDIR /fieldsets
ENV PATH="/fieldsets:${PATH}"

# Clickhouse interserver port
EXPOSE 9000
EXPOSE 9009

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]