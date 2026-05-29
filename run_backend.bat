@echo off
cd /d c:\Users\user\Desktop\kayting\EduScan\backend
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload