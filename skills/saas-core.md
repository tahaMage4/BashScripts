---
name: saas-core-development
description: Use this skill for writing backend, DB queries, UI components, background jobs, or database migrations in this project.
---

# SaaS Core Development Principles

You are operating as a Senior Full-Stack Engineer contributing to the ai_social_media_automation codebase. This repository is a multi-tenant social media automation SaaS with Next.js, Prisma, Mastra tooling, and a worker-based background processing architecture.

## Tech Stack (project facts)
- Frontend: Next.js 16 (App Router), React 19, TypeScript 5, Tailwind CSS, `shadcn` UI
- Backend: Next.js Route Handlers (API Routes) and server components
- ORM: Prisma (see `package.json` — `@prisma/client` and `prisma` are present)
- Vector search: `pgvector` (used alongside PostgreSQL; raw Prisma queries are acceptable for advanced vector ops)
- Background processing: `bullmq` + `redis` with multiple worker entrypoints under `features/*/workers` and `scripts/` (see `package.json` `workers` scripts)
- Storage: AWS S3 (`@aws-sdk/client-s3` in dependencies)
- Agent/observability tools: `mastra` and Mastra-related packages are present (see `mastra.duckdb` in repo root)
- Orchestration & LLM tooling: LangChain, OpenRouter, Runway and other model SDKs are installed

## Key Project Conventions and Mandates

1) Multi-tenancy / Data scoping (MANDATORY)
- All database reads, writes, updates and deletes MUST be explicitly scoped to `organizationId` to prevent cross-tenant leakage.
- Example anti-pattern: `prisma.contentDraft.findMany()`
- Example correct pattern: `prisma.contentDraft.findMany({ where: { organizationId } })`
- Use the shared helper where available (e.g. `features/multi-location/services/multi-location.service.ts`) which resolves `organizationId` from `businessId` when appropriate.

2) Background-first for heavy work (MANDATORY)
- Do not execute heavy GPU/AI calls, long-running transforms, video/image encoding, or external social API posting inside API route sync handlers.
- Enqueue work to BullMQ workers. API route should return `202 Accepted` with a job identifier and minimal metadata.
- Respect idempotency: design workers to be idempotent and safe to retry. Use `p-retry` or BullMQ retry policies for transient failures.

3) Type safety, input validation, and schemas
- Use strict TypeScript types (no `any`). Keep `tsconfig` strict settings in mind.
- Validate all external input with `zod` (request bodies, query params, and env vars). Many services in this repo already use Zod schemas.

4) Vector and RAG data rules
- Chunk text documents to <= 1000 characters with controlled overlap when ingesting into vector store.
- Use Prisma raw queries or dedicated vector helpers when specific `pgvector` operators are required.

5) Workers and deployment scripts
- Review `package.json` scripts before adding packages or scripts. This repo exposes many worker scripts (e.g. `worker:generation`, `worker:posting`, `workers`) — reuse them when possible.

6) Secrets and environment
- Never commit `.env` files. Use environment variables for API keys (OpenRouter, Runway, AWS, Stripe, Redis). Validate required env vars at start using Zod.

## Testing, Migrations, and Local Dev
- Prisma: use `npm run prisma:generate`, `npm run prisma:migrate` or `npm run prisma:push` depending on environment. `npm run setup` is available to `prisma generate && prisma migrate deploy`.
- Tests: run unit and integration tests with `npm run test` (Jest) and `npm run test:watch` for local dev.
- Dev server: `npm run dev` (Next.js)

## Practical examples
- Enqueue a content-generation job from an API route:

	- Validate request with Zod
	- Enqueue to BullMQ (return 202 and job id)

- Prisma query example (preferred):

	- `const drafts = await prisma.contentDraft.findMany({ where: { organizationId: orgId } })`

	- If you have only `businessId`, use the repository helper to resolve `organizationId` first.

## Terminal & Dependency Policies
- Always inspect `package.json` before adding dependencies.
- Prefer existing project libraries (`mastra`, `@mastra/*`, `@langchain/*`) over adding new ones for similar functionality.

---

If you'd like, I can also:
- run a quick repository scan for any files that still use un-scoped Prisma queries and prepare a short report,
- or commit this SKILL.md change and then run the project's lint/tests.
