import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import { z } from "zod";
import dotenv from "dotenv";
import fs from "fs";
import path from "path";
import { sendGraphMail, testGraphConnection } from "./lib/graphMailer.js";

// Chargement des variables d'environnement
dotenv.config();

const app = express();

// Sécurité middleware
app.use(helmet());

// Rate limiting pour éviter le spam
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Maximum 5 emails par IP toutes les 15 minutes
  message: {
    success: false,
    error: "Trop de tentatives d'envoi. Veuillez réessayer dans 15 minutes.",
  },
});

// CORS configuration
app.use(
  cors({
    origin: [
      "http://localhost:5173",
      "http://localhost:5174",
      "http://localhost:5175",
      "http://localhost:5176",
      "https://black-island-0b83e3e03.1.azurestaticapps.net",
      "https://kawoukeravore.top",
      "https://www.kawoukeravore.top",
    ], // URLs du frontend Vite et Azure
    credentials: true,
  })
);

// Body parser
app.use(express.json({ limit: "1mb" }));

// Schema de validation avec Zod
const contactSchema = z.object({
  name: z
    .string()
    .min(2, "Le nom doit contenir au moins 2 caractères")
    .max(50, "Le nom ne peut pas dépasser 50 caractères")
    .regex(
      /^[a-zA-ZÀ-ÿ\s'-]+$/,
      "Le nom contient des caractères non autorisés"
    ),

  email: z
    .string()
    .email("Format d'email invalide")
    .max(100, "L'email ne peut pas dépasser 100 caractères"),

  message: z
    .string()
    .min(10, "Le message doit contenir au moins 10 caractères")
    .max(1000, "Le message ne peut pas dépasser 1000 caractères"),
});

// Configuration Microsoft Graph Email
const validateGraphConfig = () => {
  const requiredVars = [
    "AZURE_TENANT_ID",
    "AZURE_CLIENT_ID",
    "AZURE_CLIENT_SECRET",
    "GRAPH_SENDER",
    "MAIL_TO",
  ];
  const missing = requiredVars.filter((v) => !process.env[v]);
  if (missing.length > 0) {
    console.warn(
      `⚠️ Variables d'environnement manquantes pour Microsoft Graph: ${missing.join(
        ", "
      )}`
    );
    return false;
  }
  return true;
};

// Route pour l'envoi d'emails via Microsoft Graph
app.post("/api/contact", limiter, async (req, res) => {
  try {
    // Validation des données avec Zod
    const validatedData = contactSchema.parse(req.body);
    const { name, email, message } = validatedData;

    // Vérification de la configuration Microsoft Graph
    if (!validateGraphConfig()) {
      console.error("❌ Configuration Microsoft Graph manquante");
      return res.status(500).json({
        success: false,
        error: "Configuration du serveur email manquante",
      });
    }

    // Envoi via Microsoft Graph
    await sendGraphMail({
      from: process.env.GRAPH_SENDER,
      to: process.env.MAIL_TO,
      subject:
        process.env.MAIL_SUBJECT ||
        `[Kawoukeravore] Nouveau message de ${name}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #15803d; border-bottom: 2px solid #15803d; padding-bottom: 10px;">
            📧 Nouveau message depuis Kawoukeravore
          </h2>
          
          <div style="background-color: #f0f9ff; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <p><strong>👤 Nom:</strong> ${name}</p>
            <p><strong>📧 Email:</strong> 
              <a href="mailto:${email}" style="color: #15803d;">${email}</a>
            </p>
            <p><strong>📅 Date:</strong> ${new Date().toLocaleString(
              "fr-FR"
            )}</p>
          </div>

          <div style="background-color: #ffffff; padding: 20px; border-left: 4px solid #15803d; margin: 20px 0;">
            <h3 style="color: #15803d; margin-top: 0;">💬 Message:</h3>
            <p style="line-height: 1.6; color: #333;">${message.replace(
              /\n/g,
              "<br>"
            )}</p>
          </div>

          <footer style="text-align: center; padding: 20px; color: #666; font-size: 12px;">
            <p>Cet email a été envoyé depuis le site web Kawoukeravore</p>
          </footer>
        </div>
      `,
      replyTo: email,
    });

    console.log(
      `✅ Email envoyé avec succès via Microsoft Graph de ${name} (${email})`
    );
    res.json({
      success: true,
      message:
        "Votre message a été envoyé avec succès ! Nous vous répondrons bientôt.",
    });
  } catch (error) {
    // Gestion des erreurs de validation Zod
    if (error instanceof z.ZodError) {
      const errorMessages = error.errors.map((err) => err.message).join(", ");
      console.log(`❌ Validation error: ${errorMessages}`);
      return res.status(400).json({
        success: false,
        error: `Données invalides: ${errorMessages}`,
      });
    }

    // Autres erreurs
    console.error("❌ Erreur serveur:", error);
    res.status(500).json({
      success: false,
      error:
        "Une erreur est survenue lors de l'envoi de votre message. Veuillez réessayer.",
    });
  }
});

// Route de santé
app.get("/api/health", (req, res) => {
  res.json({
    status: "OK",
    message: "🚀 API Kawoukeravore opérationnelle",
    timestamp: new Date().toISOString(),
    version: "1.0.0",
  });
});

// Route de test Microsoft Graph (pour développement)
app.get("/api/test-graph", async (req, res) => {
  try {
    if (!validateGraphConfig()) {
      return res.status(500).json({
        success: false,
        error: "Configuration Microsoft Graph manquante",
      });
    }

    const isConnected = await testGraphConnection();
    res.json({
      success: true,
      connected: isConnected,
      message: isConnected
        ? "Microsoft Graph connecté"
        : "Échec connexion Microsoft Graph",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: "Erreur test Microsoft Graph",
      details: error.message,
    });
  }
});

// Schéma de validation pour les messages WhatsApp
const WhatsAppMessageSchema = z.object({
  provider: z.string().min(1),
  type: z.enum(["text", "media"]),
  groupId: z.string().min(1),
  groupName: z.string().min(1),
  messageId: z.string().min(1),
  timestamp: z.string().datetime(),
  author: z.object({
    id: z.string().optional(),
    name: z.string().min(1),
  }),
  content: z.string().nullable(),
  media: z
    .object({
      filename: z.string().min(1),
      mimetype: z.string().min(1),
      sizeBytes: z.number().positive(),
      base64: z.string().min(1),
    })
    .nullable(),
});

// Rate limiter spécifique pour WhatsApp (plus permissif que le contact)
const whatsappLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 50, // Maximum 50 messages par IP toutes les 5 minutes
  message: {
    success: false,
    error: "Trop de messages WhatsApp. Veuillez ralentir.",
  },
});

