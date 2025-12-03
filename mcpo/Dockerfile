FROM python:3.14-slim
RUN pip install mcpo
ADD ./mcpo-config.json /etc/mcpo-config.json
ENTRYPOINT ["mcpo", "--port", "80", "--config", "/etc/mcpo-config.json", "--api-key", "secret"]

