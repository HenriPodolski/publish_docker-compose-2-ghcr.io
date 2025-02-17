VERSION="$1"
OVERRIDE="$2"
REPO_TOKEN="$3"
ENV_FILE="$4"

echo "VERSION=$VERSION"
echo "OVERRIDE=$OVERRIDE"

docker login ghcr.io -u ${GITHUB_REF} -p ${REPO_TOKEN}

docker-compose -f $OVERRIDE --env-file $ENV_FILE up --no-start --remove-orphans

IMAGES=$(docker-compose -f $OVERRIDE --env-file $ENV_FILE images -q)

echo ".env file:"
cat .env
echo "IMAGES: $IMAGES"
for IMAGE in $IMAGES; do
    echo "IMAGE: $IMAGE"
    
    NAME=$(basename ${GITHUB_REPOSITORY}).$(docker inspect --format '{{ index .Config.Labels "name" }}' $IMAGE)
    TAG="ghcr.io/${GITHUB_REPOSITORY}/$NAME:$VERSION"

    docker tag $IMAGE $TAG
    docker push $TAG
done
