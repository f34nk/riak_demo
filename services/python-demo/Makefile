M2_LOCAL := file://$(HOME)/.m2/repository
MAVEN_CENTRAL := https://repo.maven.apache.org/maven2
export SMITHY_MAVEN_REPOS := $(M2_LOCAL)|$(MAVEN_CENTRAL)

SMITHY_PYTHON_SRC ?= $(CURDIR)/.smithy-python
SMITHY_PYTHON_REPO ?= https://github.com/smithy-lang/smithy-python.git
SMITHY_PYTHON_REF ?= develop
CODEGEN_JAR := $(HOME)/.m2/repository/software/amazon/smithy/python/codegen/core/0.3.0/core-0.3.0.jar

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

.PHONY: build
build: install-codegen
	#
	# Build
	#
	smithy build

.PHONY: demo
demo: build

.PHONY: test
test:
	@echo "No tests yet"

.PHONY: clean
clean:
	#
	# Clean
	#
	rm -rf build generated $(CODEGEN_JAR)
