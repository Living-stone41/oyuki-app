# Oyuki Backend — Local Setup

Follow these in order. By the end, you'll have the API running on your machine with test data and login credentials ready.

## 1. Prerequisites
- Python 3.11+ installed and on your PATH
- Git installed

## 2. Clone the repo
```bash
git clone <repo-url>
cd oyuki-backend
```

## 3. Create and activate a virtual environment
```bash
python -m venv venv
```
Windows (Git Bash):
```bash
source venv/Scripts/activate
```
Windows (Command Prompt):
```bash
venv\Scripts\activate
```
Mac/Linux:
```bash
source venv/bin/activate
```
Your terminal prompt should now show `(venv)` at the start of the line.

## 4. Install dependencies
```bash
pip install -r requirements.txt
```

## 5. Create your `.env` file
In the project root — the same folder as `manage.py` — create a file named exactly `.env` with this content: