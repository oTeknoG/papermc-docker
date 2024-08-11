#!/bin/bash

# Enter server directory
cd papermc

# Set Minecraft version to 1.20.4 and Paper build to 'latest'
: ${MC_VERSION:='1.20.4'}
: ${PAPER_BUILD:='latest'}

# Lowercase these to avoid 404 errors on wget
MC_VERSION="${MC_VERSION,,}"
PAPER_BUILD="${PAPER_BUILD,,}"

# Base URL for PaperMC API
URL='https://api.papermc.io/v2/projects/paper'

# Build the URL for the specified version (1.20.4)
VERSION_URL="${URL}/versions/${MC_VERSION}"

# Get the latest build if not specified
if [[ $PAPER_BUILD == latest ]]; then
  PAPER_BUILD=$(wget -qO - "$VERSION_URL" | jq -r '.builds[-1]')
fi

# Construct the JAR file name and download URL
JAR_NAME="paper-${MC_VERSION}-${PAPER_BUILD}.jar"
DOWNLOAD_URL="${VERSION_URL}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}"

# Download the PaperMC server jar if it's not already present
if [[ ! -e $JAR_NAME ]]; then
  # Remove any existing JAR files
  rm -f *.jar
  # Download the new server jar
  wget "$DOWNLOAD_URL" -O "$JAR_NAME"
fi

# Ensure the EULA is accepted
echo "eula=${EULA:-false}" > eula.txt

# Set memory allocation options if specified
if [[ -n $MC_RAM ]]; then
  JAVA_OPTS="-Xms${MC_RAM} -Xmx${MC_RAM} $JAVA_OPTS"
fi

# Start the Minecraft server
exec java -server $JAVA_OPTS -jar "$JAR_NAME" nogui
