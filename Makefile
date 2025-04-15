# Binaries
APP_BIN = .build/release/stripper

# Directories
QUERY_DIR = $(HOME)/.stripper/queries
SWIFT_QUERY_DIR = $(QUERY_DIR)/swift
C_QUERY_DIR = $(QUERY_DIR)/c
CPP_QUERY_DIR = $(QUERY_DIR)/cpp
JS_QUERY_DIR = $(QUERY_DIR)/javascript
TS_QUERY_DIR = $(QUERY_DIR)/typescript
PYTHON_QUERY_DIR = $(QUERY_DIR)/python
RUBY_QUERY_DIR = $(QUERY_DIR)/ruby
GO_QUERY_DIR = $(QUERY_DIR)/go
RUST_QUERY_DIR = $(QUERY_DIR)/rust

# Targets
.PHONY: all build run clean install setup-queries test clean-queries reset-queries

all: build

build:
	swift build -c release

setup-queries:
	mkdir -p $(SWIFT_QUERY_DIR) $(C_QUERY_DIR) $(CPP_QUERY_DIR) $(JS_QUERY_DIR) $(TS_QUERY_DIR) $(PYTHON_QUERY_DIR) $(RUBY_QUERY_DIR) $(GO_QUERY_DIR) $(RUST_QUERY_DIR)
	@echo "Creating basic query files for Tree-Sitter..."
	@echo "(comment) @comment" > $(SWIFT_QUERY_DIR)/highlights.scm
	@echo "(comment) @comment" > $(C_QUERY_DIR)/highlights.scm
	@echo "(comment) @comment" > $(CPP_QUERY_DIR)/highlights.scm
	@echo "(comment) @comment" > $(JS_QUERY_DIR)/highlights.scm
	@echo "(comment) @comment" > $(TS_QUERY_DIR)/highlights.scm
	@echo "(comment) @comment" > $(PYTHON_QUERY_DIR)/highlights.scm
	@echo "(comment) @comment" > $(RUBY_QUERY_DIR)/highlights.scm
	@echo "(comment) @comment" > $(GO_QUERY_DIR)/highlights.scm
	@echo "(comment) @comment" > $(RUST_QUERY_DIR)/highlights.scm
	@echo "✅ Query files created at $(QUERY_DIR)"

clean-queries:
	rm -rf $(QUERY_DIR)
	@echo "🧹 Removed query files directory at $(QUERY_DIR)"

reset-queries: clean-queries
	@echo "🔄 Recreating query files..."
	@$(MAKE) setup-queries

run: build
	$(APP_BIN) --help

install: build
	cp $(APP_BIN) /usr/local/bin/stripper
	chmod +x /usr/local/bin/stripper
	@echo "✅ Installed stripper to /usr/local/bin/stripper"
	@$(MAKE) setup-queries
	@echo "✅ Query files installed at $(QUERY_DIR)"

clean:
	swift package clean
	@echo "🧹 Cleaned build artifacts."

test: build
	@echo "Running tests..."
	swift test
