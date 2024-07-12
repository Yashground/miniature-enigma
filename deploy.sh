#!/bin/bash

# Variables
IMAGE_NAME="minipekka/deploy"
LATEST_TAG="stable"
VERSION_FILE="version.txt"
DOCKERFILE_PATH="./Dockerfile"  # Explicitly specifying the Dockerfile path

# Function to get the current version
get_current_version() {
  if [ ! -f $VERSION_FILE ]; then
    echo "1" > $VERSION_FILE
  fi
  cat $VERSION_FILE
}

# Function to increment the version
increment_version() {
  local version=$(get_current_version)
  local new_version=$((version + 1))
  echo $new_version > $VERSION_FILE
  echo $new_version
}

# Get the current version and increment it
current_version=$(get_current_version)
new_version=$(increment_version)

# Login to Docker Hub
echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USERNAME" --password-stdin
if [ $? -ne 0 ]; then
  echo "Docker login failed"
  exit 1
fi

# Build the Docker image with the latest tag
docker build -f $DOCKERFILE_PATH -t $IMAGE_NAME:$LATEST_TAG .
if [ $? -ne 0 ]; then
  echo "Docker build failed"
  exit 1
fi

# Run the Docker container to test it
docker run --name temp_container -d $IMAGE_NAME:$LATEST_TAG
if [ $? -ne 0 ]; then
  echo "Docker run failed"
  exit 1
fi

# Check if the container is running successfully
if [ "$(docker inspect -f {{.State.Running}} temp_container)" = "true" ]; then
  echo "Container is running successfully."

  # Tag the image with the new version
  docker tag $IMAGE_NAME:$LATEST_TAG $IMAGE_NAME:$new_version

  # Push the latest and the new version tags to Docker Hub
  docker push $IMAGE_NAME:$LATEST_TAG
  if [ $? -ne 0 ]; then
    echo "Docker push failed for latest tag"
    exit 1
  fi

  docker push $IMAGE_NAME:$new_version
  if [ $? -ne 0 ]; then
    echo "Docker push failed for version tag"
    exit 1
  fi

  echo "Image pushed to Docker Hub with tags: $LATEST_TAG and $new_version"
else
  echo "Container failed to start."
  exit 1
fi

# Output the new version for GitHub Actions
echo "::set-output name=version::$new_version"

# Clean up
docker stop temp_container
docker rm temp_container
