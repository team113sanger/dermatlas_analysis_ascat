# MUTLI-STAGE DOCKERFILE for building a Python image
# STAGE 1: builder is the disposable image that makes build products into /opt
# STAGE 2: (default) is the final image that is copied from /opt in the builder image

########################
# STAGE 1: builder     #
########################

# IMPORTANT
# If you change the base image, you will need to update the
# PRE_FETCH_BASE_IMAGE variable in the .gitlab-ci.yml file also.


FROM rocker/tidyverse:4.2.2 as builder


USER root
ENV \
    DATA_DIRECTORY="/data" \
    OPT_DIRECTORY="/opt" \
    USER_NAME="admin" \
    USER_DIRECTORY="/home/admin" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8"

ENV \
    USER_BASHRC="${USER_DIRECTORY:?}/.bashrc" \
    USER_BIN_DIRECTORY="${USER_DIRECTORY:?}/.local/bin" \
    SSH_DIR="${USER_DIRECTORY:?}/.ssh" \
    PROJECT_DIRECTORY="${OPT_DIRECTORY:?}/repo" \
    RENV_DIRECTORY="${OPT_DIRECTORY:?}/renv" \
    RENV_PATHS_CACHE="${OPT_DIRECTORY:?}/renv-cache" \
    LOGGING_DIRECTORY="${DATA_DIRECTORY:?}/logs" \
    OTHER_INSTALLS_DIRECTORY="${OPT_DIRECTORY:?}/other-installs" \
    OTHER_INSTALLS_LIB="${OPT_DIRECTORY:?}/other-installs/lib" \
    OTHER_INSTALLS_BIN="${OPT_DIRECTORY:?}/other-installs/bin"


ENV \
    PATH="${OTHER_INSTALLS_BIN:?}:$PATH" \
    LD_LIBRARY_PATH="${OTHER_INSTALLS_LIB:?}" \
    VER_ALLELECOUNT="4.3.0" \
    VER_HTSLIB="1.17" \
    VER_LIBDEFLATE="v1.9" \
    RENV_PATHS_LIBRARY="${RENV_DIRECTORY:?}/library"

RUN \
    locale-gen "${LANG:?}" \
    && update-locale LANG="${LANG:?}" \
    && useradd "${USER_NAME}" --shell /bin/bash --create-home --home-dir "${USER_DIRECTORY}" \
    && mkdir -p "${PROJECT_DIRECTORY:?}" "${DATA_DIRECTORY:?}" "${OPT_DIRECTORY:?}" "${RENV_DIRECTORY:?}" "${RENV_PATHS_LIBRARY:?}" "${RENV_PATHS_CACHE:?}" "${OTHER_INSTALLS_LIB:?}" "${OTHER_INSTALLS_BIN:?}" \
    && chown -R "${USER_NAME:?}:${USER_NAME:?}" "${PROJECT_DIRECTORY:?}" "${DATA_DIRECTORY:?}" "${USER_DIRECTORY:?}" "${OPT_DIRECTORY:?}" \
    && chmod -R 755 "${PROJECT_DIRECTORY:?}" "${DATA_DIRECTORY:?}" "${USER_DIRECTORY:?}" "${OPT_DIRECTORY:?}" 

RUN \
    apt-get update -y \
    && apt-get install -yq --no-install-recommends \
    build-essential \
    apt-transport-https \
    curl \
    tree \
    procps \
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


COPY --chown="${USER_NAME}:${USER_NAME}" ["docker/build/install_libdeflate.sh", "docker/build/install_htslib.sh", "docker/build/install_alleleCount_C.sh", "/tmp/"]
RUN \
    /tmp/install_libdeflate.sh "${OTHER_INSTALLS_DIRECTORY:?}" && \
    /tmp/install_htslib.sh "${OTHER_INSTALLS_DIRECTORY:?}" && \
    /tmp/install_alleleCount_C.sh "${OTHER_INSTALLS_DIRECTORY:?}"


WORKDIR $PROJECT_DIRECTORY

COPY --chown="${USER_NAME}:${USER_NAME}" [".gitignore", ".Rprofile", "renv.loc[k]", "dependencies.R", "setup_dependencies.R", "./"]
COPY --chown="${USER_NAME}:${USER_NAME}" ["renv/activate.R", "renv/settings.json", "./renv/"]

RUN Rscript setup_dependencies.R --force

# We set the R_LIBS environment variable to the renv library path so that the
# Rscript command will use the renv library path by default.
ENV R_LIBS="/opt/renv/library/R-4.2/x86_64-pc-linux-gnu"

COPY --chown="${USER_NAME}:${USER_NAME}" . .

# Reapply permissions after all installation and copying is done so the user can
# manipulate the files if necessary
RUN \
    chown -R "${USER_NAME:?}:${USER_NAME:?}" "${PROJECT_DIRECTORY:?}" "${DATA_DIRECTORY:?}" "${USER_DIRECTORY:?}" "${OPT_DIRECTORY:?}" \
    && chmod -R 755 "${PROJECT_DIRECTORY:?}" "${DATA_DIRECTORY:?}" "${USER_DIRECTORY:?}" "${OPT_DIRECTORY:?}"


USER "${USER_NAME:?}"


# Build time test to confirm that the package is installed
# TODO - remove this once CI has a better way to test. We want to check R finds
# these packages when outside of the repo (the repo is bootstrapped by .Rprofile)
WORKDIR /
RUN R --version && \
    R --slave -e 'packageVersion("ASCAT")' && \
    R --slave -e 'packageVersion("GenomicRanges")' && \
    R --slave -e 'packageVersion("IRanges")' && \
    R --slave -e 'packageVersion("optparse")' && \
    R --slave -e 'packageVersion("dplyr")'

WORKDIR $PROJECT_DIRECTORY
CMD ["/bin/bash"]