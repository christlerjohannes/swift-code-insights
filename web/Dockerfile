FROM python:3.8.5-slim-buster

COPY . /

RUN pip install -r requirements.txt && pip install gunicorn

RUN chmod +x runserver.sh

ENTRYPOINT ["/runserver.sh"]