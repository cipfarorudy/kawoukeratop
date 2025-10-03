import { useState } from "react";

const images = [
  { 
    src: "/images/produit-de-la-guadeloupe.png", 
    alt: "Produits de la Guadeloupe",
    title: "Produits Locaux",
    description: "Découvrez nos produits authentiques du terroir guadeloupéen"
  },
  { 
    src: "/images/livre-et-bibliotheque-de-guadeloupe.png", 
    alt: "Livres et Bibliothèques",
    title: "Patrimoine Littéraire",
    description: "Explorez notre riche héritage littéraire et nos bibliothèques"
  },
  { 
    src: "/images/artisanat-de-la-guadeloupe.png", 
    alt: "Artisanat",
    title: "Artisanat Traditionnel",
    description: "L'art de nos artisans transmis de génération en génération"
  },
  { 
    src: "/images/musique-de-la-guadeloupe.png", 
    alt: "Musique",
    title: "Rythmes Caribéens",
    description: "Vibrez au son du gwoka, zouk et musiques traditionnelles"
  },
  { 
    src: "/images/plat-local-de-la-guadeloupe.png", 
    alt: "Plats locaux",
    title: "Cuisine Créole",
    description: "Savourez les délices de notre gastronomie créole authentique"
  },
  { 
    src: "/images/kawoubiz.png", 
    alt: "Kawoubiz",
    title: "Kawoubiz",
    description: "Notre plateforme de promotion de l'économie locale"
  }
];

export default function Galerie() {
  const [hoveredIndex, setHoveredIndex] = useState(null);

  return (
    <section className="py-16 bg-white">
      <div className="max-w-6xl mx-auto px-4">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-gray-800 mb-4">
            🖼️ Galerie Culturelle
          </h2>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            Immergez-vous dans l'univers coloré et authentique de la Guadeloupe
          </p>
        </div>
        
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {images.map((img, i) => (
            <div 
              key={i} 
              className="group relative rounded-2xl overflow-hidden shadow-lg hover:shadow-2xl transition-all duration-500 transform hover:-translate-y-3"
              onMouseEnter={() => setHoveredIndex(i)}
              onMouseLeave={() => setHoveredIndex(null)}
            >
              {/* Image */}
              <div className="relative overflow-hidden">
                <img 
                  src={img.src} 
                  alt={img.alt} 
                  className="w-full h-64 object-cover transition-transform duration-700 group-hover:scale-110"
                  loading="lazy"
                />
                {/* Overlay gradient */}
                <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              </div>
              
              {/* Content overlay */}
              <div className={`absolute bottom-0 left-0 right-0 p-6 text-white transform transition-all duration-300 ${
                hoveredIndex === i 
                ? 'translate-y-0 opacity-100' 
                : 'translate-y-4 opacity-0'
              }`}>
                <h3 className="text-lg font-bold mb-2">{img.title}</h3>
                <p className="text-sm text-gray-200 leading-relaxed">{img.description}</p>
              </div>

              {/* Badge catégorie */}
              <div className="absolute top-4 left-4">
                <span className="bg-green-600 text-white px-3 py-1 rounded-full text-xs font-medium">
                  Guadeloupe
                </span>
              </div>

              {/* Effet de brillance au hover */}
              <div className="absolute inset-0 opacity-0 group-hover:opacity-20 transition-opacity duration-500 bg-gradient-to-r from-transparent via-white to-transparent transform -skew-x-12 -translate-x-full group-hover:translate-x-full"></div>
            </div>
          ))}
        </div>

        {/* Call to action */}
        <div className="text-center mt-12">
          <button className="bg-gradient-to-r from-green-600 to-blue-600 hover:from-green-700 hover:to-blue-700 text-white font-bold py-4 px-8 rounded-full transition-all duration-300 transform hover:scale-105 hover:shadow-lg">
            🔍 Voir plus d'images
          </button>
        </div>
      </div>
    </section>
  );
}