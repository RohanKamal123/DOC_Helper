-- BD Document Helper — database schema (Supabase / Postgres)
-- Run this once against a fresh Supabase project (SQL Editor), then run
-- db/seed/*.sql to populate it.

-- Canonical fact source for every citable row. Every fact-bearing table below
-- points at a source_id so the frontend can show "Sources · সূত্র" with a URL
-- and a last-verified date instead of an unattributed claim.
CREATE TABLE sources (
  id SERIAL PRIMARY KEY,
  url TEXT NOT NULL,
  title TEXT,
  publisher TEXT,               -- e.g. 'nidw.gov.bd'
  last_verified_date DATE NOT NULL,
  notes TEXT
);

CREATE TABLE services (
  id TEXT PRIMARY KEY,          -- 'nid','birth','passport', ... matches the existing SERVICES ids in index.html
  name_en TEXT NOT NULL,
  name_bn TEXT NOT NULL,
  icon TEXT,
  department_en TEXT,
  department_bn TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE offices (
  id SERIAL PRIMARY KEY,
  service_id TEXT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  office_level TEXT NOT NULL CHECK (office_level IN ('national', 'divisional', 'district', 'upazila')),
  name_en TEXT NOT NULL,
  name_bn TEXT NOT NULL,
  division TEXT,
  district TEXT,                -- nullable for national-level rows
  upazila TEXT,                 -- nullable
  address_en TEXT,
  address_bn TEXT,
  phone TEXT,
  email TEXT,
  lat NUMERIC,
  lng NUMERIC,
  source_id INT REFERENCES sources(id)
);
CREATE INDEX idx_offices_service_location ON offices (service_id, district, upazila);

CREATE TABLE fees (
  id SERIAL PRIMARY KEY,
  service_id TEXT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  fee_type TEXT NOT NULL,       -- 'new' | 'renewal' | 'correction' | 'duplicate' | 'urgent' | ...
  amount_bdt NUMERIC NOT NULL,
  unit TEXT NOT NULL DEFAULT 'per application',
  notes_en TEXT,
  notes_bn TEXT,
  source_id INT REFERENCES sources(id)
);
CREATE INDEX idx_fees_service ON fees (service_id);

CREATE TABLE required_documents (
  id SERIAL PRIMARY KEY,
  service_id TEXT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  document_en TEXT NOT NULL,
  document_bn TEXT NOT NULL,
  is_mandatory BOOLEAN NOT NULL DEFAULT true,
  applies_to TEXT NOT NULL DEFAULT 'all', -- 'first_time' | 'renewal' | 'correction' | 'all'
  sort_order INT NOT NULL DEFAULT 0,
  source_id INT REFERENCES sources(id)
);
CREATE INDEX idx_documents_service ON required_documents (service_id);

CREATE TABLE steps (
  id SERIAL PRIMARY KEY,
  service_id TEXT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  step_number INT NOT NULL,
  title_en TEXT NOT NULL,
  title_bn TEXT NOT NULL,
  description_en TEXT,
  description_bn TEXT,
  is_online BOOLEAN NOT NULL DEFAULT false,
  source_id INT REFERENCES sources(id)
);
CREATE INDEX idx_steps_service ON steps (service_id, step_number);

CREATE TABLE forms (
  id SERIAL PRIMARY KEY,
  service_id TEXT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  form_name TEXT NOT NULL,
  form_number TEXT,
  download_url TEXT,
  source_id INT REFERENCES sources(id)
);
CREATE INDEX idx_forms_service ON forms (service_id);

CREATE TABLE online_portals (
  id SERIAL PRIMARY KEY,
  service_id TEXT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  portal_name TEXT NOT NULL,
  url TEXT NOT NULL,
  description_en TEXT,
  description_bn TEXT
);
CREATE INDEX idx_portals_service ON online_portals (service_id);
