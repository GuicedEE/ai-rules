#!/usr/bin/env node

/**
 * Terraform Registry Resource Fetcher
 * Fetches resource documentation from registry.terraform.io
 */

const https = require('https');

// Parse command line arguments
const args = process.argv.slice(2);
const provider = args.find(arg => arg.startsWith('--provider='))?.split('=')[1];
const resource = args.find(arg => arg.startsWith('--resource='))?.split('=')[1];
const version = args.find(arg => arg.startsWith('--version='))?.split('=')[1];

if (!provider) {
  console.error('Error: --provider is required');
  console.error('Usage: node fetch-resource.js --provider=<provider> [--resource=<resource>] [--version=<version>]');
  process.exit(1);
}

/**
 * Make HTTPS request
 */
function httpsGet(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode === 200) {
          try {
            resolve(JSON.parse(data));
          } catch (e) {
            reject(new Error(`Failed to parse JSON: ${e.message}`));
          }
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${data}`));
        }
      });
    }).on('error', (err) => {
      reject(err);
    });
  });
}

/**
 * Get latest provider version
 */
async function getLatestVersion(provider) {
  const url = `https://registry.terraform.io/v2/providers/hashicorp/${provider}/versions`;
  const data = await httpsGet(url);

  if (data.versions && data.versions.length > 0) {
    // Get the latest stable version (first in the list)
    return data.versions[0].version;
  }

  throw new Error(`No versions found for provider: ${provider}`);
}

/**
 * Get provider documentation
 */
async function getProviderDocs(provider, version) {
  const url = `https://registry.terraform.io/v2/providers/hashicorp/${provider}/${version}/docs`;
  return await httpsGet(url);
}

/**
 * Get specific resource documentation
 */
async function getResourceDocs(provider, version, resource) {
  const url = `https://registry.terraform.io/v2/providers/hashicorp/${provider}/${version}/docs/resources/${resource}`;
  return await httpsGet(url);
}

/**
 * Main execution
 */
async function main() {
  try {
    // Get version (use provided or fetch latest)
    const providerVersion = version || await getLatestVersion(provider);
    console.log(JSON.stringify({
      provider,
      version: providerVersion,
      status: 'fetching'
    }));

    if (resource) {
      // Fetch specific resource
      const resourceDocs = await getResourceDocs(provider, providerVersion, resource);
      console.log(JSON.stringify({
        provider,
        version: providerVersion,
        resource,
        data: resourceDocs
      }, null, 2));
    } else {
      // Fetch all provider docs
      const providerDocs = await getProviderDocs(provider, providerVersion);
      console.log(JSON.stringify({
        provider,
        version: providerVersion,
        data: providerDocs
      }, null, 2));
    }
  } catch (error) {
    console.error(JSON.stringify({
      error: error.message,
      provider,
      resource
    }));
    process.exit(1);
  }
}

main();
