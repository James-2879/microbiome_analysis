echo "Check all necessary R packages are added to Dockerfile."
echo ""
echo "> Stopping container if running"
sudo docker container stop microbiome-analysis
echo ""
echo "> Removing container if present"
sudo docker container rm microbiome-analysis-container
echo ""
echo "> Removing image if present"
sudo docker image rm microbiome-analysis
echo ""
echo "> Building image"
DOCKER_BUILDKIT=1 sudo docker build -t microbiome-analysis .
echo ""
echo "> Launching container"
sudo docker run -d --name microbiome-analysis-container microbiome-analysis
echo ""

# docker exec -it microbiome-analysis-container /bin/bash
