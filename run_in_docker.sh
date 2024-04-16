# Copy data in if needed
# docker cp /home/$USER/Documents/microbiome_analysis/data/input/all_samples.tsv microbiome-analysis-container:/usr/local/bin/microbiome_analysis/data/input/all_samples.tsv

# Run command in Docker container
docker exec microbiome-analysis-container Rscript cmdline_util.R --function do_pcoa --data data/input/all_samples.tsv --output data/output/pcoa.jpeg 

# Copy from container to local OS
docker cp microbiome-analysis-container:/usr/local/bin/microbiome_analysis/data/output/pcoa.jpeg ~/Downloads/

# Run container interactively
# docker exec -it microbiome-analysis-container /bin/bash

