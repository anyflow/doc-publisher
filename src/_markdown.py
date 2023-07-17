import json
import os

import requests


def generate(markdown_path: str, templates_path: str, output_path: str):
    with open(markdown_path, "r") as f:
        markdown = f.read()

    response = requests.post(
        "https://api.github.com/markdown",
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": "Bearer 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",
            "X-GitHub-Api-Version": "2022-11-28",
        },
        data=json.dumps({"text": markdown}).encode("utf-8"),
    )

    with open(os.path.join(templates_path, 'github/markdown.html'), "r") as f:
        template = f.read()

    html = template.replace(
        '<article class="markdown-body">',
        f'<article class="markdown-body">{response.text}',
    )

    with open(
        f"{os.path.join(output_path, os.path.splitext(os.path.basename(markdown_path))[0])}.html",
        "w",
    ) as f:
        f.write(html)
