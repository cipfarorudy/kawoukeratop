export default {
  apps: [
    {
      name: "kawou-whatsapp-bot",
      script: "src/index.js",
      cwd: "./",
      env: {
        NODE_ENV: "production",
      },
      time: true,
      max_restarts: 20,
      restart_delay: 5000,
      watch: false,
      ignore_watch: [".auth", "node_modules", ".git"],
      log_file: "/var/log/pm2/kawou-whatsapp-bot.log",
      error_file: "/var/log/pm2/kawou-whatsapp-bot-error.log",
      out_file: "/var/log/pm2/kawou-whatsapp-bot-out.log",
    },
  ],
};
