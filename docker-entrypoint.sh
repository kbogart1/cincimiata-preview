#!/bin/bash
flask db upgrade || true
exec gunicorn -b 0.0.0.0:80 app.main:app
