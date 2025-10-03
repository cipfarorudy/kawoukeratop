import got from "got";

/**
 * Envoie un message à l'API Kawoukeravore
 * @param {Object} options - Options d'envoi
 * @param {string} options.baseUrl - URL de base de l'API
 * @param {string} options.endpoint - Endpoint à utiliser
 * @param {string} options.secret - Clé secrète partagée
 * @param {Object} options.payload - Données à envoyer
 * @param {Object} options.logger - Logger Pino
 * @returns {Promise<Object>} Réponse de l'API
 */
export async function sendToApi({
  baseUrl,
  endpoint,
  secret,
  payload,
  logger,
}) {
  const url = `${baseUrl.replace(/\/$/, "")}${endpoint}`;

  try {
    const response = await got
      .post(url, {
        json: payload,
        timeout: {
          request: 10_000, // 10 secondes
        },
        headers: {
          "Content-Type": "application/json",
          "X-WhatsApp-Secret": secret,
          "User-Agent": "Kawoukeravore-WhatsApp-Bot/1.0.0",
        },
      })
      .json();

    logger?.debug({ url, status: "success" }, "API request successful");
    return response;
  } catch (error) {
    const errorMessage =
      error?.response?.body || error?.message || "Unknown error";
    const statusCode = error?.response?.statusCode;

    logger?.error(
      {
        url,
        statusCode,
        error: errorMessage,
      },
      "API post failed"
    );

    return {
      success: false,
      error: errorMessage,
      statusCode,
    };
  }
}
