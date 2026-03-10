FROM golang:latest AS builder

COPY source /go/src

ENV GOPATH=

WORKDIR /go/src/microservice-framework
RUN go mod init github.com/Dartmouth-OpenAV/microservice-framework
RUN go mod tidy

WORKDIR /go
# Change the module path for each microservice
RUN go mod init github.com/Dartmouth-OpenAV/microservice-pjlink
RUN go mod edit -replace github.com/Dartmouth-OpenAV/microservice-framework=./src/microservice-framework
RUN go mod tidy

WORKDIR /go/src
RUN go get -u
RUN CGO_ENABLED=0 go build -o /go/bin/microservice

FROM alpine:latest
RUN apk add --no-cache tzdata
COPY --from=builder /go/bin/microservice /microservice

# Use this entrypoint for a fully functional docker image
ENTRYPOINT ["/microservice"]
