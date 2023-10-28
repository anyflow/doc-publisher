import os
import shutil

import yaml

DEFAULT_ENVIRONMENT = os.getenv("DEFAULT_ENVIRONMENT")


def generate(openapi_path: str, template_path: str, output_path: str):
    openapi_dir = os.path.join(openapi_path, DEFAULT_ENVIRONMENT)

    def app_title(openapi_file: str):
        app = app if (app := openapi_file.split(".")[0]) != "openapi" else ""

        openapi = __load_yaml(os.path.join(openapi_dir, openapi_file))

        return app, openapi["info"]["title"]

    app_titles = {app_title(openapi_file) for openapi_file in os.listdir(openapi_dir)}

    for media_type in ["swaggerui", "redoc"]:
        destination_path = f"{output_path}/{media_type}"
        os.mkdir(destination_path)

        for app, title in app_titles:
            __generate(media_type, template_path, destination_path, app, title)


def __load_yaml(file_path: str) -> dict:
    with open(file_path) as f:
        try:
            return yaml.safe_load(f)
        except yaml.YAMLError as error:
            print(f"Error while parsing YAML file: {error}")
            exit(1)


def __generate(media_type: str, template_path: str, output_path: str, app: str, title: str):
    template_path = os.path.join(template_path, media_type)
    output_path = os.path.join(output_path, app)

    if not os.path.exists(output_path):
        os.mkdir(output_path)

    def replace(file_path, target, content):
        with open(file_path, "r") as f:
            contents = f.read().replace(target, content)

        with open(file_path, "w") as f:
            f.write(contents)

    def generate_and_replace(filename):
        shutil.copy(
            os.path.join(template_path, filename),
            (copied := os.path.join(output_path, filename)),
        )

        if filename == "swagger-initializer.js":
            replace(
                copied,
                "##OPENAPI_FILE_PATH_EXPOSED##",
                f"/__openapi/{app + '.' if app else ''}openapi.yaml",
            )

        elif filename == "index.html":
            replace(copied, "##TITLE##", title)

            if media_type == "redoc":
                replace(
                    copied,
                    "##OPENAPI_FILE_PATH_EXPOSED##",
                    f"/__openapi/{app + '.' if app else ''}openapi.yaml",
                )

    for file in os.listdir(template_path):
        generate_and_replace(file)
