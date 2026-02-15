-- Create Appointments Table
CREATE TABLE public.appointments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    clinic_name text NOT NULL, -- Storing name for easier display, or use clinic_id if strict FK needed
    service_name text NOT NULL,
    appointment_time timestamptz NOT NULL,
    status text DEFAULT 'Confirmed',
    price double precision DEFAULT 0.0,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own appointments
CREATE POLICY "Users can see own appointments" 
ON public.appointments FOR SELECT 
USING (auth.uid() = user_id);

-- Policy: Users can create their own appointments
CREATE POLICY "Users can create own appointments" 
ON public.appointments FOR INSERT 
WITH CHECK (auth.uid() = user_id);
