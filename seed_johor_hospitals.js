const url = 'https://qmvpvwrsvtayktvxergh.supabase.co/rest/v1/clinics';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFtdnB2d3JzdnRheWt0dnhlcmdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExMzM4NjksImV4cCI6MjA4NjcwOTg2OX0.Z05VLRqBelWBrr7LrU6mdpxx3OmXkeMQIXgLAfn48uk';
const { randomUUID } = require('crypto');

const johorHospitals = [
    // Government
    {
        name: "Hospital Sultan Ismail",
        address: "Jalan Persiaran Mutiara Emas Utama, Mount Austin, 81100 Johor Bahru",
        latitude: 1.5451,
        longitude: 103.7952,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Hospital Permai",
        address: "Persiaran Kempas Baru, 81200 Johor Bahru",
        latitude: 1.5225,
        longitude: 103.7027,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Hospital Enche' Besar Hajjah Khalsom",
        address: "KM 5, Jalan Kota Tinggi, 86000 Kluang",
        latitude: 2.0305,
        longitude: 103.3150,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Hospital Pakar Sultanah Fatimah",
        address: "Jalan Salleh, 84000 Muar",
        latitude: 2.0435,
        longitude: 102.5694,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Hospital Segamat",
        address: "KM 6, Jalan Genuang, 85000 Segamat",
        latitude: 2.5152,
        longitude: 102.8222,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Hospital Pontian",
        address: "Jalan Alsagoff, 82000 Pontian",
        latitude: 1.4886,
        longitude: 103.3912,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Hospital Kota Tinggi",
        address: "Jalan Lombong, 81900 Kota Tinggi",
        latitude: 1.7370,
        longitude: 103.8988,
        type: "Hospital",
        is_verified: true
    },

    // Private
    {
        name: "KPJ Puteri Specialist Hospital",
        address: "33, Jalan Tun Abdul Razak (Susur 5), 80350 Johor Bahru",
        latitude: 1.5037,
        longitude: 103.7380,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "KPJ Pasir Gudang Specialist Hospital",
        address: "Lot PTD 204781, Jalan Masjid, 81750 Pasir Gudang",
        latitude: 1.4735,
        longitude: 103.8967,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Gleneagles Hospital Medini Johor",
        address: "2, Jalan Medini Utara 4, Medini Iskandar, 79250 Iskandar Puteri",
        latitude: 1.4287,
        longitude: 103.6267,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Columbia Asia Hospital - Iskandar Puteri",
        address: "Persiaran Afiat, Taman Kesihatan Afiat, 79250 Iskandar Puteri",
        latitude: 1.4925,
        longitude: 103.6457,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Columbia Asia Hospital - Tebrau",
        address: "Persiaran Southkey 5, Kota Southkey, 80150 Johor Bahru",
        latitude: 1.5542,
        longitude: 103.7846,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Regency Specialist Hospital",
        address: "1, Jalan Suria, Bandar Seri Alam, 81750 Masai",
        latitude: 1.5135,
        longitude: 103.8820,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Kempas Medical Centre",
        address: "Lot PTD 104997, Persiaran Kempas Baru, 81200 Johor Bahru",
        latitude: 1.5369,
        longitude: 103.7144,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Pantai Hospital Batu Pahat",
        address: "9S, Jalan Kluang, 83000 Batu Pahat",
        latitude: 1.8550,
        longitude: 102.9463,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "Putra Specialist Hospital Batu Pahat",
        address: "1, Jalan Peserai Jaya, 83000 Batu Pahat",
        latitude: 1.8542,
        longitude: 102.9298,
        type: "Hospital",
        is_verified: true
    },
    {
        name: "KPJ Bandar Dato' Onn Specialist Hospital",
        address: "Jalan Bukit Mutiara, Bandar Dato Onn, 81100 Johor Bahru",
        latitude: 1.5647,
        longitude: 103.7451,
        type: "Hospital",
        is_verified: true
    }
];

const records = johorHospitals.map(h => ({
    id: randomUUID(),
    name: h.name,
    address: h.address,
    latitude: h.latitude,
    longitude: h.longitude,
    type: h.type,
    image_url: 'https://via.placeholder.com/150',
    created_at: new Date().toISOString()
}));

fetch(url, {
    method: 'POST',
    headers: {
        'apikey': key,
        'Authorization': 'Bearer ' + key,
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
    },
    body: JSON.stringify(records)
})
    .then(res => {
        if (res.ok) {
            console.log(`Successfully added ${records.length} hospitals in Johor to the database!`);
        } else {
            return res.text().then(text => console.error("Error connecting to Supabase:", res.status, text));
        }
    })
    .catch(err => console.error(err));
