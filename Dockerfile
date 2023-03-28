FROM golang:1.16-alpine

WORKDIR /app

COPY src/*.go ./

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
RUN go build -o api main.go && rm -rf main.go

EXPOSE 8080

CMD ["/app/api"]
