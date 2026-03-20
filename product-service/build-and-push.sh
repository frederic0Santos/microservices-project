IMAGE_NAME="frederic0santos/product-service"
VERSION=${1:-"latest"}
GIT_COMMIT=$(git rev-parse --short HEAD)

# Build
docker build -t ${IMAGE_NAME}:${VERSION} .
docker build -t ${IMAGE_NAME}:${GIT_COMMIT} .

# Push
docker push ${IMAGE_NAME}:${VERSION}
docker push ${IMAGE_NAME}:${GIT_COMMIT}