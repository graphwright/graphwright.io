#!/usr/bin/env python3
"""Update books.md to replace the identity-book PDF links with HTML section links.

Usage: update_books_links.py <books.md>

Rewrites the file in place.
"""

import sys

REPLACEMENTS = [
    (
        "## [The Identity Server: Canonical Identity for Knowledge Graphs]"
        "(../books/the-identity-server.pdf)",
        "## [The Identity Server: Canonical Identity for Knowledge Graphs]"
        "(identity-book/)",
    ),
    (
        "[Download PDF](../books/the-identity-server.pdf)",
        "[Read online](identity-book/)",
    ),
]


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <books.md>", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    with open(path) as f:
        content = f.read()
    for old, new in REPLACEMENTS:
        content = content.replace(old, new)
    with open(path, "w") as f:
        f.write(content)


if __name__ == "__main__":
    main()
