docker build --no-cache -t project .
# docker build -t project .

docker rm -f project 2>/dev/null; docker run --privileged -it --rm --name project project
