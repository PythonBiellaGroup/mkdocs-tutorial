FROM --platform=linux/amd64 ghcr.io/pythonbiellagroup/dockbase/python-base:0.0.3 as python

# FROM --platform=linux/amd64 python:3.10.12-slim-buster as python

# Metadata
LABEL name="Mkdocs website"
LABEL maintainer="PBG"
LABEL version="0.1"

# ARG YOUR_ENV="virtualenv"
# ARG POETRY_VERSION="1.7.1"

# ENV YOUR_ENV=${YOUR_ENV} \
#     PYTHONDONTWRITEBYTECODE=1 \
#     PYTHONUNBUFFERED=1 \
#     PYTHONFAULTHANDLER=1 \
#     PYTHONHASHSEED=random \
#     PIP_NO_CACHE_DIR=off \
#     PIP_DISABLE_PIP_VERSION_CHECK=on \
#     PIP_DEFAULT_TIMEOUT=100 \
#     POETRY_HOME=/opt/poetry \
#     POETRY_VIRTUALENVS_CREATE=false \
#     POETRY_VIRTUALENVS_IN_PROJECT=false \
#     POETRY_NO_INTERACTION=1 \
#     POETRY_VERSION=${POETRY_VERSION} \
#     LC_ALL=C.UTF-8 \
#     LANG=C.UTF-8

# ENV PATH="$POETRY_HOME/bin:$PATH"

# add ssh config capabilities
# RUN mkdir -p ~/.ssh
# COPY bin/ssh-config.sh /usr/bin
# RUN chmod +x /usr/bin/ssh-config.sh

# RUN DEBIAN_FRONTEND=noninteractive apt update && apt install -y \
#     wget curl libpq-dev gcc wget gnupg2 curl openssh-client make git build-essential

# RUN  wget -O install-poetry.py https://install.python-poetry.org/ \
#     && python install-poetry.py --version ${POETRY_VERSION}

# Project Python definition
WORKDIR /app

#Copy poetry files
COPY pyproject.toml poetry.lock poetry.toml ./

RUN poetry install --no-interaction --no-ansi --only main && \
    rm -rf /root/.cache/pypoetry

COPY docs ./docs
COPY myapp ./myapp
# COPY theme ./theme
# COPY notebooks ./notebooks

# COPY Makefile .
COPY mkdocs.yml .
# COPY mkdocs.insiders.yml .

# RUN make docs_build
RUN mkdocs build --clean --quiet --config-file mkdocs.yml

## STAGE 2 Nginx deploy
FROM --platform=linux/amd64 nginx as deploy

COPY --from=python /app/site /usr/share/nginx/html

# Copy the nginx config to nginx config directly
COPY nginx.conf /etc/nginx/conf.d