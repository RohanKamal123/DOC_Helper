import { listServices } from '../db.js';

export const schema = {
  type: 'function',
  function: {
    name: 'list_services',
    description:
      "List all Bangladesh government document services this assistant can help with, with their ids. Use this to map a user's free-text query to the correct service_id before calling get_service_info.",
    parameters: { type: 'object', properties: {}, required: [] },
  },
};

export async function handler() {
  const services = await listServices();
  return { services };
}
