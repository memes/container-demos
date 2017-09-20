# Build final services in a container to get around problems with GOOS
# and GOARCH setting in Makefile.
#
FROM golang:1.9-alpine as builder
RUN apk add --no-cache make git protobuf musl-dev gcc && \
    go get -u github.com/golang/dep/cmd/dep
ARG BUST_A_CACHE=1
RUN echo Busting caches since $BUST_A_CACHE
WORKDIR /go
COPY src/ src/
COPY Makefile .
RUN make clean build

FROM alpine:3.6
MAINTAINER Matthew Emes "matthew.emes@neudesic.com"
COPY --from=builder /go/bin/pi /usr/local/bin/
EXPOSE 8080
RUN chmod 0755 /usr/local/bin/pi
USER nobody
ENTRYPOINT [ "/usr/local/bin/pi" ]
CMD [ "server" ]
