import { fileURLToPath, URL } from 'node:url';

import { defineConfig } from 'vite';
import vue2 from '@vitejs/plugin-vue2';

export default defineConfig({
  plugins: [
    vue2(),
  ],
  build: {
    lib: {
      entry: {
        issue_templates: '/scripts/issue_templates.js',
        template_fields: '/scripts/template_fields.js',
      },
      name: 'RemineIssueTemplates',
      formats: ['cjs'],
    },
    outDir: 'assets/javascripts',
  },
  resolve: {
    alias: {
      '^': fileURLToPath(new URL('./scripts', import.meta.url))
    }
  }
});
