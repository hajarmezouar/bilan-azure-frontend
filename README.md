# azure-quiz-frontend

Angular application to review Microsoft certifications (AZ-900 to start, AZ-104 next): review by
module or mock exam, accessible from a simple link (no account). Consumes the REST API of
[azure-quiz-backend](../azure-quiz-backend).


## Stack

- Angular 22 (standalone components, signals), Angular Material, ngx-translate (fr/en)
- Vitest (Angular CLI 22 native test runner)
- ESLint (`angular-eslint`) + Prettier, husky + lint-staged on pre-commit

## Application architecture

The frontend is the application's public entry point. It is compiled into
static files and hosted by Azure Static Web Apps. It communicates only with the
Spring Boot REST API over HTTPS.

![Azure Quiz frontend architecture](docs/application-architecture.png)

The editable draw.io source is available at
[`docs/application-architecture.drawio`](docs/application-architecture.drawio).

Main runtime flow:

```text
User browser
     |
     | HTTPS
     v
Angular frontend (Azure Static Web Apps)
     |
     | HTTPS REST API
     v
Spring Boot backend (Azure Linux Web App)
     |
     +--> private Azure data services
```

The frontend never receives database, Redis, Storage or Key Vault credentials.
Its production build receives the backend HTTPS URL through the deployment
workflow. Sensitive backend configuration remains in Azure Key Vault.

The complete infrastructure and its decisions are maintained in the
`bilan-azure-terraform` repository.

## Run locally

Prerequisites: Node 22+, and the backend (`azure-quiz-backend`) running on `http://localhost:8080`.

```bash
npm install
npm start   # http://localhost:4200, targets the API on localhost:8080 (see src/environments/environment.development.ts)
```

## Tests and quality

```bash
npm test           # Vitest
npm run test:coverage
npm run lint
npm run format:check
```

## Production build

```bash
npm run build:prod
```

Static output in `dist/azure-quiz-frontend/browser` (that's the folder to point to as
`output_location` when deploying to Azure Static Web Apps).

Before building for a real deployment, update `src/environments/environment.ts` with the deployed
backend API URL (`apiBaseUrl`).

## Planned continuous deployment

The frontend delivery pipeline will be implemented with GitHub Actions. A
change to the frontend must follow this sequence:

1. check out the signed commit;
2. install the declared Node and npm versions with dependency caching;
3. run `npm ci`;
4. run tests, linting and formatting checks;
5. scan the source, dependencies and repository for vulnerabilities or secrets;
6. inject the non-production backend URL during the ephemeral CI build;
7. run `npm run build:prod`;
8. deploy `dist/azure-quiz-frontend/browser` to Azure Static Web Apps;
9. execute an HTTPS availability check and a frontend-to-backend smoke test;
10. mark the workflow as failed so developers can see and diagnose any error.

Infrastructure is provisioned separately by Terraform. Pre-production and
production use the same build and deployment process; only environment-specific
configuration differs.

This section documents the target workflow. The GitHub Actions workflow is not
considered operational until its file, protected environment and successful run
have been added and verified.


## Structure

- `src/app/core` — models, services (`QuizApiService` for REST calls, `QuizSessionStore` for
  signal-based quiz session state)
- `src/app/features` — pages: `certifications` (home), `modules` (a certification's modules +
  starting a mock exam), `quiz` (question-by-question flow), `results` (final score)

## Out of scope for this repo

- Provisioning the Azure infrastructure (Static Web App, App Service, database).

## Repository governance and security

- commits are signed with SSH and must display the GitHub `Verified` badge;
- root `CODEOWNERS` assigns the Angular sources, npm manifests, container image
  and GitHub automation to `@hajarmezouar`;
- Dependabot checks npm, Docker and GitHub Actions dependencies weekly;
- the `Security` workflow runs Trivy and Gitleaks on every push and pull
  request.

Trivy checks dependencies, the Dockerfile, secrets and configuration issues.
Gitleaks scans the complete Git history. These controls do not depend on GitHub
native secret scanning, whose availability can vary with repository visibility
and the selected GitHub plan.
