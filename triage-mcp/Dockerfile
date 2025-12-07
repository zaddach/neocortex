FROM python:3.13-slim

WORKDIR /app
RUN apt update && \
    apt install -y libglib2.0-0t64
RUN pip install mcpo https://github.com/eversinc33/TriageMCP/archive/1c51a2df7006e69fcb2b7bedf18fb74b7bb06163.tar.gz

EXPOSE 80
USER 65532:65532
ENTRYPOINT ["mcpo", "--port", "80", "--", "python", "-m", "triage"]
