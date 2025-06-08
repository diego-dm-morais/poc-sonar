export DATABASE_URL := $(shell grep DATABASE_URL pytest.ini | cut -d= -f2 | tr -d ' ')
export POSTGRES_USER := $(shell echo $(DATABASE_URL) | sed -E 's|postgresql://([^:]+):.*|\1|')
export POSTGRES_PASSWORD := $(shell echo $(DATABASE_URL) | sed -E 's|postgresql://[^:]+:([^@]+)@.*|\1|')
export POSTGRES_DB := $(shell echo $(DATABASE_URL) | sed -E 's|.*/([^/?]+).*|\1|')
export SONAR_TOKEN ?= $(shell grep SONAR_TOKEN pytest.ini | cut -d= -f2 | tr -d ' ')

export VIRTUALENV := $(PWD)/.venv

.venv:
	python3.11 -m venv $(VIRTUALENV)
	$(VIRTUALENV)/bin/pip install --upgrade pip

clean:
	@rm -rf .pytest_cache .coverage coverage.xml .scannerwork poc_sonar.egg-info htmlcov
	@find . -type d -name "__pycache__" -exec rm -rf {} +
	@find . -type f -name "*.pyc" -delete
	
install: .venv
	$(VIRTUALENV)/bin/pip install -r requirements.txt

install-dev: .venv install
	$(VIRTUALENV)/bin/pip install -r requirements-dev.txt -v --progress-bar=off

db-down:
	@docker rm -f postgres_test || true


db-up: db-down
	@docker run -d \
		--name postgres_test \
		-e POSTGRES_USER=$(POSTGRES_USER) \
		-e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		-e POSTGRES_DB=$(POSTGRES_DB) \
		-p 5432:5432 \
		postgres:13
	@until docker exec postgres_test pg_isready -U $(POSTGRES_USER) > /dev/null 2>&1; do \
		sleep 1; \
	done

test: clean db-up
	@pytest -v
	${MAKE} db-down

coverage: clean db-up
	@pytest \
	--cov=app \
	--cov-report=xml \
	--cov-report=term \
	--cov-report=html \
	--cov-config=.coveragerc
	${MAKE} db-down

open-coverage:
	@command -v xdg-open >/dev/null 2>&1 || { \
		sudo apt update && sudo apt install -y xdg-utils; \
	}
	@xdg-open htmlcov/index.html > /dev/null 2>&1 &

# sonar: coverage
# 	@sonar-scanner \
# 		-Dsonar.projectKey=poc-sonar \
# 		-Dsonar.verbose=true \
# 		-Dsonar.host.url=http://localhost:9000 \
# 		-Dsonar.login=$(SONAR_TOKEN)


sonar: coverage
	@echo "$(PWD)"
	@docker run --rm -it \
		-v $(PWD):/usr/src \
		-w /usr/src \
		--add-host=host.docker.internal:host-gateway \
		-e SONAR_HOST_URL="http://host.docker.internal:9000" \
		-e SONAR_TOKEN="$(SONAR_TOKEN)" \
		sonarsource/sonar-scanner-cli \
		sh -c "sed -i 's|<source>.*</source>|<source>app</source>|g' coverage.xml && sonar-scanner -Dsonar.verbose=true -Dsonar.scm.disabled=true"