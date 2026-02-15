-- Create Hotspots Table
CREATE TABLE public.hotspots (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    risk_level text CHECK (risk_level IN ('High', 'Medium', 'Low')),
    reported_cases int DEFAULT 0,
    radius_meters double precision DEFAULT 200.0,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.hotspots ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read hotspots
CREATE POLICY "Public hotspots are viewable by everyone" 
ON public.hotspots FOR SELECT 
USING (true);

-- Seed Data (Kuala Lumpur & Surroundings)
INSERT INTO public.hotspots (latitude, longitude, risk_level, reported_cases, radius_meters) VALUES
(3.1390, 101.6869, 'High', 45, 300.0), -- KL City Centre
(3.1579, 101.7116, 'Medium', 12, 150.0), -- KLCC Area
(3.0738, 101.5183, 'High', 30, 250.0), -- Shah Alam
(3.0470, 101.5857, 'Low', 3, 100.0), -- Subang Jaya
(3.1119, 101.6622, 'High', 67, 400.0), -- Mid Valley Area
(1.4927, 103.7414, 'High', 25, 200.0), -- Johor Bahru City
(5.4141, 100.3288, 'Medium', 15, 150.0); -- Georgetown, Penang
