{% if deepstream %}FROM nvcr.io/nvidia/deepstream:6.0-triton{% elif gpu %}FROM nvidia/cuda:11.3.1-cudnn8-runtime-ubuntu20.04{% else %}FROM python:3.9{% endif %}

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" && echo $SNIPPET >> "/root/.bashrc"{% if gpu or deepstream %}

RUN apt-key adv --fetch-keys https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub{% endif %}

RUN apt update -y
RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata
RUN apt install -y \
    build-essential \
    curl \
    git{% if deepstream %}

RUN apt install -y \
    python3-gi python3-dev python3-gst-1.0 python-gi-dev git python-dev \
    python3 python3-pip python3.8-dev python3.8-venv cmake g++ build-essential \
    libglib2.0-dev libglib2.0-dev-bin python-gi-dev libtool m4 autoconf automake \
    openssh-client

RUN git config --global http.sslverify false

WORKDIR /opt/nvidia/deepstream/deepstream
RUN git clone https://github.com/NVIDIA-AI-IOT/deepstream_python_apps.git
RUN cd deepstream_python_apps && \
    git checkout 0148b5afc4e1c3f1c640cb06cac6e2bc050cacff && \
    git submodule update --init && \
    cd 3rdparty/gst-python && \
    ./autogen.sh && \
    make && \
    make install
RUN cd deepstream_python_apps/bindings && \
    mkdir build && \
    cd build && \
    cmake .. -DPYTHON_MAJOR_VERSION=3 -DPYTHON_MINOR_VERSION=8 && \
    make && \
    pip3 install pyds-*.whl

RUN rm /usr/bin/python /usr/local/bin/pip
RUN ln -s /usr/bin/python3.8 /usr/local/bin/python
RUN ln -s /usr/local/bin/pip3.8 /usr/local/bin/pip{% elif gpu %}

# GPU Setup
RUN apt-get install -y \
    libcairo2-dev \
    libgl1-mesa-glx \
    software-properties-common

# Install Python 3.9
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt install -y python3.9-dev python3.9-venv
RUN python3.9 -m ensurepip
RUN ln -s /usr/bin/python3.9 /usr/local/bin/python
RUN ln -s /usr/local/bin/pip3.9 /usr/local/bin/pip
RUN pip install --upgrade pip{% endif %}

# Allow root for Jupyter notebooks
RUN mkdir /root/.jupyter
RUN echo "c.NotebookApp.allow_root = True" > /root/.jupyter/jupyter_notebook_config.py{% if gpu %}

ENV PIP_EXTRA_INDEX_URL https://download.pytorch.org/whl/cu113{% endif %}

CMD mkdir -p /code
WORKDIR /code
RUN mkdir {{ source_directory }} && \
  touch {{ source_directory }}/__init__.py
COPY setup.cfg .
COPY setup.py .
RUN pip install -e .
ADD . .

ENTRYPOINT [ "make" ]
