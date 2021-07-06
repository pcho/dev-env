FROM ubuntu:hirsute

RUN set -xe && \
    apt-get update \
    && apt-get install -y gnupg

ENV DEBIAN_FRONTEND="noninteractive"

# Install deps
RUN set -xe && \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    apt-utils \
    build-essential \
    libgd-dev \
    libxslt-dev \
    libgeoip-dev \
    libssl-dev \
    ncurses-dev \
    libevent-dev \
    libpcre++-dev \
    zsh \
    git \
    cmake \
    ncdu \
    htop \
    wget \
    curl \
    whois \
    dialog \
    autogen \
    tzdata \
    man-db \
    bison \
    autoconf \
    libtool \
    locales \
    silversearcher-ag

# Sets Timezone to EU/Berlin
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure tzdata

# Sets locales to en_US.UTF-8
RUN set -xe &&\
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Unminimize
RUN yes | unminimize

# Install VIM from source
RUN set -xe \
    && git clone --depth=1 https://github.com/vim/vim.git /vim \
    && ( \
        cd /vim \
        && ./configure --with-features=huge --enable-multibyte --enable-python3interp=yes \
	    && make \
        && make install \
        && cd .. \
        && rm -rf /vim \
    )

# Install TMUX from source
RUN set -xe \
    && git clone --depth=1 https://github.com/tmux/tmux.git /tmux \
    && ( \
        cd /tmux \
        && sh autogen.sh \
        && ./configure \
	    && make \
        && make install \
        && cd .. \
        && rm -rf /tmux \
    )

# Install tmux-mem-cpu-load plugin for tmux
RUN set -xe \
    && git clone --depth=1 https://github.com/thewtex/tmux-mem-cpu-load /tmcl \
    && ( \
        cd /tmcl \
        && cmake . \
	    && make \
        && make install \
        && cd .. \
        && rm -rf /tmcl \
    )

# Add Node and Yarn to apt
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install node & yarn packages
RUN set -xe && \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    nodejs \
    yarn

# Change default shell to ZSH
RUN chsh -s /usr/bin/zsh

# Defaults
USER root:root
WORKDIR /root

# Run with ZSH
CMD ["/usr/bin/zsh"]
