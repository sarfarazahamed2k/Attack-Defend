FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y \
    software-properties-common

RUN apt-get install -y \
    systemd \
    wget \
    tar \
    python3 \
    python3-pip \
    python3-virtualenv

ENV VIRTUAL_ENV=/workspace/.venv
RUN virtualenv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip3 install ansible

WORKDIR /opt/rita

COPY run.sh .

RUN chmod +x run.sh

RUN wget https://github.com/activecm/rita/releases/download/v5.0.8/rita-v5.0.8.tar.gz \
    && tar -xf rita-v5.0.8.tar.gz \
    && rm rita-v5.0.8.tar.gz

CMD ["/lib/systemd/systemd"]

# docker exec -it <id> /bin/bash
# ./rita-v5.0.8-installer/install_rita.sh localhost

# Exiting the systemd -
# 1. Ctrl+P + Ctrl+Q
# 2. docker stop <id>

