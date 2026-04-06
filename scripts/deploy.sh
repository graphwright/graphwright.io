#!/bin/bash
# -----------------------------------------------------------------------
# Check out all repos into a flat layout that mirrors the local dev tree:
#   graphwright.io/   identity-server/   kgraph/   medlit/   docs/  ...
# -----------------------------------------------------------------------

# -----------------------------------------------------------------------
# Build docs site (MkDocs + book PDFs)
# -----------------------------------------------------------------------

env >> /etc/environment

git clone https://github.com/graphwright/graphwright.io.git
git clone https://github.com/graphwright/kgraph.git
git clone https://github.com/graphwright/identity-server.git
git clone https://github.com/graphwright/medlit.git
git clone https://github.com/graphwright/docs.git
git clone https://github.com/graphwright/kg-book.git
git clone https://github.com/graphwright/bfs-ql-book.git
git clone https://github.com/graphwright/identity-book.git

(cd /graphwright.io
source $HOME/.local/bin/env
uv sync
uv add mkdocs)

(cd kg-book; make text.pdf || true)

#      - name: Build bfs-ql-book PDF
#        working-directory: bfs-ql-book
#        run: make text.pdf || true
#
#      - name: Build identity-book PDF
#        working-directory: identity-book
#        run: make text.pdf || true
#
#      - name: Collect PDFs
#        run: |
#          mkdir -p graphwright.io/books
#          cp kg-book/text.pdf graphwright.io/books/knowledge-graphs-from-unstructured-text.pdf || true
#          cp bfs-ql-book/text.pdf graphwright.io/books/bfs-ql.pdf || true
#          cp identity-book/text.pdf graphwright.io/books/the-identity-server.pdf || true
#
#      - name: Build docs site
#        working-directory: docs
#        run: |
#          pip install mkdocs mkdocs-material
#          mkdocs build
#
#      - name: Copy docs site into graphwright.io image context
#        run: |
#          cp -r docs/site graphwright.io/site
#          cp -r graphwright.io/books graphwright.io/site/books
#
#      # -----------------------------------------------------------------------
#      # Log in to GitHub Container Registry
#      # -----------------------------------------------------------------------
#      - name: Log in to ghcr.io
#        uses: docker/login-action@v3
#        with:
#          registry: ghcr.io
#          username: ${{ github.actor }}
#          password: ${{ secrets.GITHUB_TOKEN }}
#
#      # -----------------------------------------------------------------------
#      # Build and push all images
#      # -----------------------------------------------------------------------
#      - name: Build and push docs image
#        run: |
#          docker build \
#            -t $REGISTRY/docs:${{ github.sha }} \
#            -t $REGISTRY/docs:latest \
#            graphwright.io/
#          docker push $REGISTRY/docs:${{ github.sha }}
#          docker push $REGISTRY/docs:latest
#
#      - name: Build and push api+mcpserver image
#        run: |
#          docker build \
#            -f kgraph/kgserver/Dockerfile \
#            -t $REGISTRY/kgserver:${{ github.sha }} \
#            -t $REGISTRY/kgserver:latest \
#            kgraph/
#          docker push $REGISTRY/kgserver:${{ github.sha }}
#          docker push $REGISTRY/kgserver:latest
#
#      - name: Build and push gwchat image
#        run: |
#          docker build \
#            --build-arg NEXT_PUBLIC_BASE_PATH=/chat \
#            -t $REGISTRY/gwchat:${{ github.sha }} \
#            -t $REGISTRY/gwchat:latest \
#            kgraph/gwchat/
#          docker push $REGISTRY/gwchat:${{ github.sha }}
#          docker push $REGISTRY/gwchat:latest
#
#      - name: Build and push identity-server image
#        run: |
#          docker build \
#            -t $REGISTRY/identity-server:${{ github.sha }} \
#            -t $REGISTRY/identity-server:latest \
#            identity-server/
#          docker push $REGISTRY/identity-server:${{ github.sha }}
#          docker push $REGISTRY/identity-server:latest
#
#      - name: Build and push medlit-domain image
#        working-directory: ${{ github.workspace }}
#        run: |
#          docker build \
#            -f medlit/Dockerfile.domain-service \
#            -t $REGISTRY/medlit-domain:${{ github.sha }} \
#            -t $REGISTRY/medlit-domain:latest \
#            .
#          docker push $REGISTRY/medlit-domain:${{ github.sha }}
#          docker push $REGISTRY/medlit-domain:latest
#
#      # -----------------------------------------------------------------------
#      # Deploy: copy compose file + config to droplet, pull images, restart stack
#      # -----------------------------------------------------------------------
#      - name: Copy compose file and gwchat config to droplet
#        uses: appleboy/scp-action@v0.1.7
#        with:
#          host: 137.184.49.99
#          username: root
#          key: ${{ secrets.DROPLET_SSH_KEY }}
#          source: "graphwright.io/docker-compose.prod.yml,graphwright.io/gwchat-config"
#          target: /opt/graphwright
#          strip_components: 1
#
#      - name: Deploy to staging droplet
#        uses: appleboy/ssh-action@v1
#        with:
#          host: 137.184.49.99
#          username: root
#          key: ${{ secrets.DROPLET_SSH_KEY }}
#          script: |
#            set -e
#            cd /opt/graphwright
#
#            echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io \
#              --username ${{ github.actor }} \
#              --password-stdin
#
#            REGISTRY=ghcr.io/graphwright docker compose \
#              -f docker-compose.prod.yml \
#              up -d --pull always --remove-orphans
