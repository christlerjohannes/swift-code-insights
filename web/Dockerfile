FROM swift:5.3

ARG BB_BASE_URL
ENV BB_BASE_URL $BB_BASE_URL

ARG BB_PROJECT
ENV BB_PROJECT $BB_PROJECT

ARG BB_REPORT_SLUG
ENV BB_REPORT_SLUG $BB_REPORT_SLUG

ARG BB_TOKEN
ENV BB_TOKEN $BB_TOKEN

ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0

RUN apt-get update

RUN apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8


RUN apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y git
RUN apt-get install -y unzip

ENV SWIFTLINT_REVISION="master"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install tzdata

# delete all the apt list files since they're big and get stale quickly
RUN rm -rf /var/lib/apt/lists/*

# Install SwiftLint
RUN git clone --branch $SWIFTLINT_REVISION https://github.com/realm/SwiftLint.git && \
    cd SwiftLint && \
    swift build --configuration release --static-swift-stdlib && \
    mv `swift build --configuration release --static-swift-stdlib --show-bin-path`/swiftlint /usr/bin && \
    cd .. && \
    rm -rf SwiftLint

COPY . /

RUN pip install -r requirements.txt && pip install gunicorn

RUN chmod +x runserver.sh

ENTRYPOINT ["/runserver.sh"]