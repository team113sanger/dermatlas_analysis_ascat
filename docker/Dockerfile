FROM rocker/r-base:4.2.2 as builder

USER  root

RUN apt-get update -y && \
    apt-get install -yq --no-install-recommends \
    build-essential \
    apt-transport-https \
    curl \
    ca-certificates \
    libtasn1-dev \
    nettle-dev \
    libgmp-dev \
    libp11-kit-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-gnutls-dev \
    libncurses-dev \
    r-cran-devtools \
    r-bioc-genomicranges && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ENV OPT="/opt/dermatlas"
ENV PATH="${OPT}/bin:$PATH" \
    LD_LIBRARY_PATH="${OPT}/lib" \
    R_LIBS="$OPT/R-lib" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8"
ENV R_LIBS_USER="$R_LIBS"

ENV VER_ALLELECOUNT="4.3.0" \
    VER_HTSLIB="1.17" \
    VER_LIBDEFLATE="v1.9"

COPY build/install_libdeflate.sh /tmp/.
RUN /tmp/install_libdeflate.sh $OPT

COPY build/install_htslib.sh /tmp/.
RUN /tmp/install_htslib.sh $OPT

COPY build/install_alleleCount_C.sh /tmp/.
RUN /tmp/install_alleleCount_C.sh $OPT

COPY build/install_R_packages.R /tmp/.
RUN  mkdir -p $R_LIBS && Rscript /tmp/install_R_packages.R

FROM rocker/r-base:4.2.2

USER root

RUN apt-get -yq update && \
    apt-get install -yq --no-install-recommends \
    apt-transport-https \
    curl \
    ca-certificates \
    bzip2 \
    zlib1g \
    liblzma5 \
    libncurses5-dev \
    p11-kit \
    r-bioc-genomicranges \
    r-cran-argparser \
    unattended-upgrades && \
    unattended-upgrade -d -v && \
    apt-get remove -yq unattended-upgrades && \
    apt-get autoremove -yq && \
    rm -rf /var/lib/apt/lists/*

# LABEL maintainer="cgphelp@sanger.ac.uk" \
#       uk.ac.sanger.cgp="Cancer, Ageing and Somatic Mutation, Wellcome Trust Sanger Institute" \
#       description="Dermatlas ASCAT image"

ENV OPT="/opt/dermatlas"
ENV PATH="${OPT}/bin:$PATH" \
    LD_LIBRARY_PATH="${OPT}/lib" \
    R_LIBS="$OPT/R-lib" \
    R_LIBS_USER="$R_LIBS" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8"

RUN mkdir -p $OPT
COPY --from=builder $OPT $OPT
COPY build/run_ascat.R $OPT/bin/.

### this belongs in final minimised image

RUN useradd ascat --shell /bin/bash --create-home --home-dir /home/ascat

USER ascat
WORKDIR /var/spool/output

# Check dependencies can be found
RUN alleleCounter --version && \
    R --version && \
    R --slave -e 'packageVersion("ASCAT")' && \
    R --slave -e 'packageVersion("GenomicRanges")' && \
    R --slave -e 'packageVersion("IRanges")' && \
    R --slave -e 'packageVersion("ggplot2")' && \
    R --slave -e 'packageVersion("tidyverse")' && \
    R --slave -e 'packageVersion("optparse")' && \
    R --slave -e 'packageVersion("valr")' && \
    R --slave -e 'packageVersion("dplyr")' && \
    run_ascat.R --help

CMD ["/bin/bash"]
