FROM alpine:latest
LABEL org.opencontainers.image.source=https://github.com/rhunt222/dump1090-db-stream
LABEL org.opencontainers.image.authors=""
LABEL description="Docker container to ingest ADS/B data via Dump1090 streams and store it in a PostgreSQL database."

ENV DUMP1090HOST="localhost"
ENV DUMP1090PORT="30003"
ENV PGHOST="localhost"
ENV PGPORT="5432"
ENV PGDATABASE="adsb"
ENV PGSCHEMA="adsb"
ENV PGTABLE="adsb_messages"
ENV PGUSER="user"
ENV PGPASSWORD="pw"
ENV BUFFER_SIZE="10000"
ENV BATCH_SIZE="1"
ENV CONNECT_ATTEMPT_LIMIT="10"
ENV CONNECT_ATTEMPT_DELAY="5.0"
ENV PYTHONPATH=/usr/local/lib/python3.7/site-packages

RUN apk add --no-cache python3
RUN apk add --no-cache postgresql-libs && apk add --no-cache --virtual .build-deps gcc musl-dev postgresql-dev
RUN pip install --no-cache-dir virtualenv

COPY create_schema.sql .
COPY dump1090-postgres.py .
COPY requirements.txt .
ENV VIRTUAL_ENV=/opt/venv
RUN python -m virtualenv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN /bin/sh -c "source $VIRTUAL_ENV/bin/activate && pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir psycopg2-binary==2.9.6"

ENTRYPOINT ["python", "/dump1090-postgres.py"]
