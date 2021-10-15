#FROM pytorch/pytorch:1.9.0-cuda11.1-cudnn8-runtime 
FROM ubuntu:18.04

#ENV PATH=/opt/conda/bin:$PATH
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update && apt-get -y upgrade && apt-get install -y python3-pip
RUN apt-get install -y wget
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install pyvirtualdisplay xlrd selenium beautifulsoup4 flask wget xmltodict flask-cors flask_restx pororo fasttext pymysql sklearn numpy pandas
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update 
RUN apt-get install -y google-chrome-stable xvfb

WORKDIR /root

EXPOSE 5000
ENTRYPOINT [ "python3", "app.py"]
