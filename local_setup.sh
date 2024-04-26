echo "Ensure this script is run from the parent level of the cloned repo"

# Make data directories. Don't do this if you are storing data elsewhere.
# mkdir data
# mkdir data/input
# mkdir data/output

echo "> Setting up R environment"
# Install dependencies from renv.lock file
R -e "install.packages('renv')"
R -e "renv::restore('/home/$USER/Documents/microbiome_analysis/')"
