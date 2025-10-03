import { useState, useEffect } from "react";
import { Link, useLocation } from "react-router-dom";

export default function Header() {
  const [isOpen, setIsOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const location = useLocation();

  // Gestion du scroll pour effet de transparence
  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 50);
    };
    
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Fermer le menu mobile lors du changement de page
  useEffect(() => {
    setIsOpen(false);
  }, [location]);

  const navigationItems = [
    { to: "/", label: "🏠 Accueil", emoji: "🏠" },
    { to: "/about", label: "ℹ️ À propos", emoji: "ℹ️" },
    { to: "/contact", label: "📞 Contact", emoji: "📞" }
  ];

  return (
    <header className={`fixed top-10 left-0 right-0 z-40 transition-all duration-300 flex justify-center ${
      scrolled 
        ? 'bg-green-700/95 backdrop-blur-md shadow-lg' 
        : 'bg-green-700 shadow-md'
    }`}>
      <div className="w-full max-w-6xl mx-auto flex justify-between items-center px-4 py-4">
        {/* Logo avec animation */}
        <Link to="/" className="group">
          <div className="flex items-center space-x-2">
            <div className="text-2xl animate-bounce">🌴</div>
            <h1 className="text-2xl font-bold bg-gradient-to-r from-yellow-200 to-orange-200 bg-clip-text text-transparent group-hover:scale-105 transition-transform duration-200">
              Kawoukeravore
            </h1>
          </div>
        </Link>

        {/* Menu desktop avec animations */}
        <nav className="hidden md:flex space-x-1">
          {navigationItems.map((item) => (
            <Link 
              key={item.to}
              to={item.to} 
              className={`relative px-4 py-2 rounded-lg transition-all duration-200 hover:bg-white/10 ${
                location.pathname === item.to 
                  ? 'bg-white/20 text-yellow-200' 
                  : 'text-white hover:text-yellow-200'
              }`}
            >
              <span className="flex items-center space-x-2">
                <span>{item.emoji}</span>
                <span className="font-medium">{item.label.split(' ').slice(1).join(' ')}</span>
              </span>
              {/* Indicateur de page active */}
              {location.pathname === item.to && (
                <div className="absolute bottom-0 left-1/2 transform -translate-x-1/2 w-2 h-2 bg-yellow-400 rounded-full"></div>
              )}
            </Link>
          ))}
        </nav>

        {/* Bouton CTA desktop */}
        <div className="hidden md:flex items-center space-x-4">
          <a
            href="https://wa.me/590690000000"
            target="_blank"
            rel="noopener noreferrer"
            className="bg-yellow-400 hover:bg-yellow-300 text-green-800 font-bold py-2 px-4 rounded-full transition-all duration-200 transform hover:scale-105 flex items-center space-x-2"
          >
            <span>💬</span>
            <span>WhatsApp</span>
          </a>
        </div>

        {/* Bouton hamburger mobile animé */}
        <button
          onClick={() => setIsOpen(!isOpen)}
          className="md:hidden relative w-8 h-8 flex flex-col justify-center items-center group"
          aria-label="Menu mobile"
        >
          <span className={`block w-6 h-0.5 bg-white transition-all duration-300 ${
            isOpen ? 'rotate-45 translate-y-0.5' : ''
          }`}></span>
          <span className={`block w-6 h-0.5 bg-white transition-all duration-300 mt-1 ${
            isOpen ? 'opacity-0' : ''
          }`}></span>
          <span className={`block w-6 h-0.5 bg-white transition-all duration-300 mt-1 ${
            isOpen ? '-rotate-45 -translate-y-1.5' : ''
          }`}></span>
        </button>
      </div>

      {/* Menu mobile avec animations améliorées */}
      <div
        className={`md:hidden bg-gradient-to-b from-green-800 to-green-900 transition-all duration-300 overflow-hidden ${
          isOpen ? "max-h-96 opacity-100" : "max-h-0 opacity-0"
        }`}
      >
        <div className="px-4 py-6 space-y-4">
          {navigationItems.map((item, index) => (
            <Link 
              key={item.to}
              to={item.to} 
              className={`block py-3 px-4 rounded-lg transition-all duration-200 hover:bg-white/10 ${
                location.pathname === item.to 
                  ? 'bg-white/20 text-yellow-200' 
                  : 'text-white hover:text-yellow-200'
              }`}
              style={{ animationDelay: `${index * 100}ms` }}
            >
              <div className="flex items-center space-x-3">
                <span className="text-xl">{item.emoji}</span>
                <span className="font-medium">{item.label.split(' ').slice(1).join(' ')}</span>
              </div>
            </Link>
          ))}
          
          {/* CTA WhatsApp mobile */}
          <div className="pt-4 border-t border-white/20">
            <a
              href="https://wa.me/590690000000"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center justify-center space-x-2 bg-yellow-400 hover:bg-yellow-300 text-green-800 font-bold py-3 px-4 rounded-lg transition-all duration-200"
            >
              <span>💬</span>
              <span>Contactez-nous sur WhatsApp</span>
            </a>
          </div>
        </div>
      </div>
    </header>
  );
}