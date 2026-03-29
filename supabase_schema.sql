-- ============================================================
-- HIGH-TECH SENTINEL — SUPABASE DATABASE SCHEMA
-- Run this entire file in: Supabase Dashboard → SQL Editor
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── OWNERS TABLE ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.owners (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'Member',
  image_url     TEXT,
  is_active     BOOLEAN DEFAULT TRUE,
  face_embedding TEXT,              -- store face descriptor JSON here
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ─── ACCESS LOGS TABLE ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.access_logs (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  action      TEXT NOT NULL,        -- e.g. "Access Granted", "Manual Unlock"
  device_id   TEXT NOT NULL,
  status      TEXT NOT NULL CHECK (status IN ('success', 'failure', 'manual')),
  owner_name  TEXT,
  timestamp   TIMESTAMPTZ DEFAULT NOW()
);

-- ─── ALERTS TABLE ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.alerts (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type               TEXT NOT NULL DEFAULT 'failedAuth',
  title              TEXT NOT NULL,
  device_id          TEXT NOT NULL DEFAULT 'HUB-01',
  image_url          TEXT,
  camera_id          TEXT DEFAULT 'CAM_01_ENTRY',
  timestamp          TIMESTAMPTZ DEFAULT NOW(),
  dismissed          BOOLEAN DEFAULT FALSE,
  lockout_initiated  BOOLEAN DEFAULT FALSE
);

-- ─── SETTINGS TABLE (optional per-device config) ──────────────────────────────
CREATE TABLE IF NOT EXISTS public.settings (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  device_id   TEXT UNIQUE NOT NULL,
  config      JSONB DEFAULT '{}'::jsonb,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─── CAPTURED IMAGES TABLE ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.captured_images (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  alert_id    UUID REFERENCES public.alerts(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  camera_id   TEXT,
  captured_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── STORAGE BUCKETS ──────────────────────────────────────────────────────────
-- Run these separately in Storage section or use SQL below

INSERT INTO storage.buckets (id, name, public)
VALUES ('owner-images', 'owner-images', true)
ON CONFLICT DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('intruder-images', 'intruder-images', true)
ON CONFLICT DO NOTHING;

-- ─── ROW LEVEL SECURITY (RLS) ─────────────────────────────────────────────────
-- Enable RLS on all tables
ALTER TABLE public.owners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.access_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.captured_images ENABLE ROW LEVEL SECURITY;

-- Allow all operations with anon key (update for production with auth)
CREATE POLICY "Allow all for anon" ON public.owners
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for anon" ON public.access_logs
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for anon" ON public.alerts
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for anon" ON public.settings
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all for anon" ON public.captured_images
  FOR ALL USING (true) WITH CHECK (true);

-- Storage policies
CREATE POLICY "Public owner images" ON storage.objects
  FOR ALL USING (bucket_id = 'owner-images') WITH CHECK (bucket_id = 'owner-images');

CREATE POLICY "Public intruder images" ON storage.objects
  FOR ALL USING (bucket_id = 'intruder-images') WITH CHECK (bucket_id = 'intruder-images');

-- ─── REALTIME ─────────────────────────────────────────────────────────────────
-- Enable realtime for alerts and logs
ALTER PUBLICATION supabase_realtime ADD TABLE public.alerts;
ALTER PUBLICATION supabase_realtime ADD TABLE public.access_logs;

-- ─── SEED DATA (optional, for testing) ────────────────────────────────────────
INSERT INTO public.access_logs (action, device_id, status, owner_name, timestamp)
VALUES
  ('Access granted: Owner #1 (Main Hub)', 'HUB-01', 'success', 'Owner #1', NOW() - INTERVAL '2 hours'),
  ('Encryption key rotation completed', 'SENTINEL-X-9000', 'success', NULL, NOW() - INTERVAL '5 hours'),
  ('System diagnostic: All sensors nominal', 'SENTINEL-X-9000', 'success', NULL, NOW() - INTERVAL '9 hours')
ON CONFLICT DO NOTHING;