// Route d'ingestion des messages WhatsApp
app.post("/api/whatsapp", whatsappLimiter, async (req, res) => {
  try {
    // Vérification de sécurité par clé partagée
    const authHeader = req.get("X-WhatsApp-Secret");
    if (!authHeader || authHeader !== process.env.WHATSAPP_SHARED_SECRET) {
      console.log(
        `❌ Tentative d'accès WhatsApp non autorisée depuis ${req.ip}`
      );
      return res.status(401).json({
        success: false,
        error: "Non autorisé",
      });
    }

    // Validation du payload avec Zod
    const validatedData = WhatsAppMessageSchema.parse(req.body);

    const {
      provider,
      type,
      groupId,
      groupName,
      messageId,
      timestamp,
      author,
      content,
      media,
    } = validatedData;

    // TODO: Déduplication en base de données (messageId unique)
    // Exemple simple en mémoire pour éviter les doublons immédiats
    // if (recentMessageIds.has(messageId)) {
    //   return res.json({ success: true, message: "Déjà traité" });
    // }

    // Sauvegarde du média si présent
    let savedMediaPath = null;
    if (media?.base64 && media?.mimetype && process.env.STORE_MEDIA_DIR) {
      try {
        const ext = (media.mimetype.split("/")[1] || "bin").replace(
          /[^a-z0-9]/gi,
          ""
        );
        const filename = `${Date.now()}-${messageId}.${ext}`;
        const mediaDir = process.env.STORE_MEDIA_DIR;

        // Créer le dossier si nécessaire
        fs.mkdirSync(mediaDir, { recursive: true });

        const fullPath = path.join(mediaDir, filename);
        fs.writeFileSync(fullPath, Buffer.from(media.base64, "base64"));

        savedMediaPath = `/media/${filename}`;

        console.log(
          `📁 Média sauvegardé: ${savedMediaPath} (${Math.round(
            media.sizeBytes / 1024
          )} KB)`
        );
      } catch (error) {
        console.warn(`⚠️ Échec sauvegarde média: ${error.message}`);
      }
    }

    // TODO: Insertion en base de données
    // await db.insert("whatsapp_posts", {
    //   provider, type, groupId, groupName, messageId, timestamp,
    //   authorId: author.id, authorName: author.name, content,
    //   mediaPath: savedMediaPath, createdAt: new Date()
    // });

    // Logging pour le moment (remplacer par BDD en production)
    console.log("📱 WHATSAPP MESSAGE:", {
      groupName,
      author: author.name,
      type,
      contentPreview: content
        ? `"${content.substring(0, 100)}${content.length > 100 ? "..." : ""}"`
        : null,
      hasMedia: !!savedMediaPath,
      timestamp,
    });

    return res.json({
      success: true,
      message: "Message WhatsApp traité avec succès",
      savedMediaPath,
    });
  } catch (error) {
    // Gestion des erreurs de validation Zod
    if (error instanceof z.ZodError) {
      console.log("❌ Données WhatsApp invalides:", error.errors);
      return res.status(400).json({
        success: false,
        error: "Données invalides",
        details: error.errors,
      });
    }

    console.error("❌ Erreur serveur WhatsApp:", error.message || error);
    return res.status(500).json({
      success: false,
      error: "Erreur interne du serveur",
    });
  }
});

