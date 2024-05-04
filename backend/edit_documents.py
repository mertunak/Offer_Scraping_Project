import firebase_operations
import firebase_admin
from firebase_admin import credentials, firestore

credentialData = credentials.Certificate("backend/serviceAccountKey.json")
firebase_admin.initialize_app(credentialData)
firestoreDb = firestore.client()

# scraped_site = {
#     "site_name": "Isbank",
#     "url": "https://www.isbank.com.tr",
#     "last_scrape_date": "10.02.2024"
# }
# firebase_operations.add_scraped_site(scraped_site, firestoreDb)

# scraped_site = {
#     "site_name": "Bellona",
#     "url": "https://www.bellona.com.tr",
#     "scraping_date": "11.02.2024"
# }
# firebase_operations.add_scraped_site(scraped_site, firestoreDb)

# scraped_site = {
#     "site_name": "MediaMarkt",
#     "url": "https://www.mediamarkt.com.tr",
#     "scraping_date": "10.02.2024"
# }
# firebase_operations.add_scraped_site(scraped_site, firestoreDb)

# scraped_site = {
#     "site_name": "MediaMarkt",
#     "url": "https://www.mediamarkt.com.tr",
#     "scraping_date": "10.02.2024"
# }
# firebase_operations.add_scraped_site(scraped_site, firestoreDb)