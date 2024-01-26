import firebase_admin
from firebase_admin import credentials, firestore
from pandas import read_excel

def add_campaigns_to_firestore(campaigns, site):
    # SDK ayarlamaları
    credentialData = credentials.Certificate("backend/serviceAccountKey.json")
    firebase_admin.initialize_app(credentialData)
    # Firestore instance  oluşturma
    firestoreDb = firestore.client()

    for campaign in campaigns:
        campaignTitle = campaign.get("Title")  # Burada "id" kampanyanın benzersiz özelliği olsun
        # Daha önce eklenmişse kontrol et
        existing_campaign = firestoreDb.collection("campaigns").where("Title", "==", campaignTitle).get()

        # Daha önce eklenmemişse ekle
        if not existing_campaign:
            firestoreDb.collection("campaigns").add(campaign)

# Veri Ekleme
# firestoreDb.collection(u'testCollection').add({'yazar':'Orhan Veli'})
# # Veri Okuma
# snapshots = list(firestoreDb.collection(u'testCollection').get())
# for snap in snapshots:
#  print(snap.to_dict())