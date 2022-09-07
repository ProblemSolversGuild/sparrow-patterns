FROM python:3.9

ENV USER_ID=1000

RUN useradd -m -d "/home/${USER_ID}" "${USER_ID}"

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" && echo $SNIPPET >> "/home/${USER_ID}/.bashrc"

ENV LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  PATH="${PATH}:/root/.poetry/bin"

RUN apt update -y
RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata
RUN apt install -y \
    build-essential \
    curl \
    git

# Install Poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | POETRY_HOME=/opt/poetry python && \
    cd /usr/local/bin && \
    ln -s /opt/poetry/bin/poetry && \
    poetry config virtualenvs.create false
  
COPY pyproject.toml poetry.lock* ./

# Allow installing dev dependencies to run tests
ARG INSTALL_DEV=true
RUN bash -c "poetry lock"
RUN bash -c "if [ $INSTALL_DEV == 'true' ] ; then poetry install --no-root ; else poetry install --no-root --no-dev ; fi"

CMD mkdir -p /code
WORKDIR /code
ENV SHELL /bin/bash

ADD . .
ENTRYPOINT [ "make" ]