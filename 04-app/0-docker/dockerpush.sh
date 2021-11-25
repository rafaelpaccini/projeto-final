cd spring-web-youtube
tag=$(git describe --tags $(git rev-list --tags --max-count=1))
docker tag projetofinal/spring-web-youtube:$tag hub.docker.com/r/projetofinal/spring-web-youtube:$tag
docker push projetofinal/spring-web-youtube:$tag