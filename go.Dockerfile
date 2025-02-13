# Base image with Golang
FROM golang:1.22 AS builder

# Set working directory for building the gRPC server
WORKDIR /usr/local/google/home/sravindrapal/docker-cli

# Copy Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod tidy 

# Copy the source code and build the gRPC server
COPY . .
RUN go build -o grpc_server

# Use a minimal base image for deployment
FROM golang:1.22 AS final

# Set working directory
WORKDIR /usr/local

# Clone grpc-go repository
RUN git clone https://github.com/grpc/grpc-go.git --branch v1.70.0 --depth 1

# Install Go dependencies for grpc-go
WORKDIR /usr/local/grpc-go
RUN go mod tidy

# Set working directory for running gRPC server
WORKDIR /usr/local/grpc-go/examples/helloworld/greeter_server

# Expose gRPC server port
EXPOSE 50051

# Run the gRPC server from the correct directory
CMD ["go", "run", "."]
