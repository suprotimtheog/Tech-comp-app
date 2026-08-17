const axios = require('axios');

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  const query = (req.query.q || '').trim();
  if (!query) {
    return res.status(400).json({ error: 'Query parameter "q" is required' });
  }

  try {
    // Dynamically query a public mobile specifications index
    const apiUrl = `https://api-mobilespecs.azharimm.dev/search?query=${encodeURIComponent(query)}`;
    
    const response = await axios.get(apiUrl, { timeout: 8000 });
    const data = response.data;

    if (!data || !data.data || !data.data.phones || data.data.phones.length === 0) {
      return res.status(200).json([]);
    }

    // Grab the first matching phone's slug/detail URL from the public index
    const phoneDetail = data.data.phones[0];
    const detailUrl = phoneDetail.detail; // e.g., points to full specs

    // Fetch deep specs for that specific phone dynamically
    const detailResponse = await axios.get(detailUrl, { timeout: 8000 });
    const details = detailResponse.data.data;

    // Map the public API fields into your app's exact Device structure
    const getSpecValue = (specsArray, keyName) => {
      if (!specsArray) return 'N/A';
      for (const specGroup of specsArray) {
        if (specGroup.key === keyName && specGroup.val && specGroup.val.length > 0) {
          return specGroup.val.join(', ');
        }
      }
      return 'N/A';
    };

    const specs = details.specifications || [];

    const device = {
      id: details.phone_name ? details.phone_name.toLowerCase().replace(/[^a-z0-9]/g, '_') : 'unknown',
      name: details.phone_name || query,
      brand: details.brand || 'Unknown',
      image: details.thumbnail || '',
      price: 'N/A',
      processor: getSpecValue(specs, 'Platform'),
      ram: getSpecValue(specs, 'Memory'),
      storage: getSpecValue(specs, 'Memory'),
      battery: getSpecValue(specs, 'Battery'),
      camera: getSpecValue(specs, 'Main Camera'),
      display: getSpecValue(specs, 'Display'),
    };

    return res.status(200).json([device]);
  } catch (error) {
    return res.status(500).json({ error: 'Failed to fetch dynamic specs', details: error.message });
  }
};