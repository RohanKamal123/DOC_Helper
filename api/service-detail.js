import { getServiceInfo } from '../lib/db.js';
import { SERVICE_IDS } from '../lib/serviceIds.js';

// Direct DB read for the guided (button-driven) flow — deliberately bypasses
// the DeepSeek agent loop entirely. This path doesn't need an LLM: the user
// picked a known service_id from the UI, so there's nothing to interpret.
// Faster, free (no DeepSeek call), and can't hallucinate since it's a
// straight passthrough of lib/db.js's query result.
export default async function handler(req, res) {
  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const { service_id } = req.query || {};
  if (!service_id || !SERVICE_IDS.includes(service_id)) {
    res.status(400).json({ error: `Invalid or missing service_id. Valid ids: ${SERVICE_IDS.join(', ')}` });
    return;
  }

  try {
    const info = await getServiceInfo(service_id);
    if (!info) {
      res.status(404).json({ error: `No record found for service_id "${service_id}".` });
      return;
    }
    res.status(200).json(info);
  } catch (err) {
    console.error('api/service-detail error:', err.message);
    res.status(500).json({ error: 'Could not load service details. Please try again.' });
  }
}
