import { useState } from "react";

export default function Contact() {
  const [form, setForm] = useState({ name: "", email: "", message: "" });
  const [status, setStatus] = useState(null);
  const [loading, setLoading] = useState(false);

  const onChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const onSubmit = async (e) => {
    e.preventDefault();
    setLoading(true); setStatus(null);
    try {
      const res = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (data.success) {
        setStatus({ ok: true, msg: "✅ Message envoyé !" });
        setForm({ name: "", email: "", message: "" });
      } else {
        setStatus({ ok: false, msg: "❌ Erreur d'envoi." });
      }
    } catch {
      setStatus({ ok: false, msg: "❌ Réseau indisponible." });
    } finally {
      setLoading(false);
    }
  };

  return (
    <section className="max-w-4xl mx-auto py-16 px-6 text-center">
      <h1 className="text-3xl font-bold text-green-800 mb-6">Contact</h1>
      <form onSubmit={onSubmit} className="grid gap-4 max-w-md mx-auto text-left">
        <input name="name" value={form.name} onChange={onChange} placeholder="Votre nom"
               className="p-3 border rounded" required minLength={2} />
        <input type="email" name="email" value={form.email} onChange={onChange} placeholder="Votre email"
               className="p-3 border rounded" required />
        <textarea name="message" value={form.message} onChange={onChange} placeholder="Votre message"
                  className="p-3 border rounded h-32" required minLength={10}></textarea>
        <button disabled={loading}
                className="bg-green-700 text-white py-2 px-4 rounded hover:bg-green-800 transition disabled:opacity-60">
          {loading ? "Envoi..." : "Envoyer"}
        </button>
      </form>
      {status && (
        <p className={`mt-4 ${status.ok ? "text-green-700" : "text-red-700"}`}>{status.msg}</p>
      )}
    </section>
  );
}