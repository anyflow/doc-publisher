import os

import markdown2


def generate(markdown_path: str, template_path: str, output_path: str):
    with open(markdown_path, "r") as f:
        markdown = f.read()

    html = markdown2.markdown(markdown, extras=["tables"])

    with open(template_path, "r") as f:
        template = f.read()

    html = template.replace(
        '<article class="markdown-body">', f'<article class="markdown-body">{html}'
    )

    with open(
        os.path.join(output_path, os.path.splitext(os.path.basename(markdown_path))[0], "html"),
        "w",
    ) as f:
        f.write(html)
