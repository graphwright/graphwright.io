FROM ubuntu:latest
RUN apt update -qq
RUN apt install -y --no-install-recommends \
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

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN ln -s /root/.local/bin/uv /usr/bin
COPY deploy.sh /deploy.sh
# RUN bash -xe /deploy.sh
