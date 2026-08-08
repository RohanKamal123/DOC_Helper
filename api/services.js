import { listServices } from '../lib/db.js';

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  try {
    const services = await listServices();
    res.status(200).json({ services });
  } catch (err) {
    console.error('api/services error:', err.message);
    res.status(500).json({ error: 'Could not load services.' });
  }
}
