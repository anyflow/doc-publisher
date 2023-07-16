import argparse
import os

import _markdown
import openapi


def main(args):
    template_path = os.path.join(os.path.dirname(__file__), "../template")

    openapi.generate(args.openapi_path, template_path, args.output_path)
    _markdown.generate(args.markdown_path, template_path, args.output_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="TCN DOC Publisher")

    parser.add_argument(
        "-io",
        "--openapi_path",
        required=True,
        help="[INPUT] The root path of openapi files",
    )
    parser.add_argument(
        "-io",
        "--markdown_path",
        required=True,
        help="[INPUT] The root path of markdown file",
    )
    parser.add_argument(
        "-o",
        "--output_path",
        required=True,
        help="[OUTPUT] The output root path",
    )

    main(parser.parse_args())
