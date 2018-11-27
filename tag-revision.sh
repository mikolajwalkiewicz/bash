#
# * Increment git tags in bash * #
#

# Branch to be pushed
BRANCH="master"

# Get the highest current tag
TAG_CURR=$( \
  git describe --abbrev=0 --tags
)
echo "Current highest git tag is: ${TAG_CURR}"

# Create an array from current highest tag
TAG_ARRAY=(${TAG_CURR//./ })

# Set variables values to an array records
# and increment revision part
TAG_MAJOR=${TAG_ARRAY[0]//v/}
TAG_MINOR=${TAG_ARRAY[1]}
TAG_REVISION=${TAG_ARRAY[2]}
TAG_REVISION=$((TAG_REVISION+1))

INCREMENTED_TAG="v"${TAG_MAJOR}.${TAG_MINOR}.${TAG_REVISION}
echo "Git tag will be incremented to: ${INCREMENTED_TAG}"

git add --all
git commit -m "Automatic version bump"

# Check if tag needs to be set at HEAD commit
# If yes, then set it and push the commit and tag
# If no, push only the commit

HEAD_HASH=$(git rev-parse HEAD)
TAG_COMMIT=$(git describe --contains ${HEAD_HASH} || true)

if [ -z "${TAG_COMMIT}" ]; then
  echo "Incrementing tag.."
  git tag ${INCREMENTED_TAG}

  echo "version=${INCREMENTED_TAG}" > config.version

  echo "Executing git push."
  git push --set-upstream origin ${BRANCH}
  git push --set-upstream origin ${INCREMENTED_TAG}
else
  echo "Tag already exists. Executing git push."
  echo "version=${TAG_CURR}" > config.version
  git push --set-upstream origin ${BRANCH}
fi
