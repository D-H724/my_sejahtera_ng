-- 1. Add Security Columns to Profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS security_question text,
ADD COLUMN IF NOT EXISTS security_answer text;

-- 2. Update Handle New User Trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, username, ic_number, phone, security_question, security_answer)
  VALUES (
    new.id, 
    new.raw_user_meta_data->>'full_name', 
    new.raw_user_meta_data->>'username',
    new.raw_user_meta_data->>'ic_number',
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'security_question',
    new.raw_user_meta_data->>'security_answer'
  );
  
  INSERT INTO public.user_progress (user_id)
  VALUES (new.id);
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. RPC to Get Security Question (Unauthenticated access allowed for this specific purpose)
CREATE OR REPLACE FUNCTION public.get_security_question(email_input text)
RETURNS text AS $$
DECLARE
  question text;
BEGIN
  -- We look up the question from the profiles table by joining with auth.users to find the ID for the email
  -- This requires SECURITY DEFINER to access auth.users
  SELECT p.security_question INTO question
  FROM public.profiles p
  JOIN auth.users u ON u.id = p.id
  WHERE u.email = email_input;
  
  RETURN question;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. RPC to Verify Security Answer
CREATE OR REPLACE FUNCTION public.verify_security_answer(email_input text, answer_input text)
RETURNS boolean AS $$
DECLARE
  is_correct boolean;
BEGIN
  SELECT (p.security_answer = answer_input) INTO is_correct
  FROM public.profiles p
  JOIN auth.users u ON u.id = p.id
  WHERE u.email = email_input;
  
  RETURN COALESCE(is_correct, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
