FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu14.04 

RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         libjpeg-dev \
         libpng-dev &&\
     rm -rf /var/lib/apt/lists/*

RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \     
     rm ~/miniconda.sh && \
     /opt/conda/bin/conda install conda-build && \
     /opt/conda/bin/conda create -y --name pytorch-py35 python=3.5.2 numpy scipy ipython mkl&& \
     /opt/conda/bin/conda clean -ya 
ENV PATH /opt/conda/envs/pytorch-py35/bin:$PATH
RUN conda install --name pytorch-py35 -c soumith magma-cuda80
# This must be done before pip so that requirements.txt is available
WORKDIR /opt/pytorch
COPY . .

RUN cat requirements.txt | xargs -n1 pip install --no-cache-dir && \
    TORCH_CUDA_ARCH_LIST="3.5 5.2 6.0 6.1+PTX" TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    CMAKE_LIBRARY_PATH=/opt/conda/envs/pytorch-py35/lib \
    CMAKE_INCLUDE_PATH=/opt/conda/envs/pytorch-py35/include \
    pip install -v .

WORKDIR /workspace
RUN chmod -R a+w /workspace
