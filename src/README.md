# Repositories in src/

This directory is ignored by git. By default any repositories created or cloned in this will be mounted in the container at `/fieldsets/`. You can change the local source directory to be mounted using the `${FIELDSETS_LOCAL_SRC_PATH}` environment variable.