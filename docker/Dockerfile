# MUTLI-STAGE DOCKERFILE for building a Python image
# STAGE 1: builder is the disposable image that makes build products into /opt
# STAGE 2: (default) is the final image that is copied from /opt in the builder image

########################
# STAGE 1: builder     #
########################

# IMPORTANT
# If you change the base image, you will need to update the
# PRE_FETCH_BASE_IMAGE variable in the .gitlab-ci.yml file also.


FROM rocker/r-base:4.2.2 as builder


USER root
ENV \
    DATA_DIRECTORY="/data" \
    OPT_DIRECTORY="/opt" \
    USER_NAME="admin" \
    USER_DIRECTORY="/home/admin" \
    R_LIB_DIR="/usr/local/lib/R/site-library"

ENV \
    USER_BASHRC="${USER_DIRECTORY:?}/.bashrc" \
    USER_BIN_DIRECTORY="${USER_DIRECTORY:?}/.local/bin" \
    SSH_DIR="${USER_DIRECTORY:?}/.ssh" \
    PROJECT_DIRECTORY="${OPT_DIRECTORY:?}/repo" \
    RENV_DIRECTORY="${OPT_DIRECTORY:?}/renv" \
    RENV_PATHS_CACHE="${OPT_DIRECTORY:?}/renv-cache" \
    LOGGING_DIRECTORY="${DATA_DIRECTORY:?}/logs"

ENV \
    RENV_PATHS_LIBRARY="${RENV_DIRECTORY:?}/library"

RUN \
    useradd "${USER_NAME}" --shell /bin/bash --create-home --home-dir "${USER_DIRECTORY}" \
    && mkdir -p "${PROJECT_DIRECTORY:?}" "${DATA_DIRECTORY:?}" "${OPT_DIRECTORY:?}" "${RENV_DIRECTORY:?}" "${RENV_PATHS_LIBRARY:?}" "${RENV_PATHS_CACHE:?}" \
    && chown -R "${USER_NAME:?}:${USER_NAME:?}" "${PROJECT_DIRECTORY:?}" "${DATA_DIRECTORY:?}" "${USER_DIRECTORY:?}" "${OPT_DIRECTORY:?}" \
    && chmod -R 755 "${PROJECT_DIRECTORY:?}" "${DATA_DIRECTORY:?}" "${USER_DIRECTORY:?}" "${OPT_DIRECTORY:?}" 

RUN \
    apt-get update -y \
    && apt-get install -yq --no-install-recommends \
    build-essential \
    apt-transport-https \
    curl \
    tree \
    ca-certificates \
    libtasn1-dev \
    nettle-dev \
    libgmp-dev \
    libp11-kit-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libxml2-dev \
    libncurses-dev \
    && rm -rf /var/lib/apt/lists/*


# TODO - DO WE NEED TO INSTALL BIOCMANAGER OR LET RENV DO IT?
# RUN \
#     install2.r --error --skipinstalled --ncpus -1 \
#     renv \
#     devtools \
#     BiocManager \ 
#     && R --slave -e "BiocManager::install(version = '3.16')" \
#     && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
RUN \
    install2.r --error --skipinstalled --ncpus -1 \
    renv \
    devtools \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

WORKDIR $PROJECT_DIRECTORY
COPY --chown="${USER_NAME}:${USER_NAME}" [".gitignore", ".Rprofile", "renv.loc[k]", "dependencies.R", "setup_dependencies.R", "./"]
COPY --chown="${USER_NAME}:${USER_NAME}" ["renv/activate.R", "renv/settings.json", "./renv/"]

# --mount=type=cache,target=${RENV_PATHS_CACHE:?},sharing=locked \
RUN \
    tree . -a -L 2 && \
    Rscript setup_dependencies.R --force

# # https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/reference.md#run---mounttypecache

# # R -e "install.packages('renv', lib = '${RENV_PATHS_LIBRARY:?}', repos = 'https://cloud.r-project.org')" \
# # && R -e "install.packages('devtools', lib = '${RENV_PATHS_LIBRARY:?}', repos = 'https://cloud.r-project.org')"


RUN R --version && \
    R --slave -e 'packageVersion("ASCAT")' && \
    R --slave -e 'packageVersion("GenomicRanges")' && \
    R --slave -e 'packageVersion("IRanges")'