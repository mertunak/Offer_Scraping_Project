import re
import datetime

text = [
"Kampanya Detayları STARS, alışverişlerde üyelerimize özel avantajlar sunan bir sadakat programıdır.STARS'lı olmak için üyelik oluşturmanız ve telefon numaranızı doğrulamanız yeterlidir.STARS'lı olduğunuzda, her alışverişinizde %3 Stars puan kazanırsınız.Bu kampanya dahilinde, STARS'lı olarak yaptığınız 1250 TL ve üzeri alışverişlerinizde 50 Stars puana kadar 3 kat değerli puan katlama fırsatını yakalarsınız.Kampanya 1-29 Şubat tarihleri arasında geçerlidir.Altınyıldız Classics, kampanyayı dilediği zaman değiştirme veya sonlandırma hakkını saklı tutar.",

"Kampanya Detayları STARS; alışverişlerde, üyelerimize özel avantajlar ve ayrıcalıklar sağlayan programdır.Üyelik oluşturup, telefon numarasını doğrulayan her kullanıcı STARS'lı olma avantajını yakalar.Sepet ekranına geldiğinizde STARS bölümünden topladığınız puanları kullanarak indirimli alışveriş yapabilirsiniz.Her alışverişinde puan kazanırsınız.Kazandığın puanları bir sonraki alışverişinde kullanarak ekstra indirimli alışveriş yapabilirsiniz.Özel günlerde sizi ilk o hatırlar!Ayrıcalıklı Müşteri Hizmetleri deneyimi sunarız.STARS özel ayrıcalık ve avantajlardan ilk sizin haberiniz olur.Altıkullanıcılarınanyıldız Classics Müşteri Hizmetleri - Çağrı Merkezi Tel No: 0850 455 56 57 - E-posta: destek@altinyildizclassics.com",

"Kampanya Detayları Kampanyadan Hopi Kartsız Taksit kullanıcıları faydalanabilecektir.Kampanya Altınyıldız Classics Online’da geçerlidir.Kampanya, 17 Mart 2024 saat 23.59’da sona erecektir.Kampanya markada 300 TL – 3.000 TL arasında 6 taksitle yapılacak alışverişlerde geçerli olacaktır.Kampanya kapsamında 6 ay taksitle yapılan alışverişlerde son taksit TURK Finansman A.Ş. tarafından ödenecektir. İlk 5 taksitin geri ödemesinde müşteri tarafından gecikme yaşanması halinde müşteri kampanyadan yararlanma hakkını kaybedecek ve son taksit kullanıcı tarafından ödenecektir. Böyle bir durumda, TURK Finansman A.Ş.’nin belirlediği faiz oranları geçerli olacak ve kullanıcıya gecikme faizi yansıtılacaktır.İptal/iade işlemlerinde hopi Kartsız Taksit hesabı oluştururken kabul edilen Kullanıcı Sözleşmesi’nde yer alan “İptal/iade” koşulları geçerli olacaktır.",

"Kampanya Detayları 31 Aralık 2024 tarihine kadar Altınyıldız Classics ve altinyildizclassics.com’da; yalnızca Axess ve Maximum Kart’a özel vade farksız 6 taksit uygulanabilecektir.Akbank T.A.Ş. ve T. İş Bankası A.Ş. kampanyayı durdurma ve değiştirme hakkını saklı tutar.",

"Kampanya Detayları “Bip Club” üyelerine özel, Altınyıldız Classics mağazalarından yapılacak alışverişlerde geçerli 3000 TL ve üzeri alışverişlerde geçerli ek %15 indirim uygulanır.Kampanya, sadece Altınyıldız Classics mağazalarında geçerlidir, outlet mağazalarda ve online alışverişlerde geçerli değildir.Kampanya, smokin hariç tüm ürün gruplarında geçerlidir.Kazanılan indirim kodu tek kullanımlık olup şifre kullanmadan yapılan işlemlerde indirim sağlanmayacaktır.Kampanya dönemi boyunca 1 kişi, kampanyadan 1 defa faydalanabilecektir.Kampanyadan kazanılan indirim kodu 10.03.2024’e kadar geçerlidir.Altınyıldız Classics mağazalarında indirimden yararlanmak için STARS sadakat programı üyeliği yapılmalıdır. Katılımcılar STARS sadakat programı hakkında altinyildizclassics.com internet sitesinden detaylı bilgiye ulaşabilirler.Bu kampanya, belli tutarda alışverişe toplam fatura tutarı üzerinden kasada ekstra anında indirim sağlayan kampanyalar ile birleştirilemez.Kampanya, diğer indirim çeki/ hediye çeki kampanyaları ile birleştirilemez.Altınyıldız Classics ve Bip Club kampanyayı dilediği zaman sonlandırma veya değiştirme hakkını saklı tutar.Kampanya 13.02.2024 - 10.03.2024 tarihleri arasında geçerlidir.",

"Kampanya Detayları Altınyıldız Classics mağazalarındaki öğrenci kampanyası görselinde yer alan QR kodu okut, edu.tr uzantılı mail adresinle sayfaya kaydol, e-mail adresine gelecek kodla %15 indirim kazan.Kampanyadan yararlanabilmek için alışveriş öncesinde STARS sadakat programı üyesi olunması gerekmektedir.Kampanyadan ayda 1 kez yararlanılabilir.İndirim kodu, başka indirim kodları/çekleri ile birleştirilemez.Bu kampanya, belli tutarda alışverişe toplam fatura tutarı üzerinden kasada ekstra anında indirim sağlayan kampanyalar ile birleştirilemez.Kampanya, Altınyıldız Classics online mağazalarında geçerli değildir.Kampanya 23.10.2023 - 31.12.2024 tarihleri arasında geçerlidir.Altınyıldız Classics, kampanyayı dilediği zaman değiştirme veya sonlandırma hakkını saklı tutar.",

"Kampanya Detayları Altınyıldız Classics mağazalarındaki öğretmen kampanyası görselinde yer alan QR kodu okut, karşına çıkan formdaki bilgileri doldur ve forma öğretmen kartının fotoğrafını yükle.Kampanyadan sadece öğretmen kartı olan kişiler yararlanabilir. SMS ile telefonuna gelecek olan kodla Altınyıldız Classics mağazalarında gerçekleştirdiğin 3000 TL ve üzeri alışverişlerde tüm indirimlere ek %15 indirim kazanırsın.Kampanyadan yararlanabilmek için alışveriş öncesinde STARS sadakat programı üyesi olunması gerekmektedir. Kampanyadan ayda 1 kez yararlanılabilir. İndirim kodu, başka indirim kodları /çekleri ile birleştirilemez.Bu kampanya, belli tutarda alışverişe toplam fatura tutarı üzerinden kasada ekstra anında indirim sağlayan kampanyalar ile birleştirilemez. Kampanya, Altınyıldız Classics online mağazalarında geçerli değildir.Kampanya 01.12.2023 - 31.12.2024 tarihleri arasında geçerlidir.Altınyıldız Classics, kampanyayı dilediği zaman sonlandırma veya değiştirme hakkını saklı tutar.",

"Kampanya Detayları Altınyıldız Classics mağazalarındaki avukat kampanyası görselinde yer alan QR kodu okut, karşına çıkan formdaki bilgileri doldur.Türkiye Barolar Birliği’ne avukat olarak kayıtlıysan indirimden yararlanma hakkına sahip olursun.Kampanya kapsamında, SMS ile telefonuna gelecek olan kodla Altınyıldız Classics mağazalarında gerçekleştirdiğin 3000 TL ve üzeri alışverişlerde tüm indirimlere ek %15 indirim kazanırsın.Kampanyadan yararlanabilmek için alışveriş öncesinde STARS sadakat programı üyesi olunması gerekmektedir.Kampanyadan ayda 1 kez yararlanılabilir. İndirim kodu, başka indirim kodları /çekleri ile birleştirilemez.Bu kampanya, belli tutarda alışverişe toplam fatura tutarı üzerinden kasada ekstra anında indirim sağlayan kampanyalar ile birleştirilemez.Kampanya, Altınyıldız Classics online mağazalarında geçerli değildir.Kampanya 17.08.2023 - 31.12.2024 tarihleri arasında geçerlidir.Altınyıldız Classics, kampanyayı dilediği zaman sonlandırma veya değiştirme hakkını saklı tutar.",

"Kampanya Detayları İşbu kampanyadan yararlanabilmek için kişinin Miles&Smiles Yolcu Programı üyesi olması gerekmektedir.Miller, Türk Hava Yolları Mil harcama platformu shopandmiles.com’da Altınyıldız Hediye Çekine dönüştürülür.Miles&Smiles üyeleri tarafından Mil karşılığı alınan Altınyıldız Hediye Çekleri alındığı tarihten itibaren 1(bir) yıl geçerlidir.Altınyıldız Classics Hediye Çeki’ne çevrilen Miller, Miles&Smiles üyelik hesabına geri yüklenemez ve paraya çevrilemez.Altınyıldız Classics ve Türk Hava Yolları kampanya koşullarını değiştirme hakkını saklı tutar.Altınyıldız Classics Hediye Çeki, Türkiye’deki çadır/panayır konsept mağazaları ve web sitesi hariç tüm Altınyıldız Classics mağazalarında geçerlidir. Smokin hariç tüm ürün veya kategori alışverişlerinde geçerlidir.Altınyıldız Classics Hediye Çeki’nin kullanımı için, hediye çeki kodu mağaza kasa görevlisine gösterilmelidir.Altınyıldız Classics Hediye Çeki, kasa satış fiyatı üzerinden geçerlidir.Altınyıldız Classics Hediye Çeki ile yapılan alışverişlerde en az 1 TL’lik ödeme yapılması gerekmektedirHediye çekleri, belli tutarda alışverişe toplam fatura tutarı üzerinden kasada anında ekstra indirim sağlayan kampanyalar ile birleştirilemez.Aynı kişi aynı faturada birden fazla hediye çeki kullanamaz.Çek tutarı bölünemez, mağaza içerisindeki diğer indirim çeki kampanyaları ve hediye çeki kampanyaları ile birlikte kullanılamaz.İşbu kampanya yalnızca Türkiye’de geçerlidir.Hediye çekleri stoklarla sınırlıdır.Kampanyadan faydalanan Miles&Smiles Yolcu Programı üyeleri yukarıdaki şartları kabul etmiş sayılır.Miles&Smiles Müşteri Hizmetleri - Shop&Miles ile ilgili geri bildirimleriniz için Geri Bildirim Formu üzerinden Türk Hava Yolları’na ulaşabilirsiniz.Kampanya 04.04.2023 - 31.12.2024 tarihleri arasında geçerlidir.Altınyıldız Classics Müşteri Hizmetleri - Çağrı Merkezi Tel No: 0850 455 56 57 - E-posta: destek@altinyildizclassics.com",

"Kampanya Detayları Büyük gün için Stars’lı Ol, Smokinini Seç, 5 Arkadaşını Davet Et!Mağazalarımızda alışveriş yapan her bir arkadaşın için 30 TL STARS PUAN, 5 arkadaşın için ise 150 TL STARS PUAN kazanabilirsinSen arkadaşlarının alışverişinden 150 TL’ye varan STARS PUAN kazanırken, arkadaşların da %15 indirimli alışverişin ayrıcalığını yaşasın!Altınyıldız Classics mağazalarında smokin alışverişi yapmadan önce Altınyıldız Classics mobil uygulamasını indirerek STARS’lı olun, ardından STARS’lı müşteri numaranızla mağazalarımızda smokin alışverişi gerçekleştirin.Smokin alışverişini gerçekleştirdikten sonra, Altınyıldız Classics mobil uygulamasındaki hesabım sayfasında KAMPANYA alanında yer alan DAVET KODU’nu 5 arkadaşınızla paylaşın.Kod ile Altınyıldız Classics mobil uygulamasına davet edilen kullanıcının mobil uygulamamızı indirip STARS’lı olması gerekmektedir.STARS’a üye olan kullanıcılar, uygulamadaki hesabım sayfasında KAMPANYA alanında yer alan DAVET KODU GİR alanına damadın ilettiği kodu girer. DAVET KODU ilgili alana girildikten sonra sistem, kullanıcıya özel bir indirim şifresi oluşturur.Damadın arkadaşı, fiziki mağazalarımızda yer alan kasa noktasındaki satış görevlisi arkadaşımızla indirim şifresini paylaşarak direkt indirimden yararlanabilir.Damat tarafından arkadaşlarına yalnızca bir defa kod oluşturulabilir. Oluşturulan kod en fazla 5 kullanıcıya gönderilebilir. Damadın arkadaşının yalnızca 1 defa davet kodu alma hakkı bulunmaktadır.Davet gönderen damadın kampanya kapsamında kazandığı STARS PUAN’lar, arkadaşının alışverişinden 30 gün sonra hesabına yüklenecektir.Kampanya kapsamında damat, en fazla 5 kişiyi üye yaparak, üye olan arkadaşlarının fiziki mağazalardan alışveriş yapma koşulu ile en fazla 150 TL STARS PUAN kazanabilir.Uygulamaya davet edilen kullanıcı, kendisine iletilen tek kullanımlık indirim şifresi ile Altınyıldız Classics mağazalarından % 15 indirimli alışveriş yapabilir. % 15 indirimli alışveriş, sadece Altınyıldız Classics mağazalarında geçerlidir, outlet mağazalarda ve online alışverişlerde geçerli değildir. Kampanyadan kazanılan indirim şifresi, 31.12.2024’e kadar geçerli olacaktır. İndirim şifresi, diğer indirim çeki/ hediye çeki kampanyaları ile birleştirilemez. İndirim şifresi, belli tutarda alışverişe toplam fatura tutarı üzerinden kasada ekstra anında indirim sağlayan kampanyalar ile birleştirilemez.Kampanya 31.05.2023 - 31.12.2024 tarihleri arasında geçerlidir.Altınyıldız Classics, kampanyayı dilediği zaman sonlandırma veya değiştirme hakkını saklı tutar.",

"Kampanya Detayları indirime ek 2 ürüne sepette %15 indirim ve 3 ve üzeri ürüne sepette %20 indirim sizin için en uygun indirim ve fırsatlara kolaylıkla ulaşmanızı amaçlamaktadır.Erkek gömlek, pantolon, tişört ve daha nice indirimli ürünlerden yararlanmak için altınyıldızclassics.com'u ziyaret ederek sepet indirimi fırsatlarından faydalanabilirsiniz.Kampanya kapsamında; altınyıldızclassics.com'da, '2.ürüne sepette %15'kırmızı etiketli ürünler için 2 ürün alımında sepette %15 indirim ve 3 ve üzeri alımda sepette %20 indirim uygulanmaktadır.Mobil uygulamamıza özel ayrıcalıklı olan kampanyamızda; 2 ürüne sepette %20 indirim ve 3 ve üzeri ürüne sepette %25 indirim uygulanmaktadır.Kampanyamız başka kampanyalarla birleştirilememektedir.Üye; kampanya içeriklerinde meydana gelebilecek değişikliklerin internet sitemize yansıtılmasında kısa süreli gecikmeler yaşanabileceği hususu göz önünde bulundurulmalıdır.Kampanya 1-29 Şubat tarihleri arasında geçerlidir.Kampanya kapsamında Altınyıldız Classics'ten satın alınan ürünlerle ilgili olarak yaşanabilecek her türlü sorun, itiraz ve şikayetler Altınyıldız Classics’in 0850 455 56 57 numaralı müşteri hizmetleri hattına iletilebilir.",

"Kampanya Detayları Outlet kampanyası sizin için en uygun, kaliteli ve stil sahibi ürünlere kolaylıkla ulaşmanızı amaçlamaktadır.Erkek tişört, gömlek, pantolon ve daha nice indirimli ürünlerden yararlanmak için altınyıldızclassics.com'u ziyaret ederek outletin fırsat dolu indirimlerinden faydalanabilirsiniz.Kampanyamız başka kampanyalarla birleştirilememektedir.Üye; kampanya içeriklerinde meydana gelebilecek değişikliklerin internet sitemize yansıtılmasında kısa süreli gecikmeler yaşanabileceği hususu göz önünde bulundurulmalıdır.Kampanya 1-29 Şubat tarihleri arasında geçerlidir.Kampanya kapsamında Altınyıldız Classics'ten satın alınan ürünlerle ilgili olarak yaşanabilecek her türlü sorun, itiraz ve şikayetler Altınyıldız Classics’in 0850 455 56 57 numaralı müşteri hizmetleri hattına iletilebilir.",
]

