-- Drop existing tables to avoid conflicts
DROP TABLE IF EXISTS public.clinic_services; -- Drop child first
DROP TABLE IF EXISTS public.clinics; -- Drop parent second

-- Create Clinics Table
CREATE TABLE public.clinics (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    address text NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    type text CHECK (type IN ('Hospital', 'Clinic', 'PPV')),
    image_url text,
    created_at timestamptz DEFAULT now()
);

-- Create Services Table
CREATE TABLE public.clinic_services (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    clinic_id uuid REFERENCES public.clinics(id) ON DELETE CASCADE,
    service_name text NOT NULL,
    price double precision NOT NULL,
    available_slots int DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.clinics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clinic_services ENABLE ROW LEVEL SECURITY;

-- Policies: Public Read Access
CREATE POLICY "Clinics are viewable by everyone" ON public.clinics FOR SELECT USING (true);
CREATE POLICY "Services are viewable by everyone" ON public.clinic_services FOR SELECT USING (true);

-- Seed Data: Clinics (Using predefined UUIDs for linking)
INSERT INTO public.clinics (id, name, address, latitude, longitude, type, image_url) VALUES 
-- Kuala Lumpur
('a1111111-1111-1111-1111-111111111111', 'Klinik Kesihatan Kuala Lumpur', 'Jalan Temerloh, Titiwangsa, 53200 KL', 3.1724, 101.7027, 'Clinic', 'https://via.placeholder.com/150'),
('a2222222-2222-2222-2222-222222222222', 'Gleneagles Hospital KL', '282, Jalan Ampang, 50450 KL', 3.1578, 101.7371, 'Hospital', 'https://via.placeholder.com/150'),
('a3333333-3333-3333-3333-333333333333', 'PPV World Trade Centre', '41, Jalan Tun Ismail, 50480 KL', 3.1691, 101.6912, 'PPV', 'https://via.placeholder.com/150'),
('a4444444-4444-4444-4444-444444444444', 'Prince Court Medical Centre', '39, Jalan Kia Peng, 50450 KL', 3.1500, 101.7200, 'Hospital', 'https://via.placeholder.com/150'),

-- Selangor
('b1111111-1111-1111-1111-111111111111', 'Hospital Shah Alam', 'Persiaran Kayangan, Seksyen 7, 40000 Shah Alam', 3.0718, 101.4900, 'Hospital', 'https://via.placeholder.com/150'),
('b2222222-2222-2222-2222-222222222222', 'Sunway Medical Centre', '5, Jalan Lagoon Selatan, 47500 Subang Jaya', 3.0680, 101.6050, 'Hospital', 'https://via.placeholder.com/150'),
('b3333333-3333-3333-3333-333333333333', 'Klinik Kesihatan Gakh', 'Jalan Gombak, 53100 Selangor', 3.2200, 101.7000, 'Clinic', 'https://via.placeholder.com/150'),

-- Penang
('c1111111-1111-1111-1111-111111111111', 'Hospital Pulau Pinang', 'Jalan Residensi, 10990 George Town', 5.4160, 100.3120, 'Hospital', 'https://via.placeholder.com/150'),
('c2222222-2222-2222-2222-222222222222', 'Gleneagles Penang', '1, Jalan Pangkor, 10050 George Town', 5.4280, 100.3190, 'Hospital', 'https://via.placeholder.com/150'),

-- Johor
('d1111111-1111-1111-1111-111111111111', 'Hospital Sultanah Aminah', 'Jalan Persiaran Abu Bakar Sultan, 80100 Johor Bahru', 1.4580, 103.7430, 'Hospital', 'https://via.placeholder.com/150'),
('d2222222-2222-2222-2222-222222222222', 'KPJ Johor Specialist', '39-B, Jalan Abdul Samad, 80100 Johor Bahru', 1.4720, 103.7440, 'Hospital', 'https://via.placeholder.com/150'),

-- Sabah
('e1111111-1111-1111-1111-111111111111', 'Hospital Queen Elizabeth', 'Karung Berkunci No. 2029, 88586 Kota Kinabalu', 5.9550, 116.0740, 'Hospital', 'https://via.placeholder.com/150'),
('e2222222-2222-2222-2222-222222222222', 'Klinik Kesihatan Luyang', 'Jalan Luyang, Luyang, 88300 Kota Kinabalu', 5.9600, 116.0900, 'Clinic', 'https://via.placeholder.com/150'),

-- Sarawak
('f1111111-1111-1111-1111-111111111111', 'Sarawak General Hospital', 'Jalan Hospital, 93586 Kuching', 1.5510, 110.3420, 'Hospital', 'https://via.placeholder.com/150'),
('f2222222-2222-2222-2222-222222222222', 'Normah Medical Specialist Centre', 'Lot 937, Section 30 KTLD, Jalan Tun Datuk Patinggi, 93050 Kuching', 1.5800, 110.3300, 'Hospital', 'https://via.placeholder.com/150');


-- Seed Data: Services (Linked to Clinics)
INSERT INTO public.clinic_services (clinic_id, service_name, price, available_slots) VALUES
-- KL Clinics
('a1111111-1111-1111-1111-111111111111', 'General Consultation', 1.00, 100),
('a1111111-1111-1111-1111-111111111111', 'Vaccination (Booster)', 0.00, 200),
('a2222222-2222-2222-2222-222222222222', 'Specialist Consultation', 250.00, 15),
('a2222222-2222-2222-2222-222222222222', 'Full Body Checkup', 500.00, 5),
('a3333333-3333-3333-3333-333333333333', 'Pfizer Vaccination', 0.00, 5000),
('a4444444-4444-4444-4444-444444444444', 'Executive Screening', 800.00, 3),

-- Selangor Clinics
('b1111111-1111-1111-1111-111111111111', 'General Outpatient', 1.00, 80),
('b2222222-2222-2222-2222-222222222222', 'Pediatrics', 180.00, 12),
('b3333333-3333-3333-3333-333333333333', 'Dental Checkup', 50.00, 25),

-- Penang Clinics
('c1111111-1111-1111-1111-111111111111', 'Government Consultation', 1.00, 150),
('c2222222-2222-2222-2222-222222222222', 'Medical Tourism Package', 1200.00, 10),

-- Johor Clinics
('d1111111-1111-1111-1111-111111111111', 'Emergency Care', 1.00, 50),
('d2222222-2222-2222-2222-222222222222', 'Cardiology', 350.00, 8),

-- Sabah & Sarawak
('e1111111-1111-1111-1111-111111111111', 'General Ward', 1.00, 40),
('e2222222-2222-2222-2222-222222222222', 'Maternal Checkup', 1.00, 30),
('f1111111-1111-1111-1111-111111111111', 'General Surgery', 5.00, 5),
('f2222222-2222-2222-2222-222222222222', 'Oncology', 450.00, 6);
