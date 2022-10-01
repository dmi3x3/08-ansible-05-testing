FROM ubuntu:22.04
ENV MOLECULE_NO_LOG false

RUN apt update && apt -y upgrade && apt -y install tar gcc make python3-pip podman python3-openssl build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget curl

ADD https://www.python.org/ftp/python/3.7.10/Python-3.7.10.tgz Python-3.7.10.tgz
RUN tar xf Python-3.7.10.tgz && cd Python-3.7.10/ && ./configure --with-ssl-default-suites=openssl && ./configure --enable-optimizations && make && make altinstall
ADD https://www.python.org/ftp/python/3.9.2/Python-3.9.2.tgz Python-3.9.2.tgz
RUN tar xf Python-3.9.2.tgz && cd Python-3.9.2/ && ./configure --with-ssl-default-suites=openssl &&  ./configure --enable-optimizations && make && make altinstall
RUN python3 -m pip install --upgrade pip && pip3 install tox selinux
RUN rm -rf Python-*
RUN apt -y install docker containerd docker-compose
RUN curl https://bootstrap.pypa.io/get-pip.py | python3
RUN systemctl enable docker
RUN pip3 install "molecule==3.4.0" && pip3 install docker && pip3 install molecule-docker && pip3 install podman && pip3 install molecule-podman
RUN pip3 install "ansible-lint<6.0.0" && pip3 install flake8

RUN systemctl set-default multi-user.target

CMD [ "/lib/systemd/systemd", "log-level=info", "unit=sysinit.target" ]