def dateFormater(date):
    months = ["Ocak","Şubat","Mart","Nisan","Mayıs","Haziran","Temmuz","Ağustos","Eylül","Ekim","Kasım","Aralık"]
    formatedDate = ""
    if date is not None and isinstance(date, str):
        if re.search(r'[a-zA-Z]', date):
            dateParts = date.split(" ")
            if len(dateParts[0]) == 1:
                formatedDate += "0"
            formatedDate += dateParts[0] + "."

            i = 0
            for month in months:
                i += 1
                if re.match(month, dateParts[1], re.I):
                    break
            
            if i < 10:
                formatedDate += "0"
            formatedDate += str(i) + "."
            
            if len(dateParts) < 3:
                formatedDate += str(datetime.date.today().year)
            else:
                formatedDate += dateParts[2]
            
            return formatedDate
        else:
            return date.strip()
    else: 
        return formatedDate
        
singleDateRegex = r'\d{1,2}(\.\d{1,2}\.|\s(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s)\d{4}'
digitDateRegex = r'\d{1,2}\.\d{1,2}\.\d{4}'
dateRangeRegex1 = r'(\d{1,2})\s*\.?\s*(?:Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s*\.?\s*(\d{4})'
dateRangeRegex = r'\b\d{1,2}(\.\d{1,2}\.|\s(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s*)*(\d{4})*\s*-\s*\d{1,2}(\.\d{1,2}\.|\s(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık)\s)(\d{4})*'
dateRangeRegex3 = r'\b\d{1,2}\s*-\s*\d{1,2}(\.\d{1,2}\.|\s(Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık))'

