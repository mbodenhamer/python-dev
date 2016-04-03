FROM debian:jessie
MAINTAINER Matt Bodenhamer <mbodenhamer@mbodenhamer.com>

# Install pyenv dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libbz2-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libssl-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    python-pip \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip install -U pip

# Install pyenv
ENV HOME /root
ENV PYENVPATH $HOME/.pyenv
ENV PATH $PYENVPATH/shims:$PYENVPATH/bin:$PATH
RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

# Setup docker app
RUN mkdir /setup
COPY .bashrc /root/.bashrc
COPY pyversions /usr/local/bin/pyversions
COPY docker-entrypoint.sh /docker-entrypoint.sh

VOLUME /app
WORKDIR /app
ENTRYPOINT ["/docker-entrypoint.sh"]

ONBUILD ARG reqs=requirements.txt
ONBUILD ARG devreqs=dev-requirements.txt
ONBUILD ARG pkgreqs=apt-requirements.txt
ONBUILD ARG versions=2.7.11,3.5.1

ONBUILD COPY $pkgreqs /setup/pkg-requirements.txt
ONBUILD COPY $reqs /setup/requirements.txt
ONBUILD COPY $devreqs /setup/dev-requirements.txt

ONBUILD RUN apt-get update && \
	cat /setup/pkg-requirements.txt | xargs apt-get install -y && \
	rm -rf /var/lib/apt/lists/*
ONBUILD RUN pip install --no-cache-dir -r /setup/dev-requirements.txt \
	        -r /setup/requirements.txt
ONBUILD RUN pyversions $versions