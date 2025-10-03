const images = [
  { src: "/images/produit-de-la-guadeloupe.png", alt: "Produits de la Guadeloupe" },
  { src: "/images/livre-et-bibliotheque-de-guadeloupe.png", alt: "Livres et Bibliothèques" },
  { src: "/images/artisanat-de-la-guadeloupe.png", alt: "Artisanat" },
  { src: "/images/musique-de-la-guadeloupe.png", alt: "Musique" },
  { src: "/images/plat-local-de-la-guadeloupe.png", alt: "Plats locaux" },
  { src: "/images/kawoubiz.png", alt: "Kawoubiz" }
];

export default function Galerie() {
  return (
    <section className="max-w-6xl mx-auto py-12 px-4">
      <h2 className="text-3xl font-bold mb-6 text-center">Galerie de la Guadeloupe</h2>
      <div className="grid grid-cols-2 md:grid-cols-3 gap-6">
        {images.map((img, i) => (
          <div key={i} className="rounded-xl overflow-hidden shadow-lg hover:scale-105 transition">
            <img src={img.src} alt={img.alt} className="w-full h-48 object-cover" />
          </div>
        ))}
      </div>
    </section>
  );
}