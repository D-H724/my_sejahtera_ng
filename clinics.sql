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

-- Seed Data: Clinics (Using valid UUIDv4)
INSERT INTO public.clinics (id, name, address, latitude, longitude, type, image_url) VALUES 
('11111111-1111-1111-1111-111111111111', 'Klinik Kesihatan Kuala Lumpur', 'Jalan Temerloh, Titiwangsa, 53200 KL', 3.1724, 101.7027, 'Clinic', 'https://via.placeholder.com/150'),
('22222222-2222-2222-2222-222222222222', 'Gleneagles Hospital KL', '282, Jalan Ampang, 50450 KL', 3.1578, 101.7371, 'Hospital', 'https://via.placeholder.com/150'),
('33333333-3333-3333-3333-333333333333', 'PPV World Trade Centre', '41, Jalan Tun Ismail, 50480 KL', 3.1691, 101.6912, 'PPV', 'https://via.placeholder.com/150');

-- Seed Data: Services (Linked to Clinics)
INSERT INTO public.clinic_services (clinic_id, service_name, price, available_slots) VALUES
('11111111-1111-1111-1111-111111111111', 'General Consultation', 1.00, 50),
('11111111-1111-1111-1111-111111111111', 'Vaccination (Booster)', 0.00, 100),
('22222222-2222-2222-2222-222222222222', 'Specialist Consultation', 150.00, 10),
('22222222-2222-2222-2222-222222222222', 'Health Screening (Premium)', 350.00, 5),
('33333333-3333-3333-3333-333333333333', 'Pfizer Vaccination', 0.00, 500),
('33333333-3333-3333-3333-333333333333', 'Sinovac Vaccination', 0.00, 200);
