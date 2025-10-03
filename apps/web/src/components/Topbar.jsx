export default function Topbar() {
  return (
    <div className="bg-green-900 text-white text-xs md:text-sm relative z-50 w-full flex justify-center">
      <div className="w-full max-w-6xl mx-auto px-4 py-2 flex items-center justify-between gap-2">
        {/* Gauche : coordonnées avec animations */}
        <div className="flex flex-wrap items-center gap-2 md:gap-4">
          <a
            href="mailto:contact@kawoukeravore.top"
            className="hover:text-yellow-200 inline-flex items-center gap-1.5 transition-all duration-200 hover:scale-105"
            aria-label="Envoyer un email à Kawoukeravore"
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M20 4H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2Zm0 2v.01L12 13 4 6.01V6h16ZM4 18V8.236l7.384 6.153a1 1 0 0 0 1.232 0L20 8.236V18H4Z" />
            </svg>
            <span className="hidden sm:inline font-medium">contact@kawoukeravore.top</span>
            <span className="sm:hidden font-medium">Email</span>
          </a>

          <span className="hidden sm:inline text-green-300">|</span>

          <a
            href="tel:+590690000000"
            className="hover:text-yellow-200 inline-flex items-center gap-1.5 transition-all duration-200 hover:scale-105"
            aria-label="Appeler Kawoukeravore"
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M6.62 10.79a15.46 15.46 0 0 0 6.59 6.59l2.2-2.2a1 1 0 0 1 1.02-.24c1.12.37 2.33.57 3.57.57a1 1 0 0 1 1 1V21a1 1 0 0 1-1 1C10.52 22 2 13.48 2 3a1 1 0 0 1 1-1h3.49a1 1 0 0 1 1 1c0 1.24.2 2.45.57 3.57a1 1 0 0 1-.25 1.02l-2.19 2.2Z"/>
            </svg>
            <span className="hidden sm:inline font-medium">+590 690 00 00 00</span>
            <span className="sm:hidden font-medium">Tel</span>
          </a>
        </div>

        {/* Droite : infos et CTA */}
        <div className="flex items-center gap-2 md:gap-4">
          <div className="hidden lg:flex items-center gap-2 text-green-200 text-xs">
            <span>🏝️ Guadeloupe</span>
            <span>•</span>
            <span>🕒 Lun-Sam 9h-18h</span>
          </div>
          
          <a
            href="https://wa.me/590690000000"
            target="_blank"
            rel="noopener noreferrer"
            className="bg-green-600 hover:bg-green-500 text-white font-medium px-2 md:px-3 py-1 rounded-md transition-all duration-200 transform hover:scale-105 flex items-center gap-1.5 text-xs"
            aria-label="Contacter via WhatsApp"
          >
            <span>💬</span>
            <span className="hidden sm:inline">WhatsApp</span>
            <span className="sm:hidden">WA</span>
          </a>
        </div>
      </div>
    </div>
  );
}