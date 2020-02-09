FROM python:3.8-alpine

ENV PYTHONUNBUFFERED 1

RUN apk update \
  # psycopg2 dependencies
  && apk add --virtual build-deps gcc python3-dev musl-dev \
  && apk add postgresql-dev \
  # Install pipenv
  && pip install pipenv

RUN mkdir /app
WORKDIR /app

COPY ./Pipfile.lock ./Pipfile.lock
COPY ./configuration ./configuration
COPY ./manage.py ./manage.py

RUN pipenv --bare install --ignore-pipfile --dev
RUN pipenv install psycopg2-binary 

COPY ./entrypoint.sh entrypoint.sh
RUN sed -i 's/\r$//g' entrypoint.sh
RUN chmod +x entrypoint.sh

COPY ./start.sh start.sh
RUN sed -i 's/\r$//g' start.sh
RUN chmod +x start.sh

COPY /api ./api

ENTRYPOINT ["/app/entrypoint.sh"]

