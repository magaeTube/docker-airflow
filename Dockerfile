FROM apache/airflow:2.1.0-python3.8
MAINTAINER "magae.tube@gmail.com"

USER root
RUN cat /etc/issue
RUN apt-get update \
    && apt-get install -y procps openssh-server openssh-client sshpass ssh ansible

# replace sshd_config, ansible
RUN sed -ri 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && sed -ri '/\[defaults\]/a\host_key_checking = False\nforks = 50' /etc/ansible/ansible.cfg \
    && service ssh restart \
    && ln -snf /usr/share/zoneinfo/Asia/Seoul /etc/localtime \
    && echo Asia/Seoul > /etc/timezone

USER airflow
COPY ./requirements.txt /requirements.txt
RUN if [ -e "/requirements.txt" ]; then pip install --no-cache-dir -r /requirements.txt; fi