from flask import Flask, jsonify, request
import firebase_admin
from firebase_admin import credentials, firestore
import threading
import time
import schedule
import offer_scraper

app = Flask(__name__)

# Firebase'i başlatma
credentialData = credentials.Certificate("backend/serviceAccountKey.json")
firebase_admin.initialize_app(credentialData)
firestoreDb = firestore.client()

@app.route('/run_scraper', methods=['POST'])
def run_scraper():
    data = request.get_json()
    siteUrl = data.get('site_url')
    scraperScript = "./backend/offer_scraper.py"

    try:
        offer_scraper.scrape_offers(siteUrl, firestoreDb)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False})

def scheduled_scraper():
    site_urls = [
        "https://www.isbank.com.tr",
    ]
    for site_url in site_urls:
        try:
            offer_scraper.scrape_offers(site_url, firestoreDb)
            print(f"Scraping successful for {site_url}")
        except Exception as e:
            print(f"Error scraping {site_url}: {e}")

def run_schedule():
    while True:
        schedule.run_pending()
        time.sleep(1)

# Her gün saat 9'da çalışacak işlevi planla
schedule.every().day.at("15:29").do(scheduled_scraper)

if __name__ == '__main__':
    # Schedule işlevini ayrı bir thread'de çalıştırın
    scheduler_thread = threading.Thread(target=run_schedule, daemon=True)
    scheduler_thread.start()
    
    # Flask uygulamasını başlatın
    app.run(debug=True, host='0.0.0.0')
