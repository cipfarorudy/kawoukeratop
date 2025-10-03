import { Link } from "react-router-dom";
import Galerie from "../components/Galerie";

export default function Home() {
  return (
    <div>
      {/* Hero Section avec gradient et animation */}
      <section className="relative bg-gradient-to-br from-green-600 via-green-700 to-blue-600 text-white py-24 overflow-hidden">
        {/* Background Pattern */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute top-0 left-0 w-40 h-40 bg-white rounded-full -translate-x-20 -translate-y-20 animate-pulse"></div>
          <div className="absolute bottom-0 right-0 w-60 h-60 bg-white rounded-full translate-x-20 translate-y-20 animate-pulse delay-1000"></div>
          <div className="absolute top-1/2 left-1/4 w-20 h-20 bg-white rounded-full animate-bounce delay-500"></div>
        </div>
        
        <div className="relative max-w-6xl mx-auto px-4 text-center">
          <div className="animate-fade-in-up">
            <h1 className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-yellow-200 to-orange-200 bg-clip-text text-transparent">
              Kawoukeravore
            </h1>
            <p className="text-xl md:text-2xl mb-8 text-green-100 max-w-3xl mx-auto leading-relaxed">
              🌴 Découvrez les <span className="font-semibold text-yellow-200">richesses authentiques</span> de la Guadeloupe : 
              culture créole, artisanat local, gastronomie traditionnelle et trésors caribéens.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link 
                to="/about" 
                className="bg-yellow-400 hover:bg-yellow-300 text-green-800 font-bold py-4 px-8 rounded-full transition-all duration-300 transform hover:scale-105 hover:shadow-lg"
              >
                🔍 Explorer notre culture
              </Link>
              <Link 
                to="/contact" 
                className="bg-transparent border-2 border-white hover:bg-white hover:text-green-700 text-white font-bold py-4 px-8 rounded-full transition-all duration-300 transform hover:scale-105"
              >
                📞 Nous contacter
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Section Features */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-6xl mx-auto px-4">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-800 mb-4">
              🌺 La Guadeloupe authentique
            </h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              Plongez au cœur de notre archipel caribéen et explorez ses multiples facettes
            </p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-2">
              <div className="text-4xl mb-4">🍽️</div>
              <h3 className="text-xl font-bold text-green-700 mb-3">Gastronomie Créole</h3>
              <p className="text-gray-600">Savourez les saveurs uniques de nos plats traditionnels : accras, colombo, bokit et bien plus...</p>
            </div>
            
            <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-2">
              <div className="text-4xl mb-4">🎨</div>
              <h3 className="text-xl font-bold text-green-700 mb-3">Artisanat Local</h3>
              <p className="text-gray-600">Découvrez le savoir-faire de nos artisans : poterie, vannerie, sculpture et créations uniques...</p>
            </div>
            
            <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-2">
              <div className="text-4xl mb-4">🎵</div>
              <h3 className="text-xl font-bold text-green-700 mb-3">Culture & Musique</h3>
              <p className="text-gray-600">Vibrez au rythme du gwoka, zouk et découvrez notre patrimoine culturel riche et vivant...</p>
            </div>
          </div>
        </div>
      </section>

      {/* Section Newsletter */}
      <section className="py-12 bg-green-700 text-white">
        <div className="max-w-4xl mx-auto px-4 text-center">
          <h3 className="text-2xl md:text-3xl font-bold mb-4">
            📧 Restez connecté à la Guadeloupe
          </h3>
          <p className="text-lg text-green-100 mb-6">
            Recevez nos actualités culturelles et découvertes exclusives
          </p>
          <div className="flex flex-col sm:flex-row gap-4 max-w-md mx-auto">
            <input 
              type="email" 
              placeholder="votre@email.com"
              className="flex-1 px-4 py-3 rounded-lg text-gray-800 focus:outline-none focus:ring-2 focus:ring-yellow-400"
            />
            <button className="bg-yellow-400 hover:bg-yellow-300 text-green-800 font-bold py-3 px-6 rounded-lg transition-all duration-300 transform hover:scale-105">
              S'abonner
            </button>
          </div>
        </div>
      </section>

      <Galerie />
    </div>
  );
}