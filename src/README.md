# Repositories in src/

This directory is ignored by git. By default any repositories created or cloned in this directory will be mounted in the container at `/usr/local/fieldsets/apps/`. You can change the local source directory to be mounted using the `${FIELDSET_SRC_PATH}` environment variable.
