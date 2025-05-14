docker build --no-cache -t rita .
# docker build -t rita .

docker rm -f rita 2>/dev/null; docker run --privileged -v ./pcap_files:/opt/rita/pcap_files -it --rm --name rita rita
