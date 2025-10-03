export default function Topbar() {
  return (
    <div className="bg-green-900 text-white text-sm">
      <div className="max-w-6xl mx-auto px-4 py-2 flex items-center justify-between gap-3">
        {/* Gauche : coordonnées */}
        <div className="flex flex-wrap items-center gap-4">
          <a
            href="mailto:contact@kawoukeravore.com"
            className="hover:underline inline-flex items-center gap-2"
            aria-label="Envoyer un email à Kawoukeravore"
          >
            {/* icône email */}
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M20 4H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2Zm0 2v.01L12 13 4 6.01V6h16ZM4 18V8.236l7.384 6.153a1 1 0 0 0 1.232 0L20 8.236V18H4Z" />
            </svg>
            <span className="hidden sm:inline">contact@kawoukeravore.com</span>
            <span className="sm:hidden">Email</span>
          </a>

          <a
            href="tel:+590690000000"
            className="hover:underline inline-flex items-center gap-2"
            aria-label="Appeler Kawoukeravore"
          >
            {/* icône téléphone */}
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M6.62 10.79a15.46 15.46 0 0 0 6.59 6.59l2.2-2.2a1 1 0 0 1 1.02-.24c1.12.37 2.33.57 3.57.57a1 1 0 0 1 1 1V21a1 1 0 0 1-1 1C10.52 22 2 13.48 2 3a1 1 0 0 1 1-1h3.49a1 1 0 0 1 1 1c0 1.24.2 2.45.57 3.57a1 1 0 0 1-.25 1.02l-2.19 2.2Z"/>
            </svg>
            <span className="hidden sm:inline">+590 690 00 00 00</span>
            <span className="sm:hidden">Appeler</span>
          </a>
        </div>

        {/* Droite : infos rapides */}
        <div className="text-white/90 flex items-center gap-3">
          <span className="hidden md:inline">Guadeloupe</span>
          <span className="hidden md:inline">•</span>
          <span className="hidden md:inline">Lun-Sam 9h-18h</span>
          <a
            href="https://wa.me/590690000000"
            target="_blank"
            rel="noreferrer"
            className="rounded px-2 py-1 bg-green-700/70 hover:bg-green-700 transition"
            aria-label="Contacter via WhatsApp"
            title="WhatsApp"
          >
            WhatsApp
          </a>
        </div>
      </div>
    </div>
  );
}