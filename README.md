# Microbiome Analysis

Collection of tools to visualize microbiological abundance data.

## Local setup

1. Clone repo and `cd`
2. Run `local_setup.sh` to install necessary dependencies

### Running interactively

Use any of the tools from within `analysis.R` - this sets up the environment and source tools etc. Change `script_dir` at the top of the file.

> [!NOTE]
> `analysis.R` is primarily just a set of example functions.

### Running from CLI

1. `cd` to `microbiome_analysis` directory
2. Run commands like `Rscript file.R --help`

**Example**

```
Rscript pcoa.R --data path/to/data.tsv --output path/to/file.extension
```

## Running inside Docker

1. `cd` to `microbiome_analysis` directory
2. Run `docker_testing.sh` to build image and start container
3. Use `run_in_docker.sh` as a guide for copying files into and executing commands within the container
