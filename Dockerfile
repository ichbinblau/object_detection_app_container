FROM ubuntu:16.04

MAINTAINER theresa.shan@intel.com

RUN apt-get update \
    && apt-get install -y wget \
    git \
    build-essential \
    unzip \
    bzip2 \
    software-properties-common \
    python-setuptools \
    vim \
    libgtk2.0-0

# create user edge
RUN useradd -c "edge device" -m edge

COPY 10-installer /etc/sudoers.d/

USER edge

WORKDIR /home/edge

RUN wget -O /home/edge/Anaconda3-5.1.0-Linux-x86_64.sh https://repo.continuum.io/archive/Anaconda3-5.1.0-Linux-x86_64.sh

RUN bash Anaconda3-5.1.0-Linux-x86_64.sh -b -p /home/edge/anaconda3

ENV PATH /home/edge/anaconda3/bin:$PATH

RUN git clone https://github.com/datitran/object_detector_app.git

WORKDIR /home/edge/object_detector_app

COPY environment.yml /home/edge/object_detector_app/environment.yml

RUN conda env create -f environment.yml python=3.5

#RUN ["/bin/bash", "-c", "source activate object-detection && python3 object_detection_app.py"]
