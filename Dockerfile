FROM debian:bookworm-slim

ARG TIMEZONE

ENV TZ=${TIMEZONE:-America/New_York}
ENV DEBIAN_FRONTEND='noninteractive'

ARG POSTGRES_VERSION
ARG SSH_PORT
ARG DOTNET_VERSION

# If the certs directory exists, copy the certs and utilize them.
ARG BUILD_CONTEXT_PATH
COPY ${BUILD_CONTEXT_PATH}bin/root-certs.sh /root/.local/bin/root-certs.sh
COPY ${BUILD_CONTEXT_PATH}cert[s]/* /tmp/certs/

# Install packages
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        coreutils \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        debconf-utils \
        curl \
        procps \
        vim \
        openssh-client \
        net-tools \
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
        dnsutils \
        g++ \
        python3-full \
        python3-dev \
        python3-pip \
        python3-venv \
        zip \
        nasm \
        yasm \
        libgdiplus \
        libc6-dev \
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
        memcached \
        libmemcached-tools \
        unzip && \
    bash /root/.local/bin/root-certs.sh /tmp/certs/ && \
    install -d /usr/share/postgresql-common/pgdg && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/apt.postgresql.org.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    GNUPGHOME=$(mktemp -d) && \
    GNUPGHOME="${GNUPGHOME}" gpg --no-default-keyring --keyring /usr/share/keyrings/clickhouse-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8919F6BD2B48D754 && \
    chmod +r /usr/share/keyrings/clickhouse-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main" | tee /etc/apt/sources.list.d/clickhouse.list && \
    curl https://packages.fluentbit.io/fluentbit.key | gpg --dearmor | tee /usr/share/keyrings/fluentbit-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/fluentbit-keyring.gpg] https://packages.fluentbit.io/debian/$(lsb_release -cs) $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/fluent-bit.list && \
    wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -P /tmp/ && \
    dpkg -i /tmp/packages-microsoft-prod.deb && \
    rm /tmp/packages-microsoft-prod.deb && \
    apt-get -y update && \
    apt-get install -y --no-install-recommends \
        powershell \
        fluent-bit \
        openssh-server \
        clickhouse-client \
        postgresql-client-${POSTGRES_VERSION:-15} && \
    ln -s /opt/fluent-bit/bin/fluent-bit /usr/local/bin/fluent-bit && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    touch /etc/ssh/sshd_config.d/fieldsets.conf && \
    echo "Port ${SSH_PORT:-1022}" >> /etc/ssh/sshd_config.d/fieldsets.conf

# These can take a while to install so we move the calls into a new layer in case of build failures
RUN /usr/bin/pwsh -NoLogo -NonInteractive -Command "& {Register-PackageSource -Name NuGet.org -Location https://www.nuget.org/api/v2 -ProviderName NuGet -Force}" && \
    /usr/bin/pwsh -NoLogo -NonInteractive -Command "& {Install-Package Npgsql -Source NuGet.org -Scope AllUsers -Force}" && \
    /usr/bin/pwsh -NoLogo -NonInteractive -Command "& {Install-Package ClickHouse.Client -Source NuGet.org -Scope AllUsers -Force}" && \
    /usr/bin/pwsh -NoLogo -NonInteractive -Command "& {Install-Package Microsoft.Extensions.Logging.Abstractions -RequiredVersion ${DOTNET_VERSION}.0.0 -Source NuGet.org -Scope AllUsers -Force}"

COPY ${BUILD_CONTEXT_PATH}ssh.conf /etc/ssh/ssh_config
COPY ${BUILD_CONTEXT_PATH}sshd.conf /etc/ssh/sshd_config

# Add main work dir to PATH
WORKDIR /usr/local/fieldsets
ENV PATH="/usr/local/fieldsets/bin:${PATH}"

EXPOSE ${SSH_PORT:-1022}

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/bin/bash"]
