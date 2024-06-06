import re
from firebase_admin import firestore

def add_scraped_site(scraped_site, firestoreDb):

    if not firestoreDb.collection("scraped_sites").where("site_name", "==", scraped_site.get("site_name")).get():
        firestoreDb.collection("scraped_sites").add(scraped_site)

def add_offers_to_firestore(offers, firestoreDb):
    category_ref = firestoreDb.collection("inverted_index_category")
    type_ref = firestoreDb.collection("inverted_index_type")

    cloth_doc = category_ref.document("giyim")
    elec_doc = category_ref.document("elektronik")
    home_doc = category_ref.document("ev")
    finance_doc = category_ref.document("finans")
    holiday_doc = category_ref.document("tatil")
    travel_doc = category_ref.document("ulaşım")
    tele_doc = category_ref.document("telekom")
    baby_doc = category_ref.document("bebek")
    vehicle_doc = category_ref.document("araç")
    cosmetic_doc = category_ref.document("kozmetik")
    market_doc = category_ref.document("market")

    day_doc = type_ref.document("özel günler")
    discount_doc = type_ref.document("indirim")
    cupon_doc = type_ref.document("kupon")
    draw_doc = type_ref.document("çekiliş")

    for offer in offers:
        offerTitle = offer.get("title")
        existing_offer = firestoreDb.collection("offers").where("title", "==", offerTitle).get()

        # Daha önce eklenmemişse ekle
        if not existing_offer:
            update_time, new_offer_ref = firestoreDb.collection("offers").add(offer)
            offer_id = new_offer_ref.id

            combined_text = offer.get("title") + " " + offer.get("description")

            if re.search(r'\b(giyim|kıyafet|bluz|etek|takım)\b', combined_text, re.IGNORECASE):
                if not cloth_doc.get().exists:
                    cloth_doc.set({})
                    
                cloth_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(teknoloji|elektrik|kettle|ev alet|robot)\b', combined_text, re.IGNORECASE):
                if not elec_doc.get().exists:
                    elec_doc.set({})
                    
                elec_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(ev|eşya)\b', combined_text, re.IGNORECASE):
                if not home_doc.get().exists:
                    home_doc.set({})
                    
                home_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(kart|kredi|banka)\b', combined_text, re.IGNORECASE):
                if not finance_doc.get().exists:
                    finance_doc.set({})
                    
                finance_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(tatil|otel|rezervasyon)\b', combined_text, re.IGNORECASE):
                if not holiday_doc.get().exists:
                    holiday_doc.set({})

                holiday_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(ulaşım|uçak|mil|bilet)\b', combined_text, re.IGNORECASE):
                if not travel_doc.get().exists:
                    travel_doc.set({})

                travel_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(hat|telefon|faturalı|faturasız)\b', combined_text, re.IGNORECASE):
                if not tele_doc.get().exists:
                    tele_doc.set({})

                tele_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(bebek|mama|doğan|emzik)\b', combined_text, re.IGNORECASE):
                if not baby_doc.get().exists:
                    baby_doc.set({})

                baby_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(araba|araç|teker|otomobil|motor|lastik)\b', combined_text, re.IGNORECASE):
                if not vehicle_doc.get().exists:
                    vehicle_doc.set({})

                vehicle_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(makyaj|kişisel bakım|bakım ürün|güzellik|far|ruj)\b', combined_text, re.IGNORECASE):
                if not cosmetic_doc.get().exists:
                    cosmetic_doc.set({})

                cosmetic_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(market|meyve|sebze|dondurma|şarküteri|temizlik)\b', combined_text, re.IGNORECASE):
                if not market_doc.get().exists:
                    market_doc.set({})

                market_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })


            if re.search(r'\b(anneler gün|doğum gün|babalar gün|bayram|friday)\b', combined_text, re.IGNORECASE):
                if not day_doc.get().exists:
                    day_doc.set({})

                day_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(indirim|%|yüzde|tl|ucuz)\b', combined_text, re.IGNORECASE):
                if not discount_doc.get().exists:
                    discount_doc.set({})

                discount_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(kupon)\b', combined_text, re.IGNORECASE):
                if not cupon_doc.get().exists:
                    cupon_doc.set({})

                cupon_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

            if re.search(r'\b(çekiliş)\b', combined_text, re.IGNORECASE):
                if not draw_doc.get().exists:
                    draw_doc.set({})

                draw_doc.update({
                    "offer_ids": firestore.ArrayUnion([offer_id])
                })

# Veri Ekleme
# firestoreDb.collection(u'testCollection').add({'yazar':'Orhan Veli'})
# # Veri Okuma
# snapshots = list(firestoreDb.collection(u'testCollection').get())
# for snap in snapshots:
#  print(snap.to_dict())