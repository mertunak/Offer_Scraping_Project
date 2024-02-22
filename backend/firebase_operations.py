import firebase_admin
from firebase_admin import credentials, firestore

def add_scraped_site(scraped_site, firestoreDb):

    if not firestoreDb.collection("scraped_sites").where("site_name", "==", scraped_site.get("site_name")).get():
            firestoreDb.collection("scraped_sites").add(scraped_site)

def add_offers_to_firestore(offers, firestoreDb):
    cred = credentials.Certificate('backend/serviceAccountKey.json')
    firebase_admin.initialize_app(cred)
    # Obtain a reference to your Firestore database
    firestoreDb = firestore.client()
    
    for offer in offers:
        offerTitle = offer.get("Title")
        existing_offer = firestoreDb.collection("offers").where("Title", "==", offerTitle).get()

        # Daha önce eklenmemişse ekle
        if not existing_offer:
            firestoreDb.collection("offers").add(offer)

# Veri Ekleme
# firestoreDb.collection(u'testCollection').add({'yazar':'Orhan Veli'})
# # Veri Okuma
# snapshots = list(firestoreDb.collection(u'testCollection').get())
# for snap in snapshots:
#  print(snap.to_dict())