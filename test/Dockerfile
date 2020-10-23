FROM swift:5.3

WORKDIR /code

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


COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

EXPOSE 5000

COPY . .

CMD ["flask", "run" "-p", "8080"]