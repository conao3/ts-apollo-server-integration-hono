import { defineConfig, type ViteUserConfig } from "vite-plus"

export default defineConfig({
  fmt: {
    semi: false,
    singleQuote: false,
    trailingComma: "all",
    sortPackageJson: false,
  },
  lint: {
    categories: { correctness: "error", suspicious: "warn" },
    ignorePatterns: ["node_modules", "dist", ".direnv"],
    options: { typeAware: true, typeCheck: true },
  },
  test: {
    include: ["test/unit/**/*.test.ts"],
  },
  pack: [
    {
      entry: { index: "src/index.ts" },
      platform: "neutral",
      format: "esm",
      dts: true,
    },
    {
      entry: { server: "example/server.ts" },
      outDir: "example/dist",
      platform: "node",
      target: "node26",
      format: "esm",
      dts: false,
      deps: { alwaysBundle: [/.*/] },
      outExtensions: () => ({ js: ".mjs" }),
      outputOptions: { codeSplitting: false },
    },
  ],
  run: {
    tasks: {
      check: { command: "vp check && vp test && jest", cache: { untrackedEnv: ["TSRS_BINARY"] } },
    },
  },
} satisfies ViteUserConfig)
