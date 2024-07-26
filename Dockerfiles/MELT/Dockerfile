FROM ubuntu:24.04
# Dependencies for MELT
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y \
        bcftools \
        bzip2 \
        ca-certificates \
        libbz2-dev \
        liblzma-dev \
        libncurses5-dev \
        libtbb-dev \
        libz-dev \
        openjdk-17-jre-headless \
        samtools \
        tabix \
        vcftools \
        zlib1g-dev \
        bowtie2 
# MELT
ADD MELTv2.2.2 /opt/