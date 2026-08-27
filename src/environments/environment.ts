export const environment = {
  production: true,
  apiBaseUrl: 'https://REPLACE_WITH_PROD_API_URL/api',
  // Browser bundles cannot protect secrets. Authentication must be enforced
  // server-side or through an interactive identity flow, never a compiled key.
  apiKey: '',
};
