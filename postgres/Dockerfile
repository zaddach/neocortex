FROM postgres

ADD https://github.com/pgvector/pgvector.git#v0.8.1 /tmp/pgvector
RUN apt update && \
    apt install -y make gcc postgresql-server-dev-all && \
    cd /tmp/pgvector && \
    make OPTFLAGS="" && \
    make install && \
    rm -rf /tmp/pgvector && \
    apt remove -y make gcc postgresql-server-dev-all