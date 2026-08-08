-- All 12 services (ids/labels match the existing SERVICES array in index.html).
-- Only 'nid' and 'birth' have full detail rows seeded so far (Phase 1) —
-- the rest are listed here so list_services/api/services work immediately;
-- their offices/fees/documents/steps get filled in during Phase 3.

INSERT INTO services (id, name_en, name_bn, icon, department_en, department_bn, is_active) VALUES
  ('nid', 'National ID (NID)', 'জাতীয় পরিচয়পত্র', '🪪', 'NID Services Wing / EC', 'জাতীয় পরিচয়পত্র সেবা উইং / নির্বাচন কমিশন', true),
  ('birth', 'Birth Certificate', 'জন্মনিবন্ধন সনদ', '📋', 'Local Govt / City Corp', 'স্থানীয় সরকার / সিটি কর্পোরেশন', true),
  ('passport', 'Passport (MRP/e-Passport)', 'পাসপোর্ট', '🛂', 'Dept of Immigration', 'অভিবাসন ও পাসপোর্ট অধিদপ্তর', true),
  ('brta', 'Driving License / BRTA', 'ড্রাইভিং লাইসেন্স', '🚗', 'BRTA', 'বিআরটিএ', true),
  ('ssc', 'SSC Certificate', 'এসএসসি সনদ', '📜', 'Board of Education', 'শিক্ষা বোর্ড', true),
  ('hsc', 'HSC Certificate', 'এইচএসসি সনদ', '🎓', 'Board of Education', 'শিক্ষা বোর্ড', true),
  ('land', 'Land / Property Deed', 'জমির দলিল / খতিয়ান', '🏡', 'Sub-Registrar Office', 'সাব-রেজিস্ট্রার অফিস', true),
  ('trade', 'Trade License', 'ট্রেড লাইসেন্স', '🏪', 'City Corp / Pourashova', 'সিটি কর্পোরেশন / পৌরসভা', true),
  ('export', 'Export / Customs', 'রপ্তানি / কাস্টমস', '🚢', 'NBR / Customs', 'জাতীয় রাজস্ব বোর্ড / কাস্টমস', true),
  ('import', 'Import / LC', 'আমদানি / এলসি', '📦', 'NBR / Bangladesh Bank', 'জাতীয় রাজস্ব বোর্ড / বাংলাদেশ ব্যাংক', true),
  ('taxtin', 'TIN / Income Tax', 'টিআইএন / আয়কর', '🧾', 'NBR', 'জাতীয় রাজস্ব বোর্ড', true),
  ('police', 'Police Clearance', 'পুলিশ ক্লিয়ারেন্স', '🔏', 'Police HQ', 'পুলিশ সদর দপ্তর', true)
ON CONFLICT (id) DO NOTHING;
