# Install R version 3.5.1
FROM r-base:4.0.2

# system libraries of general use - I don't know if these are right ????
RUN apt-get update && apt-get install -y \
    default-jdk \
    libbz2-dev \
    zlib1g-dev \
    gfortran \
    liblzma-dev \
    libpcre3-dev \
    libreadline-dev \
    xorg-dev \
    sudo \  
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libxml2-dev


RUN R -e "install.packages(c('shiny', 'shiny.router', 'glue', 'dplyr', 'tidytext', 'stringr', 'stringi', 'wordcloud2', 'tidyverse', 'tokenizers', 'philentropy'), repos = 'http://cran.us.r-project.org')"


# copy the app to the image
COPY app.R /root/app.R
COPY helper_functions.R /root/helper_functions.R
COPY www /root/www


COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e", "library(shiny); library(shiny.router); library(glue); library(dplyr); library(tidytext); library(stringr); library(stringi); library(wordcloud2); library(tidyverse); library(tokenizers); library(philentropy); source('/root/helper_functions.R'); shiny::runApp('/root', host='0.0.0.0', port=3838)"]
