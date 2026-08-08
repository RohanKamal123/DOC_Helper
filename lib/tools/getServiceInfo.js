import { getServiceInfo } from '../db.js';

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
          description: 'The service id, e.g. "nid", "birth", "passport". Call list_services first if unsure.',
        },
      },
      required: ['service_id'],
    },
  },
};

export async function handler({ service_id } = {}) {
  if (!service_id) return { error: 'service_id is required.' };
  const info = await getServiceInfo(service_id);
  if (!info) return { error: `No record found for service_id "${service_id}". Call list_services to see valid ids.` };
  return info;
}
