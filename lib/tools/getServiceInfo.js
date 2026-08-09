import { getServiceInfo } from '../db.js';
import { SERVICE_IDS } from '../serviceIds.js';

export const schema = {
  type: 'function',
  function: {
    name: 'get_service_info',
    description:
      'Get the full verified record for a Bangladesh government document service: offices, fees, required documents, steps, forms, online portals, and sources. Always call this before answering a question about a specific service — never state fees, offices, or documents from memory.',
    parameters: {
      type: 'object',
      properties: {
        service_id: {
          type: 'string',
          enum: SERVICE_IDS,
          description: 'The exact service id — must be one of the enum values. Call list_services first if you are not sure which one matches the user\'s question.',
        },
      },
      required: ['service_id'],
    },
  },
};

export async function handler({ service_id } = {}) {
  if (!service_id) return { error: 'service_id is required.' };
  if (!SERVICE_IDS.includes(service_id)) {
    return { error: `"${service_id}" is not a valid service_id. Valid ids: ${SERVICE_IDS.join(', ')}. Call list_services if unsure which one matches.` };
  }
  const info = await getServiceInfo(service_id);
  if (!info) return { error: `No record found for service_id "${service_id}". Call list_services to see valid ids.` };
  return info;
}
