export default function Footer() {
  return (
    <footer className="bg-green-900 text-white py-6 mt-12">
      <div className="max-w-6xl mx-auto text-center text-sm">
        © {new Date().getFullYear()} Kawoukeravore – Tous droits réservés
      </div>
    </footer>
  );
}