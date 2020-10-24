#!/bin/bash

#gunicorn --log-level info --log-file=/gunicorn.log --workers 4 --name app -b 0.0.0.0:8080 --reload app.app:app
gunicorn -c app/config.py app.app:app
