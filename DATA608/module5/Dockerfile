FROM python:2-alpine

COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip install -U pip
RUN apk --update add python py-pip openssl ca-certificates py-openssl wget bash linux-headers
RUN apk --update add --virtual build-dependencies libffi-dev openssl-dev python-dev py-pip build-base \
  && pip install -U pipenv\
  && pip uninstall ansible\
  && pip install ansible\
  && pip install -U -r /app/requirements.txt\
  && apk del build-dependencies

COPY . /app

ENTRYPOINT ["python"]

CMD ["tree-rest-api.py"]
