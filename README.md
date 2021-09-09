# CodeChecker Docker

Run CodeChecker (analyzer) in a Docker container.

## What is this

Installing CodeChecker from PyPi is currently broken:

https://github.com/Ericsson/codechecker/issues/3395

Until there's a new release published to PyPi, it's necessary to run through the
manual installation steps, which includes installing node.js to the build host
among other dependencies.

Instead of doing that, here's a docker image that contains a copy of pre-built
CodeChecker.

## Usage

To use it on a `make` based project, you can do this:

```bash
# run the container as the current user so it can write to the mounted volume.
# the default entrypoint runs the analysis pass and generates ./reports{,_html}
# (see run-codechecker.sh)
❯ docker run --user "$(id -u):$(id -g)" --rm -v $PWD:/workdir -i -t \
    noahpendleton/codechecker 'make'

# to access the bare CodeChecker command instead of the run script
❯ docker run --user "$(id -u):$(id -g)" --rm -v $PWD:/workdir -i \
    --entrypoint /usr/bin/CodeChecker -t noahpendleton/codechecker \
    <arbitrary commands passed to CodeChecker>
```
