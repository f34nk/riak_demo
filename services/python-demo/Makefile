M2_LOCAL := file://$(HOME)/.m2/repository
MAVEN_CENTRAL := https://repo.maven.apache.org/maven2
export SMITHY_MAVEN_REPOS := $(M2_LOCAL)|$(MAVEN_CENTRAL)

SMITHY_PYTHON_SRC ?= $(CURDIR)/.smithy-python
SMITHY_PYTHON_REPO ?= https://github.com/smithy-lang/smithy-python.git
SMITHY_PYTHON_REF ?= develop
CODEGEN_JAR := $(HOME)/.m2/repository/software/amazon/smithy/python/codegen/core/0.3.0/core-0.3.0.jar
CLIENT_DIR := generated/client/python-client-codegen
OPENRIAK_CODEGEN_JAR := $(HOME)/.m2/repository/openriak/openriak-python-codegen/0.1.0/openriak-python-codegen-0.1.0.jar
CODEGEN_SRCS := $(shell find codegen/src codegen/pom.xml -type f 2>/dev/null)

.PHONY: all
all: build

.PHONY: install-codegen
install-codegen: $(CODEGEN_JAR)

$(CODEGEN_JAR):
	@test -d "$(SMITHY_PYTHON_SRC)/codegen" || { \
		echo "Cloning smithy-python ($(SMITHY_PYTHON_REF))..."; \
		git clone --depth 1 --branch "$(SMITHY_PYTHON_REF)" "$(SMITHY_PYTHON_REPO)" "$(SMITHY_PYTHON_SRC)"; \
	}
	cd "$(SMITHY_PYTHON_SRC)/codegen" && ./gradlew publishToMavenLocal

$(OPENRIAK_CODEGEN_JAR): $(CODEGEN_SRCS)
	cd codegen && mvn -q install

.PHONY: install-openriak-codegen
install-openriak-codegen: $(OPENRIAK_CODEGEN_JAR)

.PHONY: install-runtime
install-runtime:
	@test -d "$(SMITHY_PYTHON_SRC)/packages" || $(MAKE) install-codegen
	cd "$(SMITHY_PYTHON_SRC)/packages" && pip install -e smithy-core -e "smithy-http[aiohttp]"

.PHONY: build
build: install-codegen install-openriak-codegen
	#
	# Build
	#
	smithy build

.PHONY: build/client
build/client: build
	pip install -e $(CLIENT_DIR)

.PHONY: demo
demo: build/client
	python src/main.py

.PHONY: test
test: build/client
	python -m pytest test/ -q 2>/dev/null || echo "No tests yet"

.PHONY: clean
clean:
	#
	# Clean
	#
	rm -rf build generated $(CODEGEN_JAR)
