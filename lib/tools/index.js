import * as listServicesTool from './listServices.js';
import * as getServiceInfoTool from './getServiceInfo.js';
import * as findNearestOfficeTool from './findNearestOffice.js';
import * as webSearchTool from './webSearch.js';

const registry = {
  list_services: listServicesTool,
  get_service_info: getServiceInfoTool,
  find_nearest_office: findNearestOfficeTool,
  web_search: webSearchTool,
};

export function getToolSchemas() {
  return Object.values(registry).map((t) => t.schema);
}

export async function callTool(name, args) {
  const tool = registry[name];
  if (!tool) throw new Error(`Unknown tool: ${name}`);
  return tool.handler(args);
}
