.PHONY: help build up down logs clean install test lint fmt

help:
	@echo "StreamPlatform - Development Commands"
	@echo "====================================="
	@echo "make install      - Install dependencies"
	@echo "make up           - Start all services with Docker Compose"
	@echo "make down         - Stop all services"
	@echo "make logs         - Show logs from all services"
	@echo "make logs-service - Show logs from specific service"
	@echo "make build        - Build all services"
	@echo "make test         - Run tests"
	@echo "make lint         - Run linting"
	@echo "make fmt          - Format code"
	@echo "make clean        - Clean up all containers and volumes"
	@echo "make db-migrate   - Run database migrations"
	@echo "make seed         - Seed database with sample data"

install:
	@echo "Installing dependencies..."
	cd frontend && npm install
	cd ../backend && npm install

up:
	@echo "Starting all services..."
	docker-compose up -d
	@echo "Services are running! Access:"
	@echo "Frontend: http://localhost:3000"
	@echo "API: http://localhost:3001"
	@echo "Grafana: http://localhost:3000"

down:
	@echo "Stopping all services..."
	docker-compose down

logs:
	docker-compose logs -f

logs-service:
	@echo "Specify service name: make logs-service SERVICE=<service>"
	docker-compose logs -f $(SERVICE)

build:
	@echo "Building all services..."
	docker-compose build

test:
	@echo "Running tests..."
	cd frontend && npm test
	cd ../backend && npm test

lint:
	@echo "Running linter..."
	cd frontend && npm run lint
	cd ../backend && npm run lint

fmt:
	@echo "Formatting code..."
	cd frontend && npm run format
	cd ../backend && npm run format

clean:
	@echo "Cleaning up..."
	docker-compose down -v
	find . -name 'node_modules' -type d -exec rm -rf {} + 2>/dev/null || true

db-migrate:
	@echo "Running database migrations..."
	docker-compose exec postgres psql -U streamuser -d streamdb -a -f /migrations/001_init.sql

seed:
	@echo "Seeding database..."
	docker-compose exec postgres psql -U streamuser -d streamdb -a -f /seeds/initial_data.sql
