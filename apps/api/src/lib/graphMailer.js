import "isomorphic-fetch";
import { Client } from "@microsoft/microsoft-graph-client";
import { ClientSecretCredential } from "@azure/identity";

/**
 * Configuration du client Microsoft Graph avec authentification OAuth2
 * @returns {Client} Client Microsoft Graph configuré
 */
export function graphClient() {
  const credential = new ClientSecretCredential(
    process.env.AZURE_TENANT_ID,
    process.env.AZURE_CLIENT_ID,
    process.env.AZURE_CLIENT_SECRET
  );

  return Client.init({
    authProvider: {
      getAccessToken: async () =>
        credential
          .getToken("https://graph.microsoft.com/.default")
          .then((t) => t.token),
    },
  });
}

/**
 * Envoi d'email via Microsoft Graph API
 * @param {Object} options - Options d'envoi
 * @param {string} options.from - Adresse d'expéditeur
 * @param {string} options.to - Adresse de destinataire
 * @param {string} options.subject - Sujet de l'email
 * @param {string} options.text - Contenu texte (optionnel)
 * @param {string} options.html - Contenu HTML (optionnel)
 * @param {string} options.replyTo - Adresse de réponse (optionnel)
 */
export async function sendGraphMail({
  from,
  to,
  subject,
  text,
  html,
  replyTo,
}) {
  try {
    const client = graphClient();

    const message = {
      message: {
        subject,
        from: { emailAddress: { address: from } },
        toRecipients: [{ emailAddress: { address: to } }],
        replyTo: replyTo ? [{ emailAddress: { address: replyTo } }] : [],
        body: {
          contentType: html ? "HTML" : "Text",
          content: html || text,
        },
      },
      saveToSentItems: true,
    };

    // Envoi "au nom de" l'adresse from
    await client.api(`/users/${from}/sendMail`).post(message);

    console.log(`📧 Email envoyé via Microsoft Graph de ${from} vers ${to}`);
  } catch (error) {
    console.error(`❌ Erreur envoi Microsoft Graph:`, error?.message || error);
    throw error;
  }
}

/**
 * Test de connexion Microsoft Graph
 * @returns {boolean} True si la connexion réussit
 */
export async function testGraphConnection() {
  try {
    const client = graphClient();
    const me = await client.api("/me").get();
    console.log(
      `✅ Connexion Microsoft Graph réussie pour: ${
        me.displayName || me.userPrincipalName
      }`
    );
    return true;
  } catch (error) {
    console.error(
      `❌ Échec test connexion Microsoft Graph:`,
      error?.message || error
    );
    return false;
  }
}
