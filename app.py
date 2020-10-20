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
    subprocess.run(['sh', "run_insights.sh", project, commit])
    return Response(status=200)
