FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update --allow-insecure-repositories

RUN apt-get install -y \
    software-properties-common \
    curl \
    wget \
    systemd \
    python3 \
    python3-pip \
    python3-virtualenv \
    jq --allow-unauthenticated
RUN rm -rf /var/lib/apt/lists/*

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

ENV VIRTUAL_ENV=/workspace/.venv
RUN virtualenv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt-get update --allow-insecure-repositories
RUN apt-get install -y terraform --allow-unauthenticated
RUN rm -rf /var/lib/apt/lists/*

RUN pip3 install ansible pywinrm requests-credssp pandas openpyxl

RUN az --version \
    && terraform --version \
    && ansible --version

RUN ansible-galaxy collection install azure.azcollection

WORKDIR /workspace

COPY . /workspace

RUN chmod +x /workspace/*.sh

CMD ["/bin/bash"]
