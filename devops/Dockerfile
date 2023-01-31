# ------------------------------------------------------------------
# ---- Base Image
# ------------------------------------------------------------------
FROM python:3.9-slim-buster

# ENV_TEST variable is useful for poetry installation, we install only dev dependencies if it is set to True.
ARG POETRY_VERSION="1.2.0a2"
ARG ENV_TEST=false

# Save a few bytes (see: https://docs.python.org/3/using/cmdline.html#envvar-PYTHONDONTWRITEBYTECODE)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONIOENCODING=utf8

RUN apt -y -q update && \
    apt -y -q install curl

# Install poetry
ENV POETRY_HOME="/.poetry"
RUN curl -sSL https://install.python-poetry.org | python - --version  ${POETRY_VERSION} && \
    apt-get -y -q --purge autoremove curl && \
    apt-get -y -q clean autoclean && \
    rm -rf /var/lib/apt/lists/*

# Add poetry to the PATH
ENV PATH="${POETRY_HOME}/bin:${PATH}"
# BUG: poetry 1.2.0a2 seems to have a bug when working with the global Python
# environment, that's why we use per-project virtualenv.
WORKDIR /dbt_gcp
COPY pyproject.toml .
COPY poetry.lock .
RUN poetry config virtualenvs.in-project true && \
    poetry install $([ $ENV_TEST = true ] || echo "--no-dev") --no-root --no-interaction

# Copy application code.
COPY bin bin
COPY modules modules
COPY tests tests

COPY analytics/dbt_project.yml analytics/
COPY analytics/packages.yml analytics/
COPY analytics/profiles.yml analytics/
COPY analytics/macros  analytics/macros
# To be adapted in the next article.
COPY analytics/models  analytics/models

### DBT requires git installed.
RUN apt update -y && apt install git -y

# Activate virtualenv
ENV VIRTUAL_ENV=/dbt_gcp/.venv
ENV PATH=$VIRTUAL_ENV/bin:$PATH
# Install dbt packages
ENV DBT_PROFILES_DIR=analytics
RUN dbt deps --project-dir=analytics

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
# Start the flask service
ENTRYPOINT exec python -m gunicorn \
    --bind :${PORT} \
    --workers 1 \
    --threads 8 \
    --timeout 0 \
    bin.dbt_run:app