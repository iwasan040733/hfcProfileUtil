docker rm -f $(docker ps -aq)
docker rmi -f $(docker images | grep dev | awk '{print $3}')
rm -rf fabric-client-kv-org[1-2]
rm -rf /tmp/fabric-client-kv-org[1-2]
rm -rf channel-artifacts/*
rm -rf crypto-config/*
