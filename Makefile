.PHONY: demo
demo:
	docker compose up --build

.PHONY: stop
stop:
	docker compose down

.PHONY: clean
clean:
	docker compose down -v --rmi local
