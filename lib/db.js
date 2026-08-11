import { createClient } from '@supabase/supabase-js';
import { sanitizeSecret } from './sanitizeSecret.js';

let client = null;

function getClient() {
  if (client) return client;
  const url = sanitizeSecret(process.env.SUPABASE_URL);
  const key = sanitizeSecret(process.env.SUPABASE_SERVICE_ROLE_KEY);
  if (!url || !key) {
    throw new Error('SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY are not configured.');
  }
  client = createClient(url, key, { auth: { persistSession: false } });
  return client;
}

export async function listServices() {
  const db = getClient();
  const { data, error } = await db
    .from('services')
    .select('id, name_en, name_bn, icon, department_en, department_bn')
    .eq('is_active', true)
    .order('id');
  if (error) throw new Error(`listServices: ${error.message}`);
  return data;
}

export async function getServiceInfo(serviceId) {
  const db = getClient();

  const [service, offices, fees, documents, steps, forms, portals] = await Promise.all([
    db.from('services').select('*').eq('id', serviceId).maybeSingle(),
    db.from('offices').select('*').eq('service_id', serviceId),
    db.from('fees').select('*').eq('service_id', serviceId),
    db.from('required_documents').select('*').eq('service_id', serviceId).order('sort_order'),
    db.from('steps').select('*').eq('service_id', serviceId).order('step_number'),
    db.from('forms').select('*').eq('service_id', serviceId),
    db.from('online_portals').select('*').eq('service_id', serviceId),
  ]);

  for (const [label, res] of Object.entries({ service, offices, fees, documents, steps, forms, portals })) {
    if (res.error) throw new Error(`getServiceInfo(${serviceId}) ${label}: ${res.error.message}`);
  }

  if (!service.data) return null;

  const sourceIds = new Set();
  for (const rows of [offices.data, fees.data, documents.data, steps.data, forms.data]) {
    for (const row of rows) if (row.source_id) sourceIds.add(row.source_id);
  }
  const sources = sourceIds.size ? await getSourcesByIds(db, [...sourceIds]) : [];

  return {
    service: service.data,
    offices: offices.data,
    fees: fees.data,
    documents: documents.data,
    steps: steps.data,
    forms: forms.data,
    online_portals: portals.data,
    sources,
  };
}

// district/upazila match falls back to divisional, then national, then
// whatever office row exists — callers should check `match_level` and tell
// the user explicitly when the result isn't a precise local match.
export async function findNearestOffice(serviceId, district, upazila) {
  const db = getClient();
  const { data, error } = await db.from('offices').select('*').eq('service_id', serviceId);
  if (error) throw new Error(`findNearestOffice(${serviceId}): ${error.message}`);
  if (!data || data.length === 0) return null;

  const norm = (s) => (s || '').trim().toLowerCase();
  const normalizedDistrict = norm(district);
  const normalizedUpazila = norm(upazila);

  if (normalizedUpazila) {
    const match = data.find((o) => norm(o.upazila) === normalizedUpazila);
    if (match) return { ...match, match_level: 'upazila' };
  }
  if (normalizedDistrict) {
    const exact = data.find((o) => norm(o.district) === normalizedDistrict && !o.upazila);
    if (exact) return { ...exact, match_level: 'district' };
    const anyInDistrict = data.find((o) => norm(o.district) === normalizedDistrict);
    if (anyInDistrict) return { ...anyInDistrict, match_level: 'district' };
  }

  const divisional = data.find((o) => o.office_level === 'divisional');
  if (divisional) return { ...divisional, match_level: 'divisional_fallback' };

  const national = data.find((o) => o.office_level === 'national');
  if (national) return { ...national, match_level: 'national_fallback' };

  return { ...data[0], match_level: 'unmatched_fallback' };
}

async function getSourcesByIds(db, ids) {
  const { data, error } = await db.from('sources').select('*').in('id', ids);
  if (error) throw new Error(`getSourcesByIds: ${error.message}`);
  return data;
}
