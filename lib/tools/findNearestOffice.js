import { findNearestOffice } from '../db.js';
import { SERVICE_IDS } from '../serviceIds.js';

export const schema = {
  type: 'function',
  function: {
    name: 'find_nearest_office',
    description:
      "Find the office handling a service nearest to a citizen's district (and upazila if known), instead of describing a generic national office. Use this whenever the user mentions their location. The result's match_level tells you how precise the match was ('upazila'/'district' = local match, '*_fallback' = no local office on file, say so explicitly rather than implying it's their local office).",
    parameters: {
      type: 'object',
      properties: {
        service_id: { type: 'string', enum: SERVICE_IDS, description: 'The exact service id — must be one of the enum values.' },
        district: { type: 'string', description: 'District name, e.g. "Dhaka".' },
        upazila: { type: 'string', description: 'Upazila name, if known.' },
      },
      required: ['service_id', 'district'],
    },
  },
};

export async function handler({ service_id, district, upazila } = {}) {
  if (!service_id || !district) return { error: 'service_id and district are required.' };
  if (!SERVICE_IDS.includes(service_id)) {
    return { error: `"${service_id}" is not a valid service_id. Valid ids: ${SERVICE_IDS.join(', ')}. Call list_services if unsure which one matches.` };
  }
  const office = await findNearestOffice(service_id, district, upazila);
  if (!office) return { error: `No office on file for service_id "${service_id}".` };
  return { office };
}
