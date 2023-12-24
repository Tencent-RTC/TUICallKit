import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import basicSsl from '@vitejs/plugin-basic-ssl' 

// https://vitejs.dev/config/
export default defineConfig({
  base: './',
  plugins: [
    // basicSsl(),
    react()],
  server: {
    // port: 9999,
    host: "0.0.0.0"
  },
})
