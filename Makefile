.DEFAULT_GOAL := help
TASKS := $(sort $(patsubst %/main.tex,%,$(shell \
	find . -maxdepth 2 -type f \
	-regex './Task[0-9]+/main\.tex' \
	| sed 's|^\./||')))

SHELL := /bin/bash
LATEXMK := latexmk
LATEXFLAGS := -pdf -interaction=nonstopmode -halt-on-error

.PHONY: all clean $(TASKS)

all: $(TASKS)

$(TASKS):
	@NUMBER=$$(echo "$@" | sed 's/^Task0*//'); \
	cd "$@" && TEXINPUTS=..: $(LATEXMK) $(LATEXFLAGS) \
		-jobname="Blatt$$NUMBER" \
		-pdflatex="pdflatex %O '\def\SheetNumber{$$NUMBER}\input{%S}'" \
		main.tex

# Remove all generated files, including PDFs
clean:
	@for task in $(TASKS); do \
		number=$$(echo "$$task" | sed 's/^Task0*//'); \
		(cd "$$task" && $(LATEXMK) -C \
			-jobname="Blatt$$number" main.tex); \
	done

.PHONY: new

# Create a new exercise sheet
new:
	@if [ -n "$(NUMBER)" ]; then \
		case "$(NUMBER)" in \
			*[!0-9]*|'') echo "Invalid sheet number"; exit 1 ;; \
		esac; \
		next=$$(printf '%d' "1$(NUMBER)"); \
		next=$$((next - 10 ** $${#NUMBER})); \
	else \
		last=$$(find . -maxdepth 1 -type d -name 'Task[0-9]*' \
			| sed 's|^\./Task||' \
			| grep -E '^[0-9]+$$' \
			| sort -n | tail -1); \
		next=$$(($${last:-0} + 1)); \
	fi; \
	dir=$$(printf "Task%02d" "$$next"); \
	if [ -e "$$dir" ]; then \
		echo "Error: $$dir already exists"; \
		exit 1; \
	fi; \
	mkdir "$$dir"; \
	cp templates/main.tex "$$dir/main.tex"; \
	echo "Created $$dir/main.tex"

.PHONY: list

# List available exercise sheets
list:
	@printf '%s\n' $(TASKS)

.PHONY: release

# Create and push a release tag from main
release:
	@test -n "$(VERSION)" || \
		(echo "Usage: make release VERSION=v1.0.0"; exit 1)
	@[[ "$(VERSION)" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$$ ]] || \
		(echo "Error: Invalid version format"; exit 1)
	@test "$$(git branch --show-current)" = "main" || \
		(echo "Error: Releases must be created from main"; exit 1)
	@git diff --quiet && git diff --cached --quiet || \
		(echo "Error: Uncommitted changes"; exit 1)
	@test -z "$$(git ls-files --others --exclude-standard)" || \
		(echo "Error: Untracked files exist"; exit 1)
	@git fetch origin main
	@test "$$(git rev-parse HEAD)" = "$$(git rev-parse origin/main)" || \
		(echo "Error: Local main differs from origin/main"; exit 1)
	git tag -a "$(VERSION)" -m "Release $(VERSION)"
	git push origin "$(VERSION)"

.PHONY: help

# Display available commands
help:
	@printf "\n"
	@printf "LaTeX Exercise Template\n"
	@printf "=======================\n\n"
	@printf "Usage: make <target> [options]\n\n"
	@printf "Targets:\n"
	@printf "  help              Show this help message\n"
	@printf "  all               Build all exercise sheets\n"
	@printf "  new               Create a new exercise sheet\n"
	@printf "  list              List all exercise sheets\n"
	@printf "  clean             Remove generated files and PDFs\n"
	@printf "  release           Create and push a release tag\n"
	@printf "\n"
	@printf "Options:\n"
	@printf "  NUMBER=N          Set sheet number for 'new'\n"
	@printf "  VERSION=vX.Y.Z    Set release version\n"
	@printf "  -jN               Build up to N sheets in parallel\n"
	@printf "\n"
	@printf "Examples:\n"
	@printf "  make all\n"
	@printf "  make -j4 all\n"
	@printf "  make new\n"
	@printf "  make new NUMBER=5\n"
	@printf "  make list\n"
	@printf "  make clean\n"
	@printf "  make release VERSION=v1.0.0\n"
	@printf "\n"
