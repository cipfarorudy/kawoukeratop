import Galerie from "../components/Galerie";

export default function Home() {
  return (
    <div>
      <section className="bg-white py-16 text-center">
        <h1 className="text-4xl font-bold text-green-800">Bienvenue sur Kawoukeravore</h1>
        <p className="mt-4 text-lg text-gray-600">
          Découvrez les richesses culturelles, culinaires et artisanales de la Guadeloupe.
        </p>
      </section>
      <Galerie />
    </div>
  );
}