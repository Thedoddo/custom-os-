const { defineConfig } = require('vite');
const react = require('@vitejs/plugin-react');

module.exports = defineConfig({
  plugins: [react()],
  base: './',
  server: {
    port: 5173,
    strictPort: false
  },
  build: {
    outDir: 'dist-vite',
    emptyOutDir: true
  }
});
