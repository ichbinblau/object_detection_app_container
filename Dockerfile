FROM ubuntu:16.04

MAINTAINER theresa.shan@intel.com

FROM ubuntu:16.04

ARG http_p

ARG https_p

ENV http_proxy ${http_p}

ENV https_proxy ${https_p}

RUN echo $https_proxy

RUN echo $http_proxy

# Uncomment the two lines below if you wish to use an Ubuntu mirror repository
# that is closer to you (and hence faster). The 'sources.list' file inside the
# 'tools/docker/' folder is set to use one of Ubuntu's official mirror in Taiwan.
# You should update this file based on your own location. For a list of official
# Ubuntu mirror repositories, check out: https://launchpad.net/ubuntu/+archivemirrors
#COPY sources.list /etc/apt
RUN rm /var/lib/apt/lists/* -vf

RUN apt-get update \
    && apt-get autoremove libopencv-dev python-opencv \
    && apt-get install -y wget \
    git \
    build-essential \
    cmake \
    unzip \
    bzip2 \
    software-properties-common \
    python-setuptools \
    vim \
    sudo \
    qt5-default libvtk6-dev \
    zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev libjasper-dev libopenexr-dev libgdal-dev \
    libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev yasm libopencore-amrnb-dev libopencore-amrwb-dev libv4l-dev libxine2-dev \
    libtbb-dev libeigen3-dev \
    python-dev python-tk python-numpy python3-dev python3-tk python3-numpy python3-pip \    
    ant default-jdk \
    doxygen

# create user edge
RUN useradd -c "edge device" -m edge

COPY 10-installer /etc/sudoers.d/

USER edge

WORKDIR /home/edge

#RUN wget -O /home/edge/Anaconda3-5.1.0-Linux-x86_64.sh https://repo.continuum.io/archive/Anaconda3-5.1.0-Linux-x86_64.sh

#RUN bash Anaconda3-5.1.0-Linux-x86_64.sh -b -p /home/edge/anaconda3

#ENV PATH /home/edge/anaconda3/bin:$PATH

RUN wget https://github.com/opencv/opencv/archive/3.4.0.zip \
    && unzip 3.4.0.zip \
    && rm 3.4.0.zip \
    && mv opencv-3.4.0 OpenCV

WORKDIR /home/edge/OpenCV

RUN mkdir build

WORKDIR /home/edge/OpenCV/build

RUN cmake -DWITH_IPP=OFF -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON -DWITH_XINE=ON -DBUILD_EXAMPLES=ON -DENABLE_PRECOMPILED_HEADERS=OFF ..

RUN make -j4

RUN sudo make install

RUN sudo ldconfig

# set proxy for user edge
ENV http_proxy ${http_p}
ENV https_proxy ${https_p}

RUN sudo -E -H pip3 install tensorflow==1.2.0 \
    backports.weakref==1.0rc1 \
    bleach==1.5.0 \
    html5lib==0.9999999 \
    markdown==2.2.0 \
    protobuf==3.3.0 \ 
    tensorflow==1.2.0 \
    werkzeug==0.12.2 \
    pillow==4.1.1 \
    matplotlib==2.0.2

RUN git config --global http.proxy $http_proxy || echo "No http proxy is set."
RUN git config --global https.proxy $https_proxy || echo "No https proxy is set."

RUN git clone --progress https://github.com/datitran/object_detector_app.git

WORKDIR /home/edge/object_detector_app

#COPY environment.yml /home/edge/object_detector_app/environment.yml

#RUN conda env create -f environment.yml python=3.5

#RUN ["/bin/bash", "-c", "source activate object-detection && python3 object_detection_app.py"]
