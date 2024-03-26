FROM ubuntu:22.04

# Build arguments
ARG userid=1000
ARG groupid=1000
ARG username=bettercampus

# Set the timezone and setup in the container
ARG DEFAULT_TZ=America/Bogota
ENV DEFAULT_TZ=$DEFAULT_TZ

# Install some basic packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update TZ=$DEFAULT_TZ -qq \
    apt-get update -y && \
    apt-get install -y \
    # Utilities
    apt-utils \
    curl \
    wget \
    vim \
    git \
    sudo \
    # Development tools
    libedit2 \
    libncurses-dev \
    apt-transport-https \
    ca-certificates \
    gnupg \
    libxml2-dev \
    # Clean up
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure the GnuPG environment
RUN mkdir ~/.gnupg && chmod 600 ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# Create a user and group with privileges
RUN groupadd -g $groupid $username \
    && useradd -m -s /bin/bash -u $userid -g $groupid $username \
    && mkdir -p /home/$username && chown -R $username:$groupid /etc/sudoers.d/$username
RUN echo "$username ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username

# Install miniconda with python 3.11 and add it to the PATH
RUN curl -fsSL https://repo.anaconda.com/miniconda/$( wget -O - https://repo.anaconda.com/miniconda/ 2>/dev/null | grep -o 'Miniconda3-py311_[^"]*-Linux-x86_64.sh' | head -n 1) > /tmp/miniconda.sh \
    && chmod +x /tmp/miniconda.sh \
    && /tmp/miniconda.sh -b -p /opt/conda
ENV PATH=/opt/conda/bin:$PATH
RUN conda init

# Update pip and install some basic packages
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install \
    pytest \
    pytest-cov

# Add to path the modular environment
RUN echo "export HOME=/home/$username" >> /home/$username/.bashrc
RUN echo "export MODULAR_HOME='$HOME/modular'" >> /home/$username/.bashrc
RUN echo "export PATH='$HOME/.modular/pkg/packages.modular.com_mojo/bin:$PATH'" >> /home/$username/.bashrc

# Change the user
USER $username
WORKDIR /home/$username/

# Container Start
EXPOSE 8080

COPY ./mojoenv ./mojoenv
COPY utils/start.sh ./start.sh
RUN chmod +x ./start.sh

CMD ["./start.sh"]
