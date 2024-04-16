FROM rocker/shiny-verse:latest

LABEL author="James Swift"
LABEL maintainer="James Swift"
LABEL name="Microbiome Analysis"
LABEL version="1.0"

RUN apt update
RUN apt upgrade -y
RUN apt install iputils-ping -y
RUN apt install cmake -y

COPY . /usr/local/bin/microbiome_analysis/

RUN R -e "install.packages('renv')"
RUN R -e "renv::restore('/usr/local/bin/microbiome_analysis/')"
