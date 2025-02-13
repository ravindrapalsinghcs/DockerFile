FROM php:8.1-buster
# Set working directory
WORKDIR /usr/local/google/home/sravindrapal/docker-cli

# Install required PHP extensions
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    git \
    libz-dev \
    libssl-dev \
     vim \
    libprotobuf-dev \
    protobuf-compiler \
   cmake \
    build-essential \
    autoconf \
    libtool \
    pkg-config \ 
    && rm -rf /var/lib/apt/lists/*

# Install gRPC via PECL
RUN pecl install grpc && docker-php-ext-enable grpc

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# Copy PHP gRPC client files (assuming `php-client/` contains your client code)
RUN git clone --recurse-submodules -b v1.66.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc /usr/local/grpc
WORKDIR /usr/local/grpc

# Build protoc and grpc_php_plugin
RUN mkdir -p /usr/local/grpc/build && \
    cd /usr/local/grpc/build && \
    cmake .. && \
    make protoc grpc_php_plugin && \
    find . -name protoc -exec cp {} /usr/local/bin/ \; && \
    find . -name grpc_php_plugin -exec cp {} /usr/local/bin/ \;

# Clone grpc-go repository (Go implementation of gRPC)

# Replace the incorrect protoc path in greeter_proto_gen.sh
RUN sed -i 's|bazel-bin/external/com_google_protobuf/protoc|/usr/local/bin/protoc|' /usr/local/grpc/examples/php/greeter_proto_gen.sh
RUN sed -i 's|bazel-bin/src/compiler/grpc_php_plugin|/usr/local/bin/grpc_php_plugin|' /usr/local/grpc/examples/php/greeter_proto_gen.sh
# Set permissions for the script
RUN chmod +x /usr/local/grpc/examples/php/greeter_proto_gen.sh


WORKDIR /usr/local/grpc/examples/php
#COPY php-client /usr/local/google/home/sravindrapal/docker-cli

# Install PHP dependencies
RUN composer install --no-dev --prefer-dist

# Expose gRPC server port
EXPOSE 50051

# Install Composer
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#CMD ["/bin/bash"]
CMD ["/usr/local/grpc/examples/php/greeter_proto_gen.sh"]
