cat cpp.Dockerfile 
# Use FreeBSD 12.3 as the base image
FROM ubuntu:22.04  

# Install required dependencies
RUN apt update && apt install -y \
    cmake \
    ninja-build \
    clang \
    git \
    autoconf \
    automake \
    libtool \
    pkg-config \
    protobuf-compiler \
    libprotobuf-dev \
    g++ \
    make
# Set working directory for gRPC repository
WORKDIR /usr/local/google/home/sravindrapal/docker-cli

# Clone gRPC repository with submodules
RUN git clone --recurse-submodules -b v1.66.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc
WORKDIR /usr/local/google/home/sravindrapal/docker-cli/grpc
RUN mkdir -p cmake/build && cd cmake/build && \
    cmake ../.. && make -j4 && make install

# Set working directory for gRPC HelloWorld example
WORKDIR /usr/local/google/home/sravindrapal/docker-cli/grpc/examples/cpp/helloworld

# Build the HelloWorld example using cmake
RUN mkdir -p cmake/build && \
    cd cmake/build && \
    cmake -DCMAKE_PREFIX_PATH=$MY_INSTALL_DIR ../.. && \
    make -j 4

# Set the entry point to run the HelloWorld server
CMD ["./cmake/build/greeter_client"]

