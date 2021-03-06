FROM ubuntu:14.04

MAINTAINER Nick Mote <nick@jetml.com>

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        dos2unix \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        nano \
        pkg-config \
        python \
        python-dev \
        python3 \
        python3-dev \
        python3-pip \
        rsync \
        software-properties-common \
        unzip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip --no-cache-dir install \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        scipy \
        seaborn \
        sklearn \
        pandas \
        pymysql \
        Pillow \
        && \
    python  -m pip install ipykernel
RUN pip3 install ipython
RUN pip3 install ipykernel

RUN mkdir /notebooks

# Copy TensorFlow CPU version from local repo
COPY src/tensorflow-0.12.1-cp27-none-linux_x86_64.whl /tensorflow-0.12.1-cp27-none-linux_x86_64.whl

# Install TensorFlow
RUN pip install /tensorflow-0.12.1-cp27-none-linux_x86_64.whl
 
# Set up our notebook config.
COPY config/jupyter_notebook_config.py /root/.jupyter/

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY config/run_jupyter.sh /

#Windows docker can add extra return spaces to sh files that create errors. dos2unix removes those
RUN dos2unix /run_jupyter.sh

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

WORKDIR "/"

RUN chmod +x /run_jupyter.sh

CMD ["/run_jupyter.sh"]