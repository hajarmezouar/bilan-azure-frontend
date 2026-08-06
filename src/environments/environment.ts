export const environment = {
  production: true,
  apiBaseUrl: 'https://app-azure-quiz-backend-nonprod.azurewebsites.net/api',
  // Browser bundles cannot protect secrets. Authentication must be enforced
  // server-side or through an interactive identity flow, never a compiled key.
  apiKey: '',
};
