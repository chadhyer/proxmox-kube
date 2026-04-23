FROM debian:trixie-slim

# User
RUN groupadd -g 1000 -r app && \
    useradd -u 1000 -g app -m -d /usr/local/app app && \
    echo "alias ls='ls --color'" >> /usr/local/app/.bashrc && \
    echo "alias ll='ls --color -alF'" >> /usr/local/app/.bashrc && \
    echo 'PS1="\n\[\e[00;31m\]\u\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e[01;36m\]\
\h\[\e \[\e[00;37m\] \t \[\e[0m\]\[\e[01;35m\]\w\[\e[0m\]\[\e[01;37m\] \
\[\e[0m\]\n$ "' >> /usr/local/app//.bashrc

# Update and install Ansible/Terraform
RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install \
        python3 python3-pip gnupg wget ansible && \
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
        tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com trixie main" > \
        /etc/apt/sources.list.d/hashicorp.list && \
    apt-get -y update && \
    apt-get -y install terraform

WORKDIR /usr/local/app

RUN mkdir -p /usr/local/app/ansible/inventory/group_vars && \
    mkdir -p /usr/local/app/ansible/playbook/roles && \
    mkdir -p /usr/local/app/ansible/templates && \
    mkdir -p /usr/local/app/ansible/cache && \
    mkdir -p /usr/local/app/.ssh/ && \
    mkdir -p /usr/local/app/.secret && \
    chown -R app:app /usr/local/app && \
    chown -R app:app /usr/local/.*

# COPY --chown=app:app ../ansible/ansible.cfg /usr/local/app/ansible/ansible.xfg
COPY --chown=app:app ./entrypoint.sh /usr/local/app/entrypoint.sh

RUN chmod +x /usr/local/app/*.sh

USER app

ENTRYPOINT [ "/usr/local/app/entrypoint.sh" ]
