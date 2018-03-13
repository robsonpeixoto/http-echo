FROM python:3.6-alpine as builder

WORKDIR /app

COPY Pipfile /app
COPY Pipfile.lock /app

RUN set -e \
    && apk add --no-cache --update --virtual .build-deps gcc make musl-dev linux-headers \
    && pip install --no-cache-dir -q pipenv \
    && pipenv install --system

COPY . /app

EXPOSE 5000
ENTRYPOINT ["gunicorn", "-k", "gevent", "-b", "0.0.0.0:5000", "--log-level", "debug", "http_echo.app:app"]
