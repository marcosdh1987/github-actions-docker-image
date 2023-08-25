FROM python:3.10

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y locales locales-all

RUN apt update && apt upgrade -y

RUN apt install git -y && \
    pip3 install boto3 pandas sagemaker

RUN export LC_ALL=es_ES

ENV PYTHONUNBUFFERED=TRUE

ARG NB_USER="sagemaker-user"
ARG NB_UID="1000"
ARG NB_GID="100"

RUN useradd --create-home --shell /bin/bash --gid "${NB_GID}" --uid ${NB_UID} ${NB_USER} && \
    python3.10 -m pip install ipykernel && \
    python3.10 -m ipykernel install

USER ${NB_UID}

