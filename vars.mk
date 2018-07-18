PKG_NAME := github.com/docker/app
BIN_NAME ?= docker-app
E2E_NAME := $(BIN_NAME)-e2e

# Enable experimental features. "on" or "off"
EXPERIMENTAL := off

# Failing to resolve sh.exe to a full path denotes a windows vanilla shell.
# Although 'simple' commands are still exec'ed, 'complex' ones are batch'ed instead of sh'ed.
ifeq ($(SHELL),sh.exe)
  mkdir = mkdir $(subst /,\,$(1)) > nul 2>&1 || (exit 0)
  rm = del /F /Q $(subst /,\,$(1)) > nul 2>&1 || (exit 0)
  rmdir = rmdir /S /Q $(subst /,\,$(1)) > nul 2>&1 || (exit 0)
  chmod =
  BUILDTIME ?= unknown
  NULL := nul
else
  # The no-op redirection forces make to shell out the commands instead of spawning a process as
  # the latter can fail on windows running cmd or powershell while having a unix style shell in the path.
  mkdir = mkdir -p $(1) 1>&1
  rm = rm -rf $(1) 1>&1
  rmdir = rm -rf $(1) 1>&1
  chmod = chmod $(1) $(2) 1>&1
  NULL := /dev/null
endif

ifeq ($(TAG),)
  TAG := $(shell git describe --always --dirty 2> $(NULL))
endif
ifeq ($(COMMIT),)
  COMMIT := $(shell git rev-parse --short HEAD 2> $(NULL))
endif

ifeq ($(BUILDTIME),)
  BUILDTIME := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ" 2> /dev/null)
endif
ifeq ($(BUILDTIME),)
  BUILDTIME := unknown
  $(warning unable to set BUILDTIME. Set the value manually)
endif

BUILDTAGS=""
ifeq ($(EXPERIMENTAL),on)
  BUILDTAGS="experimental"
endif

LDFLAGS := "-s -w \
  -X $(PKG_NAME)/internal.GitCommit=$(COMMIT) \
  -X $(PKG_NAME)/internal.Version=$(TAG)      \
  -X $(PKG_NAME)/internal.Experimental=$(EXPERIMENTAL) \
  -X $(PKG_NAME)/internal.BuildTime=$(BUILDTIME)"

EXEC_EXT :=
ifeq ($(OS),Windows_NT)
  EXEC_EXT := .exe
endif
