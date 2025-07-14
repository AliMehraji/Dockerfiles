First the user and auth token have reda access to all repos , including python and debian

build args

docker build \
  --secret id=netrc,src=artifactory_credentials \
  -t myimage .

in gitlab-ci use a file variable and do 

- docker build --secret id=netrc,src=$ARTIFACTORY_NETRC -t my-image .
Ensure Using BuildKit
export DOCKER_BUILDKIT=1

gitlab-ci default is buildkit , also docker build is an alias to `docker buildx build` which is buildkit.



bad practice


    echo -e "machine URL \nlogin USER \npassword SECURE-Password" > ~/.netrc
