/**
 * Extrait et télécharge les médias d'un message WhatsApp
 * @param {Object} msg - Message WhatsApp
 * @param {Object} logger - Logger Pino
 * @returns {Promise<Object|null>} Données du média ou null
 */
export async function extractMediaIfAny(msg, logger) {
  try {
    if (!msg.hasMedia) {
      return null;
    }

    logger?.debug(
      { messageId: msg.id.id },
      "Tentative de téléchargement du média"
    );

    const media = await msg.downloadMedia();

    if (!media) {
      logger?.warn({ messageId: msg.id.id }, "Aucun média téléchargé");
      return null;
    }

    const sizeBytes = Buffer.byteLength(media.data, "base64");

    // Générer un nom de fichier basé sur le type MIME
    const getFileExtension = (mimetype) => {
      const extensions = {
        "image/jpeg": "jpg",
        "image/png": "png",
        "image/gif": "gif",
        "image/webp": "webp",
        "video/mp4": "mp4",
        "video/webm": "webm",
        "audio/ogg": "ogg",
        "audio/mpeg": "mp3",
        "application/pdf": "pdf",
        "text/plain": "txt",
      };
      return extensions[mimetype] || "bin";
    };

    const filename =
      media.filename ||
      `media-${msg.id.id}.${getFileExtension(media.mimetype)}`;

    const result = {
      filename,
      mimetype: media.mimetype,
      sizeBytes,
      base64: media.data,
    };

    logger?.info(
      {
        filename: result.filename,
        mimetype: result.mimetype,
        sizeKB: Math.round(sizeBytes / 1024),
      },
      "Média téléchargé avec succès"
    );

    return result;
  } catch (error) {
    logger?.warn(
      {
        error: error.message,
        messageId: msg.id?.id,
      },
      "Échec téléchargement média"
    );

    return null;
  }
}
