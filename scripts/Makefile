BASE=/home/wware/graphwright
MKDOCS=$(BASE)/docs/.venv/bin/mkdocs
MKDOCS_YML := $(BASE)/docs/mkdocs.yml
# If .mkdocs only depended on .apt, Make would never rerun mkdocs after the first build.
DOCS_SOURCES := $(shell find $(BASE)/docs/docs -type f 2>/dev/null)

.all: .apt .mkdocs .pdf .books .site
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

.mkdocs: .apt $(MKDOCS_YML) $(DOCS_SOURCES)
	(cd $(BASE)/docs && uv add mkdocs mkdocs-material mkdocs-pdf-export-plugin)
	(cd $(BASE)/docs && $(MKDOCS) build)
	touch .mkdocs

# Book PDFs do not depend on MkDocs; keep doc edits from re-running LaTeX every time.
.pdf: .apt
	(cd $(BASE)/kg-book && make text.pdf)
	(cd $(BASE)/bfs-ql-book && make bfsql.pdf)
	(cd $(BASE)/identity-book && make text.pdf)
	touch .pdf

.books: .pdf
	mkdir -p $(BASE)/graphwright.io/books
	cp $(BASE)/kg-book/text.pdf $(BASE)/graphwright.io/books/knowledge-graphs-from-unstructured-text.pdf
	cp $(BASE)/bfs-ql-book/bfsql.pdf $(BASE)/graphwright.io/books/bfs-ql.pdf
	cp $(BASE)/identity-book/text.pdf $(BASE)/graphwright.io/books/the-identity-server.pdf
	touch .books

# Needs both: static HTML from MkDocs and PDFs copied into site/books.
#
# Do NOT use `cp -r docs/site graphwright.io/site` when graphwright.io/site already
# exists — GNU cp nests into site/site/ and leaves stale index.html at the top level.
.site: .mkdocs .books
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
	rm -f .site .all .books .pdf .mkdocs
	(cd $(BASE)/docs && rm -rf site)
	(cd $(BASE)/kg-book && rm -f text.pdf)
	(cd $(BASE)/bfs-ql-book && rm -f bfsql.pdf)
	(cd $(BASE)/identity-book && rm -f text.pdf)
	(cd $(BASE)/graphwright.io && rm -rf books)

