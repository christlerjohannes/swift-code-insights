import redis, os, subprocess
from flask import Flask, request, Response
from dotenv import load_dotenv

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Works.'

@app.route('/webhook', methods=['POST'])
def respond():
    project = request.json['repository']['slug']
    commit = request.json['changes'][0]['toHash']
    subprocess.run(['sh', "run_insights.sh", os.getenv("BB_TOKEN"), os.getenv("BB_BASE_URL"), os.getenv("BB_PROJECT"), os.getenv("BB_REPORT_SLUG"), project, commit])
    return Response(status=200)
