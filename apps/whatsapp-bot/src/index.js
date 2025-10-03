import "dotenv/config";
import pino from "pino";
import qrcode from "qrcode-terminal";
import pkg from "whatsapp-web.js";
const { Client, LocalAuth } = pkg;
import { sendToApi } from "./sendToApi.js";
import { extractMediaIfAny } from "./media.js";

// Configuration du logger
const logger = pino({
  transport: {
    target: "pino-pretty",
    options: {
      translateTime: true,
      colorize: true,
      ignore: "pid,hostname",
    },
  },
  level: process.env.LOG_LEVEL || "info",
});

// Configuration globale
const config = {
  baseUrl: process.env.API_BASE_URL,
  endpoint: process.env.API_WHATSAPP_ENDPOINT || "/api/whatsapp",
  secret: process.env.WHATSAPP_SHARED_SECRET || "",
  allowGroups: (process.env.ALLOW_GROUPS || "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean),
  blockWords: (process.env.BLOCK_WORDS || "")
    .split(",")
    .map((s) => s.trim().toLowerCase())
    .filter(Boolean),
  forwardMedia: (process.env.FORWARD_MEDIA || "true") === "true",
  mediaMaxBytes: Number(process.env.MEDIA_MAX_BYTES || 5 * 1024 * 1024), // 5MB par défaut
};

// Validation de la configuration
if (!config.baseUrl || !config.secret) {
  logger.error(
    "❌ API_BASE_URL et WHATSAPP_SHARED_SECRET sont requis dans le .env"
  );
  process.exit(1);
}

logger.info("📋 Configuration chargée", {
  apiUrl: config.baseUrl,
  endpoint: config.endpoint,
  allowGroups: config.allowGroups.length || "tous les groupes",
  blockWords: config.blockWords.length,
  forwardMedia: config.forwardMedia,
  maxMediaMB: Math.round(config.mediaMaxBytes / (1024 * 1024)),
});

// Initialisation du client WhatsApp
const client = new Client({
  authStrategy: new LocalAuth({
    dataPath: ".auth",
    clientId: "kawoukeravore-bot",
  }),
  puppeteer: {
    headless: true,
    args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--disable-dev-shm-usage",
      "--disable-accelerated-2d-canvas",
      "--no-first-run",
      "--no-zygote",
      "--disable-gpu",
    ],
  },
  webVersionCache: {
    type: "remote",
    remotePath:
      "https://raw.githubusercontent.com/wppconnect-team/wa-version/main/html/2.2412.54.html",
  },
});

// Gestionnaires d'événements
client.on("qr", (qr) => {
  logger.warn("📱 Scannez le QR code avec WhatsApp pour connecter le bot :");
  qrcode.generate(qr, { small: true });
});

client.on("ready", () => {
  logger.info("✅ Bot WhatsApp connecté et opérationnel !");
  logger.info("🔍 En attente de messages dans les groupes...");
});

client.on("authenticated", () => {
  logger.info("🔐 Authentification WhatsApp réussie");
});

client.on("auth_failure", (message) => {
  logger.error("❌ Échec de l'authentification WhatsApp", { message });
});

client.on("disconnected", (reason) => {
  logger.error("❌ Bot WhatsApp déconnecté", { reason });
});

client.on("message", async (msg) => {
  try {
    // Filtrer : groupes uniquement
    const isGroup = msg.from?.endsWith("@g.us");
    if (!isGroup) {
      logger.debug(
        { from: msg.from },
        "Message privé ignoré (groupes uniquement)"
      );
      return;
    }

    // Filtrer par liste blanche de groupes (optionnel)
    if (config.allowGroups.length && !config.allowGroups.includes(msg.from)) {
      logger.debug({ group: msg.from }, "Groupe non autorisé, message ignoré");
      return;
    }

    // Ignorer les messages système ou vides
    if (!msg.body && !msg.hasMedia) {
      logger.debug({ messageId: msg.id.id }, "Message système ou vide ignoré");
      return;
    }

    // Filtrage par mots interdits
    const text = (msg.body || "").toLowerCase();
    if (config.blockWords.some((word) => text.includes(word))) {
      logger.info(
        {
          group: msg.from,
          blockedWords: config.blockWords.filter((word) => text.includes(word)),
        },
        "Message filtré (BLOCK_WORDS)"
      );
      return;
    }

    // Récupération des informations du groupe et de l'auteur
    const chat = await msg.getChat();
    const groupName = chat?.name || msg.from;
    const contact = await msg.getContact();
    const authorName =
      contact?.pushname ||
      contact?.name ||
      contact?.number ||
      msg.author ||
      "Utilisateur anonyme";

    logger.debug(
      {
        groupName,
        authorName,
        hasMedia: msg.hasMedia,
      },
      "Traitement du message"
    );

    // Extraction des médias si autorisé
    let media = null;
    if (config.forwardMedia && msg.hasMedia) {
      media = await extractMediaIfAny(msg, logger);

      if (media && media.sizeBytes > config.mediaMaxBytes) {
        logger.warn(
          {
            sizeMB: Math.round(media.sizeBytes / (1024 * 1024)),
            maxMB: Math.round(config.mediaMaxBytes / (1024 * 1024)),
          },
          "Média trop volumineux, ignoré"
        );
        media = null;
      }
    }

    // Construction du payload pour l'API
    const payload = {
      provider: "whatsapp",
      type: media ? "media" : "text",
      groupId: msg.from,
      groupName,
      messageId: msg.id.id,
      timestamp: msg.timestamp
        ? new Date(msg.timestamp * 1000).toISOString()
        : new Date().toISOString(),
      author: {
        id: msg.author || contact?.id?._serialized,
        name: authorName,
      },
      content: msg.body || null,
      media: media
        ? {
            filename: media.filename,
            mimetype: media.mimetype,
            sizeBytes: media.sizeBytes,
            base64: media.base64,
          }
        : null,
    };

    // Envoi à l'API
    const response = await sendToApi({
      baseUrl: config.baseUrl,
      endpoint: config.endpoint,
      secret: config.secret,
      payload,
      logger,
    });

    if (response?.success) {
      logger.info(
        {
          group: groupName,
          author: authorName,
          type: payload.type,
          contentPreview: (payload.content || "").substring(0, 50) + "...",
        },
        "✅ Message relayé vers l'API Kawoukeravore"
      );
    } else {
      logger.error(
        {
          error: response?.error,
          statusCode: response?.statusCode,
        },
        "❌ Échec envoi vers l'API"
      );
    }
  } catch (error) {
    logger.error(
      {
        error: error.message,
        messageId: msg.id?.id,
      },
      "❌ Erreur lors du traitement du message"
    );
  }
});

// Gestion gracieuse de l'arrêt
process.on("SIGINT", async () => {
  logger.info("🛑 Arrêt du bot WhatsApp...");
  await client.destroy();
  process.exit(0);
});

process.on("SIGTERM", async () => {
  logger.info("🛑 Signal SIGTERM reçu, arrêt du bot...");
  await client.destroy();
  process.exit(0);
});

// Gestion des erreurs non capturées
process.on("unhandledRejection", (reason, promise) => {
  logger.error({ reason }, "Promesse rejetée non gérée");
});

process.on("uncaughtException", (error) => {
  logger.error({ error }, "Exception non capturée");
  process.exit(1);
});

// Démarrage du bot
logger.info("🚀 Démarrage du bot WhatsApp Kawoukeravore...");
client.initialize();
