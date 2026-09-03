M2_LOCAL := file://$(HOME)/.m2/repository
MAVEN_CENTRAL := https://repo.maven.apache.org/maven2
export SMITHY_MAVEN_REPOS := $(M2_LOCAL)|$(MAVEN_CENTRAL)

SMITHY_BEAM_SRC ?= $(CURDIR)/.smithy-beam
SMITHY_BEAM_REPO ?= https://github.com/f34nk/smithy-beam.git
SMITHY_BEAM_REF ?= v3
CODEGEN_JAR := $(HOME)/.m2/repository/io/smithy/beam/codegen-elixir/0.1.0-SNAPSHOT/codegen-elixir-0.1.0-SNAPSHOT.jar
CODEGEN_DIR := generated/source/elixir-client-codegen
OPENRIAK_CODEGEN_JAR := $(HOME)/.m2/repository/openriak/openriak-elixir-codegen/0.1.0/openriak-elixir-codegen-0.1.0.jar
OPENRIAK_CODEGEN_SRCS := $(shell find codegen/src codegen/pom.xml -type f 2>/dev/null)

JDK21 := $(shell asdf where java openjdk-21 2>/dev/null)

.PHONY: all
all: build

.PHONY: install-codegen
install-codegen: $(CODEGEN_JAR)

$(CODEGEN_JAR):
	@test -d "$(SMITHY_BEAM_SRC)" || { \
		echo "Cloning smithy-beam ($(SMITHY_BEAM_REF))..."; \
		git clone --depth 1 --branch "$(SMITHY_BEAM_REF)" "$(SMITHY_BEAM_REPO)" "$(SMITHY_BEAM_SRC)"; \
	}
	cd "$(SMITHY_BEAM_SRC)" && make build

.PHONY: install-openriak-codegen
install-openriak-codegen: $(OPENRIAK_CODEGEN_JAR)

$(OPENRIAK_CODEGEN_JAR): $(OPENRIAK_CODEGEN_SRCS)
	cd codegen && JAVA_HOME="$(JDK21)" mvn -q install

.PHONY: build/smithy
build/smithy: install-codegen install-openriak-codegen
	smithy build 2>build-errors.log || (cat build-errors.log; exit 1)
	rm -f build-errors.log

.PHONY: build/mix
build/mix: build/smithy
	mix deps.get
	mix compile

.PHONY: build
build: build/mix

.PHONY: test
test: build/mix
	MIX_ENV=test mix test --no-start

.PHONY: demo
demo: build
	mix run --no-start

.PHONY: clean
clean:
	rm -rf _build generated deps .smithy-beam *.dump build-errors.log $(OPENRIAK_CODEGEN_JAR)
