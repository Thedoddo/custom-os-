/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'os-dark': '#0a0a0a',
        'os-darker': '#050505',
        'os-light': '#1a1a1a',
        'os-accent': '#6366f1',
        'os-accent-light': '#818cf8',
        'os-text': '#e5e5e5',
        'os-text-dim': '#a0a0a0',
      },
      fontFamily: {
        'sans': ['Inter', 'system-ui', 'sans-serif'],
      },
      backdropBlur: {
        'xl': '20px',
      },
      animation: {
        'pulse': 'pulse 6s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      }
    },
  },
  plugins: [],
}
