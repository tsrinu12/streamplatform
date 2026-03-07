FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o notification-service ./cmd/server

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

RUN addgroup -g 1001 -S appuser && adduser -S appuser -u 1001

COPY --from=builder --chown=appuser:appuser /app/notification-service .

USER appuser

EXPOSE 8004

CMD ["./notification-service"]
