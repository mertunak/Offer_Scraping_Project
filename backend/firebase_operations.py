import firebase_admin
from firebase_admin import credentials, firestore
from pandas import read_excel

def add_offers_to_firestore(offers, site):
    # SDK ayarlamaları
    credentialData = credentials.Certificate("backend/serviceAccountKey.json")
    firebase_admin.initialize_app(credentialData)
    # Firestore instance  oluşturma
    firestoreDb = firestore.client()

    for offer in offers:
        offerTitle = offer.get("Title")  # Burada "id" kampanyanın benzersiz özelliği olsun
        # Daha önce eklenmişse kontrol et
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