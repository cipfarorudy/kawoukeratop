import { useState } from "react";
import { Link } from "react-router-dom";

export default function Header() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <header className="bg-green-700 text-white shadow-md">
      <div className="max-w-6xl mx-auto flex justify-between items-center px-4 py-4">
        {/* Logo */}
        <h1 className="text-2xl font-bold">Kawoukeravore</h1>

        {/* Menu desktop */}
        <nav className="hidden md:flex space-x-6">
          <Link to="/" className="hover:underline">Accueil</Link>
          <Link to="/about" className="hover:underline">À propos</Link>
          <Link to="/contact" className="hover:underline">Contact</Link>
        </nav>

        {/* Bouton mobile */}
        <button
          onClick={() => setIsOpen(!isOpen)}
          className="md:hidden flex flex-col space-y-1"
        >
          <span className="block w-6 h-0.5 bg-white"></span>
          <span className="block w-6 h-0.5 bg-white"></span>
          <span className="block w-6 h-0.5 bg-white"></span>
        </button>
      </div>

      {/* Menu mobile */}
      <div
        className={`md:hidden bg-green-800 px-4 py-4 space-y-3 transform transition-all duration-300 ${
          isOpen ? "max-h-40 opacity-100" : "max-h-0 opacity-0 overflow-hidden"
        }`}
      >
        <Link to="/" className="block hover:underline" onClick={() => setIsOpen(false)}>Accueil</Link>
        <Link to="/about" className="block hover:underline" onClick={() => setIsOpen(false)}>À propos</Link>
        <Link to="/contact" className="block hover:underline" onClick={() => setIsOpen(false)}>Contact</Link>
      </div>
    </header>
  );
}