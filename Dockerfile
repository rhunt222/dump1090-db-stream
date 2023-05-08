FROM alpine/latest
LABEL org.opencontainers.image.source=https://github.com/rhunt222/dump1090-db-stream
LABEL org.opencontainers.image.authors="richard.hunt2@gmail.com"
LABEL description="Docker container to ingest ADS/B data via Dump1090 streams and store it in a PostgreSQL database."

ENV DUMP1090HOST="192.168.86.30"
ENV DUMP1090PORT="30003"
ENV PGHOST="192.168.86.30"
ENV PGPORT="5432"
ENV PGDATABASE="adsb"
ENV PGSCHEMA="adsb"
ENV PGTABLE="adsb_messages"
ENV PGUSER="hunta03"
ENV PGPASSWORD="airplanes!"
ENV BUFFER_SIZE="10000"
ENV BATCH_SIZE="1"
ENV CONNECT_ATTEMPT_LIMIT="10"
ENV CONNECT_ATTEMPT_DELAY="5.0"

RUN apk add --no-cache python3

COPY create_schema.sql .
COPY dump1090-postgres.py .
COPY requirements.txt .
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["python", "/dump1090-postgres.py"]
