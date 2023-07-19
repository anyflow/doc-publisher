import argparse
import os

import _markdown
import openapi
from dotenv import load_dotenv

load_dotenv()


def main(args):
    templates_path = os.path.join(os.path.dirname(__file__), "../templates")

    if args.openapi_path:
        openapi.generate(args.openapi_path, templates_path, args.openapi_output_path)

    if args.markdown_path:
        _markdown.generate(args.markdown_path, templates_path, args.markdown_output_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="TCN DOC Publisher")

    parser.add_argument(
        "-io",
        "--openapi_path",
        required=False,
        help="[INPUT] The root path of openapi files",
    )
    parser.add_argument(
        "-im",
        "--markdown_path",
        required=False,
        help="[INPUT] The root path of markdown file",
    )
    parser.add_argument(
        "-oo",
        "--openapi_output_path",
        required=False,
        help="[OUTPUT] The openapi outputs path",
    )
    parser.add_argument(
        "-om",
        "--markdown_output_path",
        required=False,
        help="[OUTPUT] The markdown output path",
    )

    main(parser.parse_args())
