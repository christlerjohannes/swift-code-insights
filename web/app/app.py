import os
import socket
import subprocess
from subprocess import check_output

from flask import Flask
from flask import request, Response
from redis import Redis


app = Flask(__name__)
redis = Redis(host=os.environ.get('REDIS_HOST', 'redis'), port=6379)



@app.route('/')
def hello():
    redis.incr('hits')
    return 'Hello Container World! I have been seen %s times and my hostname is %s.\n' % (redis.get('hits'),socket.gethostname())
    
@app.route('/webhook', methods=['POST'])
def respond():
    project = request.json['repository']['slug']
    commit = request.json['changes'][0]['toHash']
    
    subprocess.run(['sh', "run_insights.sh", project, commit], cwd="app")
    
    return Response("done")