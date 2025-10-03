import { Routes, Route } from "react-router-dom";
import Topbar from "./components/Topbar";
import Header from "./components/Header";
import Footer from "./components/Footer";
import Home from "./pages/Home";
import About from "./pages/About";
import Contact from "./pages/Contact";

export default function App() {
  return (
    <div className="min-h-screen bg-white">
      {/* Topbar fixe */}
      <div className="fixed top-0 left-0 right-0 z-40">
        <Topbar />
      </div>
      
      {/* Header fixe avec offset pour la topbar */}
      <Header />

      {/* Main content avec padding-top pour compenser le header fixe */}
      <main className="min-h-screen">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/contact" element={<Contact />} />
        </Routes>
      </main>

      <Footer />
    </div>
  );
}
