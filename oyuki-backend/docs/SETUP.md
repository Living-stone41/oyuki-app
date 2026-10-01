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

SECRET_KEY=paste-your-generated-key-here
DEBUG=True
ALLOWED_HOSTS=127.0.0.1,localhost
CORS_ALLOWED_ORIGINS=


## 6. Generate a SECRET_KEY
```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```
Copy the output and paste it as the value of `SECRET_KEY` in `.env` from step 5.

## 7. Run migrations
```bash
python manage.py migrate
```
This creates `db.sqlite3` in your project folder — that's your local database, no separate install needed.

## 8. Load demo data
```bash
python manage.py seed_demo_data
```
This creates one login per role and two sample products so the API isn't empty on first use. The password for every seeded account is `DemoPass123!`. Usernames: `demo_customer`, `demo_seller`, `demo_admin`, `demo_account_officer`, `demo_logistics_admin`, `demo_rider`, `demo_market_agent`, `demo_market_supervisor`, `demo_marketer`.

## 9. Start the server
```bash
python manage.py runserver
```

## 10. Confirm it's working
Open `http://127.0.0.1:8000/api/docs/` in your browser. You should see the Oyuki API documentation (Swagger UI) with every endpoint listed.

Try logging in: expand `POST /api/v1/accounts/login/`, click "Try it out", and use `{"username": "demo_customer", "password": "DemoPass123!"}`. You should get back an `access` and `refresh` token.

## If something goes wrong
- **`python` not recognized** — try `python3` instead, or confirm Python is installed and on your PATH.
- **Port already in use** — another process is using 8000; run `python manage.py runserver 8001` instead and adjust your base URL accordingly.
- **Anything else** — check `docs/HANDOFF.md` for the full API reference, known gaps, and response format details, or reach out to Phil.

## Next steps
Once the server is running, see `docs/HANDOFF.md` for the auth flow, response format, role permissions, and the Postman collection (`docs/Oyuki-API.postman_collection.json`) you can import to test every endpoint without writing any app code yet.