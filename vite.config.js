import { fileURLToPath, URL } from 'node:url';

import { defineConfig } from 'vite';
import vue2 from '@vitejs/plugin-vue2';

export default defineConfig({
  plugins: [
    vue2(),
  ],
  build: {
    rollupOptions: {
      input: {
        issue_templates: '/scripts/issue_templates.js',
        template_fields: '/scripts/template_fields.js',
      },
      output: {
        entryFileNames: '[name].js'
      }
    },
    outDir: 'assets/javascripts',
  },
  resolve: {
    alias: {
      '^': fileURLToPath(new URL('./scripts', import.meta.url))
    }
  }
});