// Route 404 pour l'API
app.use("/api/*", (req, res) => {
  res.status(404).json({
    success: false,
    error: "Route API non trouvée",
  });
});

// Middleware de gestion globale des erreurs
app.use((err, req, res, next) => {
  console.error("❌ Erreur non gérée:", err);
  res.status(500).json({
    success: false,
    error: "Erreur interne du serveur",
  });
});

const PORT = process.env.PORT || 4000;
const server = app.listen(PORT, async () => {
  console.log(`🚀 API Kawoukeravore démarrée sur http://localhost:${PORT}`);
  console.log(
    `📧 Microsoft Graph configuré: ${
      process.env.GRAPH_SENDER || "❌ Non configuré"
    }`
  );
  console.log(
    `📬 Destination: ${process.env.MAIL_TO || "contact@kawoukeravore.top"}`
  );
  console.log(
    `🏢 Tenant: ${
      process.env.AZURE_TENANT_ID ? "✅ Configuré" : "❌ Non configuré"
    }`
  );
  console.log(`⏰ ${new Date().toLocaleString("fr-FR")}`);

  // Test de connexion Microsoft Graph (optionnel)
  if (validateGraphConfig()) {
    console.log("🔍 Test de connexion Microsoft Graph...");
    // Le test sera fait uniquement si toutes les variables sont présentes
  }
});

// Gestion propre de l'arrêt du serveur
process.on("SIGTERM", () => {
  console.log("🛑 Signal SIGTERM reçu, arrêt propre du serveur...");
  server.close(() => {
    console.log("✅ Serveur arrêté proprement");
    process.exit(0);
  });
});

export default app;