singleDatePatern = re.compile(singleDateRegex)
digitDatePatern = re.compile(digitDateRegex)
dateRangePatern = re.compile(dateRangeRegex)

i = 1
for desc in text:
    
    startDate = ""
    endDate = ""

    print(str(i) + "--------------------------")
    i += 1
    dateRanges = list(dateRangePatern.finditer(desc))

    if dateRanges:
        dateRange = dateRanges[-1].group()
        dates = list(digitDatePatern.finditer(dateRange))
        if dates:
            startDate = dates[0].group()
            endDate = dates[1].group()
        else:
            dates = dateRange.split("-")
            endDate = dateFormater(dates[1].strip())
            startDateParts = dates[0].strip().split(" ")
            if len(startDateParts) < 2:
                startDate = dateFormater(startDateParts[0] + " " + dates[1].strip().split(" ")[1])
            else: 
                startDate = dateFormater(dates[0].strip())
    else:
        singleDates = list(singleDatePatern.finditer(desc))
        match len(singleDates):
            case 0:
                print("Date not found")
            case 1:
                startDate = ""
                endDate = dateFormater(singleDates[0].group())
            case 2:
                startDate = dateFormater(singleDates[0].group())
                endDate = dateFormater(singleDates[1].group())
            case default:
                startDate = dateFormater(singleDates[-2].group())
                endDate = dateFormater(singleDates[-1].group())
    
    print("Start date: " + startDate)
    print("End date: " + endDate)

