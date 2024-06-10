from flask import Flask, jsonify, request
import firebase_admin
from firebase_admin import credentials, firestore
import threading
import time
import schedule
import offer_scraper
import logging

app = Flask(__name__)

firestoreDb = None
  
# Configure logging
logging.basicConfig(level=logging.INFO)

@app.route('/run_scraper', methods=['POST'])
def run_scraper():
    start_time = time.time()  # Record the start time
    data = request.get_json()
    siteUrl = data.get('site_url')
    scraperScript = "./backend/offer_scraper.py"

    try:
        offer_scraper.scrape_offers(siteUrl, firestoreDb)
        end_time = time.time()  # Record the end time
        duration = end_time - start_time  # Calculate the duration
        logging.info(f"Scraper ran for {duration} seconds")
        return jsonify({'success': True, 'duration': duration})
    except Exception as e:
        end_time = time.time()
        duration = end_time - start_time
        logging.error(f"Scraper failed after {duration} seconds with error: {e}")
        return jsonify({'success': False, 'duration': duration})

def scheduled_scraper():
    start_time = time.time()  # Record the start time
    site_urls = [
        "https://www.arcelik.com.tr",
    ]
    for site_url in site_urls:
        try:
            offer_scraper.scrape_offers(site_url, firestoreDb)
            logging.info(f"Scraping successful for {site_url}")
        except Exception as e:
            logging.error(f"Error scraping {site_url}: Campaign section can not be found")
    end_time = time.time()  # Record the end time
    duration = end_time - start_time  # Calculate the duration
    logging.info(f"Scheduled scraper ran for {duration} seconds")

def run_schedule():
    while True:
        schedule.run_pending()
        time.sleep(1)

# Schedule the function to run every day at 9 AM
schedule.every().day.at("16:29").do(scheduled_scraper)

if __name__ == '__main__':
    
    # Initialize Firebase
    credentialData = credentials.Certificate("backend/serviceAccountKey.json")
    firebase_admin.initialize_app(credentialData)
    firestoreDb = firestore.client()
    # Run the schedule function in a separate thread
    scheduler_thread = threading.Thread(target=run_schedule, daemon=True)
    scheduler_thread.start()
    
    # Start the Flask application
    app.run(debug=True, host='0.0.0.0')
