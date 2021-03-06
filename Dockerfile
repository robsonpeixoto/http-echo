FROM python:3.6-alpine as builder

WORKDIR /app

COPY Pipfile /app
COPY Pipfile.lock /app

RUN set -e \
    && apk add --no-cache --update --virtual .build-deps \
    gcc make musl-dev linux-headers \
    # && apk add --no-cache --update --virtual .build-deps \
    #         gcc \
    #         g++ \
    #         make \
    #         libc-dev \
    #         musl-dev \
    #         linux-headers \
    #         libffi-dev \
    #         pcre-dev \
    && pip install -q pipenv \
    && pipenv install --system \
    && runDeps="$( \
            scanelf --needed --nobanner --recursive /usr \
                    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                    | sort -u \
                    | xargs -r apk info --installed \
                    | sort -u \
    )" \
    && apk add --virtual .python-rundeps $runDeps \
    && apk del .build-deps

FROM builder

COPY . /app

RUN adduser -S app

USER app

EXPOSE 5000

ENTRYPOINT ["uwsgi", "--http", "0.0.0.0:5000", "--wsgi-file", "http_echo/app.py", \
            "--callable", "app", "--master", "--offload-threads", \
            "--enable-threads", "--threads", "4", "--http-keepalive", \
            "--stats=0.0.0.0:1717", "--buffer-size", "32768", "--disable-logging", \
            "--max-worker-lifetime", "30"]
