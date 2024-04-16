## Setup

1. Clone repo and `cd`
2. Run `setup.sh`
    - This sets up data directories
3. Install required libraries

```
R -e "install.packages('renv')"
R -e "renv::restore('microbiome_analysis/')"
```

### Running interactively

Use any of the tools from within `analysis.R` - this sets up the environment and source tools etc. Change `script_dir` at top of file.

### Running from CLI

1. `cd` to `microbiome_analysis` directory
2. Run commands like `Rscript cmdline_util.R --help`

**Example**

```
Rscript cmdline_util.R --function do_pcoa --data path/to/data.tsv --output path/to/file.extension
```

### Running inside Docker

1. Uncomment lines for Docker at start of `cmdline_util.R`
2. `cd` to `microbiome_analysis` directory
3. Run `docker_testing.sh` to build image and start container
4. Use `run_in_docker.sh` as a guide for copying files into and executing commands within the container