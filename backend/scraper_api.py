from flask import Flask, jsonify, request
import firebase_admin
from firebase_admin import credentials, firestore
import subprocess
import offer_scraper

app = Flask(__name__)

@app.route('/run_scraper', methods=['POST'])
def run_scraper():
    data = request.get_json()
    siteUrl = data.get('site_url')
    scraperScript = "./backend/offer_scraper.py"

    try:
        offer_scraper.scrape_offers(siteUrl, firestoreDb)
        return jsonify({'success': True})
    except subprocess.CalledProcessError as e:
        return jsonify({'success': False, 'error': e.output.strip()})

if __name__ == '__main__':
    credentialData = credentials.Certificate("backend/serviceAccountKey.json")
    firebase_admin.initialize_app(credentialData)
    firestoreDb = firestore.client()
    app.run(debug=True, host='0.0.0.0')