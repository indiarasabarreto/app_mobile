#!/usr/bin/env bash
set -o errexit # Abortar em caso de erro

pip install -r requirements.txt
python manage.py collectstatic --no-input
python manage.py migrate