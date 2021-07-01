#FROM pytorch/pytorch:1.9.0-cuda11.1-cudnn8-runtime 
FROM ubuntu:18.04

#ENV PATH=/opt/conda/bin:$PATH

RUN apt-get update && apt-get -y upgrade && apt-get install -y python3-pip
RUN python3 -m pip install flask wget xmltodict flask-cors flask_restx

COPY . .

ENTRYPOINT ["/bin/bash"]
