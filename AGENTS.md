# AGENTS.md

Apollo Server integration for Hono, published to npm as `@conao3/apollo-server-integration-hono`. The README covers usage and commands.

## Conventions

- TypeScript (strict, `isolatedDeclarations`). No `class`: data is plain objects, behavior is pure functions.
- `src/index.ts` is the whole package. It depends only on `@apollo/server` and `hono` (peer dependencies) and Web standard APIs, so that it runs on every Hono runtime.
- Keep the Apollo Server integration test suite (`test/integration/`, Jest) passing in full. Cover Hono-specific behavior (the context, middleware headers) with Vitest in `test/unit/`.
- From the Nix devShell, run `vp run check` before committing.
- Commit messages, code comments, test names and documents are written in English.
- Release only with `gh workflow run release.yml --ref master -f version_bump=patch` (or `minor`, `major`). Do not edit `version` in `package.json` or push `v*` tags by hand.
