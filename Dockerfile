ARG PHASE
ARG APIDOC_TYPE

FROM python:3.11-slim

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y make

WORKDIR /app

COPY . .

RUN pip install -r ./requirements.txt

USER 1000:1000

ENTRYPOINT [ "python", "src/__main__.py" ]