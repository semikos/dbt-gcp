import logging
import os
import subprocess

import google.cloud.logging
from flask import Flask, request

app = Flask(__name__)


# Execute a dbt command
@app.route("/dbt", methods=["POST"])
def run():
    client = google.cloud.logging.Client()

    # Connects the logger to the root logging handler; by default this captures
    # all logs at INFO level and higher
    client.setup_logging()
    logging.info("Started processing request on endpoint {}".format(
        request.base_url))
    command = ["dbt"]
    arguments = []
    # Parse the request data
    request_data = request.get_json()
    logging.info("Request data: {}".format(request_data))

    if request_data:
        if "cli" in request_data.get("params", {}):
            arguments = request_data["params"]["cli"].split(" ")
            command.extend(arguments)
    # Add an argument for the project dir if not specified
    if not any("--project-dir" in c for c in command):
        project_dir = os.environ.get("DBT_PROJECT_DIR", None)
        if project_dir:
            command.extend(["--project-dir", project_dir])
    if not any("--profiles-dir" in c for c in command):
        profile_dir = os.environ.get("DBT_PROFILES_DIR", None)
        if profile_dir:
            command.extend(["--profiles-dir", profile_dir])

    # Execute the dbt command
    result = subprocess.run(command,
                            text=True,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT)
    # Format the response
    response = {
        "result": {
            "status": "ok" if result.returncode == 0 else "error",
            "args": result.args,
            "return_code": result.returncode,
            "command_output": result.stdout,
        }
    }
    logging.info("Command output: {}".format(
        response["result"]["command_output"]))
    logging.info("Command status: {}".format(response["result"]["status"]))
    logging.info("Finished processing request on endpoint {}".format(
        request.base_url))
    return response, 200


@app.route("/")
def main_route():
    return "The app is working.This is the main route of the app"


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
