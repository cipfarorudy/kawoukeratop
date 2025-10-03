import { Routes, Route } from "react-router-dom";
import Topbar from "./components/Topbar";
import Header from "./components/Header";
import Footer from "./components/Footer";
import Home from "./pages/Home";
import About from "./pages/About";
import Contact from "./pages/Contact";

export default function App() {
  return (
    <div className="min-h-screen bg-white w-full flex flex-col">
      {/* Topbar fixe */}
      <div className="fixed top-0 left-0 right-0 z-40">
        <Topbar />
      </div>
      
      {/* Header fixe avec offset pour la topbar */}
      <Header />

      {/* Main content centré avec padding-top pour compenser le header fixe */}
      <main className="min-h-screen w-full flex-1 flex flex-col items-center">
        <div className="w-full max-w-full">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/about" element={<About />} />
            <Route path="/contact" element={<Contact />} />
          </Routes>
        </div>
      </main>

      <Footer />
    </div>
  );
}
