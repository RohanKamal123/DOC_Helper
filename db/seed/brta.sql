-- Seed data for service_id = 'brta' (Driving License / BRTA).
-- Researched 2026-08-08. brta.gov.bd / bsp.brta.gov.bd fee schedule pages
-- were not directly scrapable during this pass; figures below are
-- cross-referenced from multiple independent secondary sources reporting
-- the same fee table (inclusive of 15% VAT). Re-verify against
-- bsp.brta.gov.bd before relying on exact amounts.

INSERT INTO sources (url, title, publisher, last_verified_date, notes) VALUES
  ('https://bsp.brta.gov.bd/?lan=en', 'BRTA Service Portal', 'brta.gov.bd', '2026-08-08',
   'Official BRTA e-service portal. Fee figures cross-referenced from multiple secondary sources as of verification date (fee schedule page itself not directly scraped). Re-verify before relying on exact amounts.');

-- Office (national-level placeholder: applicants apply to the BRTA Circle
-- Office covering their permanent/current address; district-specific rows
-- are Phase 3+ follow-up work).
INSERT INTO offices (service_id, office_level, name_en, name_bn, address_en, address_bn, source_id)
SELECT 'brta', 'national',
  'BRTA Circle Office (covering your permanent/current address)',
  'বিআরটিএ সার্কেল অফিস (আপনার স্থায়ী/বর্তমান ঠিকানা অনুযায়ী)',
  'Apply to the BRTA Circle Office for the district of your permanent or current address.',
  'আপনার স্থায়ী বা বর্তমান ঠিকানার জেলার বিআরটিএ সার্কেল অফিসে আবেদন করুন।',
  id
FROM sources WHERE url = 'https://bsp.brta.gov.bd/?lan=en';

-- Fees (VAT-inclusive, as commonly reported)
INSERT INTO fees (service_id, fee_type, amount_bdt, unit, notes_en, notes_bn, source_id)
SELECT 'brta', v.fee_type, v.amount_bdt, 'per application', v.notes_en, v.notes_bn, s.id
FROM (VALUES
  ('learner_single_class', 518, 'Learner license, single class (e.g. motorcycle or car), VAT included.', 'লার্নার লাইসেন্স, একক শ্রেণি (যেমন মোটরসাইকেল বা কার), ভ্যাটসহ।'),
  ('learner_two_class', 748, 'Learner license, two classes, VAT included.', 'লার্নার লাইসেন্স, দুই শ্রেণি, ভ্যাটসহ।'),
  ('smart_card_amateur_10yr', 4557, 'Non-professional (amateur) smart card license, 10-year validity, VAT included.', 'অপেশাদার স্মার্ট কার্ড লাইসেন্স, ১০ বছর মেয়াদ, ভ্যাটসহ।'),
  ('smart_card_professional_5yr', 2832, 'Professional license, 5-year validity, VAT included.', 'পেশাদার লাইসেন্স, ৫ বছর মেয়াদ, ভ্যাটসহ।'),
  ('renewal_amateur_10yr', 4212, 'Amateur license renewal, 10-year validity, VAT included.', 'অপেশাদার লাইসেন্স নবায়ন, ১০ বছর মেয়াদ, ভ্যাটসহ।'),
  ('renewal_professional_5yr', 2487, 'Professional license renewal, 5-year validity, VAT included.', 'পেশাদার লাইসেন্স নবায়ন, ৫ বছর মেয়াদ, ভ্যাটসহ।')
) AS v(fee_type, amount_bdt, notes_en, notes_bn)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://bsp.brta.gov.bd/?lan=en') AS s;

-- Required documents
INSERT INTO required_documents (service_id, document_en, document_bn, is_mandatory, applies_to, sort_order, source_id)
SELECT 'brta', v.document_en, v.document_bn, v.is_mandatory, v.applies_to, v.sort_order, s.id
FROM (VALUES
  ('Completed application form', 'পূরণকৃত আবেদনপত্র', true, 'all', 1),
  ('Medical certificate from a registered doctor', 'নিবন্ধিত ডাক্তারের মেডিকেল সার্টিফিকেট', true, 'all', 2),
  ('3 stamp-size + 1 passport-size photograph', '৩ কপি স্ট্যাম্প সাইজ + ১ কপি পাসপোর্ট সাইজ ছবি', true, 'all', 3),
  ('Attested photocopy of NID / Birth Certificate / Passport', 'এনআইডি/জন্মনিবন্ধন/পাসপোর্টের সত্যায়িত ফটোকপি', true, 'all', 4),
  ('Police verification report', 'পুলিশ যাচাই প্রতিবেদন', true, 'first_time', 5)
) AS v(document_en, document_bn, is_mandatory, applies_to, sort_order)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://bsp.brta.gov.bd/?lan=en') AS s;

-- Steps
INSERT INTO steps (service_id, step_number, title_en, title_bn, is_online, source_id)
SELECT 'brta', v.step_number, v.title_en, v.title_bn, v.is_online, s.id
FROM (VALUES
  (1, 'Apply online for a learner license at bsp.brta.gov.bd and pay the fee', 'bsp.brta.gov.bd এ অনলাইনে লার্নার লাইসেন্সের আবেদন করুন এবং ফি পরিশোধ করুন', true),
  (2, 'Take driving training (typically 2-3 months)', 'ড্রাইভিং প্রশিক্ষণ নিন (সাধারণত ২-৩ মাস)', false),
  (3, 'Sit for the written, oral, and field (practical) tests at the designated BRTA center', 'নির্ধারিত বিআরটিএ কেন্দ্রে লিখিত, মৌখিক ও ব্যবহারিক পরীক্ষায় অংশ নিন', false),
  (4, 'After passing, apply for the smart card license with required documents and fee at your Circle Office', 'পাশ করার পর প্রয়োজনীয় কাগজপত্র ও ফিসহ আপনার সার্কেল অফিসে স্মার্ট কার্ড লাইসেন্সের আবেদন করুন', false),
  (5, 'Provide biometrics (photo, signature, fingerprint)', 'বায়োমেট্রিক দিন (ছবি, স্বাক্ষর, আঙুলের ছাপ)', false),
  (6, 'Collect the smart card license after SMS notification', 'এসএমএস নোটিফিকেশনের পর স্মার্ট কার্ড লাইসেন্স সংগ্রহ করুন', false)
) AS v(step_number, title_en, title_bn, is_online)
CROSS JOIN (SELECT id FROM sources WHERE url = 'https://bsp.brta.gov.bd/?lan=en') AS s;

-- Online portal
INSERT INTO online_portals (service_id, portal_name, url, description_en, description_bn) VALUES
  ('brta', 'BRTA Service Portal', 'https://bsp.brta.gov.bd/?lan=en', 'Apply for learner/smart card licenses, renewals, and pay fees.', 'লার্নার/স্মার্ট কার্ড লাইসেন্স, নবায়ন এবং ফি পরিশোধের আবেদন করুন।');
