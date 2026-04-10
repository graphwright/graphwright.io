IDENTITY_BOOK_BUNDLE_URL := $(shell curl -sf https://api.github.com/repos/graphwright/identity-book/releases/latest \
	| python3 -c "import sys,json; r=json.load(sys.stdin); print(r['assets'][0]['browser_download_url'])" \
	2>/dev/null)

BASE=/home/wware/graphwright
MKDOCS=$(BASE)/docs/.venv/bin/mkdocs
MKDOCS_YML := $(BASE)/docs/mkdocs.yml
# If .mkdocs only depended on .apt, Make would never rerun mkdocs after the first build.
DOCS_SOURCES := $(shell find $(BASE)/docs/docs -type f 2>/dev/null)

.all: .apt .mkdocs .books .site
	touch .all

.apt:
	apt update -qq
	apt install -y --no-install-recommends \
		pandoc \
		texlive-xetex \
		texlive-fonts-recommended \
		texlive-fonts-extra \
		texlive-latex-extra \
		texlive-bibtex-extra \
		biber \
		make \
		inkscape \
		docker.io \
		docker-compose-v2 \
		ripgrep vim git curl
	touch .apt

# identity-book must run before mkdocs so its docs/ content is present for the build.
.mkdocs: .apt .identity-book $(MKDOCS_YML) $(DOCS_SOURCES)
	(cd $(BASE)/docs && uv add mkdocs mkdocs-material mkdocs-pdf-export-plugin)
	(cd $(BASE)/docs && $(MKDOCS) build)
	touch .mkdocs

# Book PDFs do not depend on MkDocs; keep doc edits from re-running LaTeX every time.
.pdf: .apt
	(cd $(BASE)/kg-book && make text.pdf)
	(cd $(BASE)/bfs-ql-book && make bfsql.pdf)
	touch .pdf

# Download the identity-book release bundle; extract PDF and mkdocs-ready docs/.
.identity-book: .apt
	mkdir -p /tmp/identity-book-bundle
	@test -n "$(IDENTITY_BOOK_BUNDLE_URL)" || (echo "ERROR: failed to resolve identity-book release URL" >&2; exit 1)
	curl -fsSL "$(IDENTITY_BOOK_BUNDLE_URL)" | tar -xz -C /tmp/identity-book-bundle
	mkdir -p $(BASE)/graphwright.io/books
	cp /tmp/identity-book-bundle/text.pdf $(BASE)/graphwright.io/books/the-identity-server.pdf
	mkdir -p $(BASE)/docs/docs/identity-book
	cp -r /tmp/identity-book-bundle/docs/. $(BASE)/docs/docs/identity-book/
	python3 $(BASE)/graphwright.io/scripts/inject_identity_book_nav.py \
		/tmp/identity-book-bundle/mkdocs.yml \
		$(BASE)/docs/mkdocs.yml
	python3 $(BASE)/graphwright.io/scripts/update_books_links.py \
		$(BASE)/docs/docs/books.md
	touch .identity-book

.books: .pdf
	mkdir -p $(BASE)/graphwright.io/books
	cp $(BASE)/kg-book/text.pdf $(BASE)/graphwright.io/books/knowledge-graphs-from-unstructured-text.pdf
	cp $(BASE)/bfs-ql-book/bfsql.pdf $(BASE)/graphwright.io/books/bfs-ql.pdf
	touch .books

# Needs both: static HTML from MkDocs and PDFs copied into site/books.
#
# Do NOT use `cp -r docs/site graphwright.io/site` when graphwright.io/site already
# exists — GNU cp nests into site/site/ and leaves stale index.html at the top level.
.site: .mkdocs .books .identity-book
	rm -rf $(BASE)/graphwright.io/site
	mkdir -p $(BASE)/graphwright.io/site
	cp -a $(BASE)/docs/site/. $(BASE)/graphwright.io/site/
	mkdir -p $(BASE)/graphwright.io/site/books
	cp -a $(BASE)/graphwright.io/books/. $(BASE)/graphwright.io/site/books/
	date -u +%Y-%m-%dT%H:%M:%SZ > $(BASE)/graphwright.io/site/build-stamp.txt
	touch .site

# After changing kgraph for medlit-domain, rebuild without cache so COPY picks up new files.
gw-medlit-domain-rebuild:
	cd $(BASE)/graphwright.io && docker compose build --no-cache medlit-domain

clean:
	rm -f .site .all .books .pdf .mkdocs .identity-book
	(cd $(BASE)/docs && rm -rf site docs/identity-book)
	(cd $(BASE)/kg-book && rm -f text.pdf)
	(cd $(BASE)/bfs-ql-book && rm -f bfsql.pdf)
	(cd $(BASE)/graphwright.io && rm -rf books)

