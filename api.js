const express = require("express");
const { Client, GatewayIntentBits, Collection, REST, Routes, SlashCommandBuilder } = require("discord.js");
const crypto = require("crypto");
const fs = require("fs");
const mysql = require("mysql2");
const bcrypt = require("bcrypt");

const app = express();
const PORT = 3000;
const DISCORD_BOT_TOKEN = 'DDDDD';
const GUILD_ID = "111111111";
const CLIENT_ID = "444444444";
const cooldowns = new Map();
const COOLDOWN_TIME = 5 * 60 * 1000;
const client = new Client({
    intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMembers, GatewayIntentBits.DirectMessages]
});

const VERIFIED_ROLE_ID = '1379563993789894786';
const WHITELIST_ROLE_ID = '1380577858589822976'; 
const verificationCodes = new Collection();
const usedDiscordIDs = new Set();
const codeTimers = new Map();
const CODE_EXPIRATION_TIME = 60000;
const VERIFIED_USERS_FILE = "verified_users.json";

const ALLOWED_IP = "127.0.0.1";
const db = mysql.createPool({
    host: "127.0.0.1",
    user: "admin",
    password: "75^pS09Nx!!g",
    database: "rp_database"
});

app.use(express.json());
app.use((req, res, next) => {
    let clientIp = req.headers["x-forwarded-for"] || req.connection.remoteAddress;
    if (clientIp.startsWith("::ffff:")) clientIp = clientIp.substring(7);

    console.log("Client IP:", clientIp);
    if (clientIp !== ALLOWED_IP) {
        return res.status(403).json({ error: "Unauthorized" });
    }
    next();
});

function saveVerifiedUsers() {
    fs.writeFileSync(VERIFIED_USERS_FILE, JSON.stringify([...usedDiscordIDs], null, 2));
}

function loadVerifiedUsers() {
    if (fs.existsSync(VERIFIED_USERS_FILE)) {
        const data = fs.readFileSync(VERIFIED_USERS_FILE);
        const parsedIDs = JSON.parse(data);
        parsedIDs.forEach(id => usedDiscordIDs.add(id));
    }
}

const changePasswordCommand = new SlashCommandBuilder()
    .setName("changepassword")
    .setDescription("Zmień swoje hasło do konta MTA.")
    .addStringOption(option =>
        option.setName("newpassword")
            .setDescription("Nowe hasło do konta")
            .setRequired(true)
    );

loadVerifiedUsers();

const serialCommand = new SlashCommandBuilder()
    .setName("serial")
    .setDescription("Zaktualizuj swój serial w bazie danych.")
    .addStringOption(option =>
        option.setName("serial")
            .setDescription("Podaj swój serial z MTA:SA")
            .setRequired(true)
    )
    .addStringOption(option =>
        option.setName("ip")
            .setDescription("Podaj swoje IP")
            .setRequired(true)
    );

const rest = new REST({ version: "10" }).setToken(DISCORD_BOT_TOKEN);

(async () => {
    try {
        console.log("🔧 Rejestruję komendy...");

        await rest.put(Routes.applicationGuildCommands(CLIENT_ID, GUILD_ID), {
            body: [
                { name: "verify", description: "Zweryfikuj swoje konto MTA" },
                serialCommand.toJSON(),
                changePasswordCommand.toJSON()
            ],
        });

        console.log("✅ Wszystkie komendy zostały zarejestrowane!");
    } catch (error) {
        console.error("❌ Błąd rejestracji komend:", error);
    }
})();

client.on("interactionCreate", async (interaction) => {
    if (!interaction.isChatInputCommand() || interaction.commandName !== "serial") return;
    
    const discordID = interaction.user.id;
    const serial = interaction.options.getString("serial");
    const playerIP = interaction.options.getString("ip");
    const member = await interaction.guild.members.fetch(discordID);
    const hasVerifiedRole = member.roles.cache.has(VERIFIED_ROLE_ID);
    const hasWhitelistRole = member.roles.cache.has(WHITELIST_ROLE_ID);

    if (!hasVerifiedRole || !hasWhitelistRole) {
        return interaction.reply({ 
            content: "❌ Aby użyć tej komendy, musisz posiadać rolę `zweryfikowany` oraz `whitelist`.", 
            ephemeral: true 
        });
    }

    const serialRegex = /^[A-F0-9]{32}$/;
    if (!serialRegex.test(serial) || !serial) {
        return interaction.reply({ content: "❌ Nieprawidłowy format serialu! Serial musi mieć dokładnie 32 znaki i składać się tylko z cyfr oraz wielkich liter (A-F).", ephemeral: true });
    }
    if (!playerIP){
        return interaction.reply({ content: "❌ Podaj swoje IP internetu.", ephemeral: true });
    }
    
    const now = Date.now();
    if (cooldowns.has(discordID)) {
        const lastUsed = cooldowns.get(discordID);
        const remainingTime = COOLDOWN_TIME - (now - lastUsed);
        if (remainingTime > 0) {
            return interaction.reply({ content: `⏳ Możesz ponownie użyć tej komendy za ${Math.ceil(remainingTime / 1000)} sekund.`, ephemeral: true });
        }
    }

    db.query("SELECT username FROM users WHERE discordID = ?", [discordID], (err, results) => {
        if (err) {
            console.error("Błąd zapytania do bazy danych:", err);
            return interaction.reply({ content: "❌ Błąd serwera, spróbuj ponownie później.", ephemeral: true });
        }

        if (results.length === 0) {
            return interaction.reply({ content: "❌ Nie znaleziono twojego konta w bazie. Zweryfikuj się najpierw!", ephemeral: true });
        }

        const { username } = results[0];
        
        db.query("UPDATE users SET serial = ?, ip = ? WHERE discordID = ?", [serial, playerIP, discordID], (updateErr) => {
            if (updateErr) {
                console.error("Błąd aktualizacji serialu:", updateErr);
                return interaction.reply({ content: "❌ Błąd aktualizacji serialu.", ephemeral: true });
            }
            
            cooldowns.set(discordID, now);
            interaction.reply({ content: `✅ Serial zaktualizowany dla użytkownika **${username}**!`, ephemeral: true });
        });
    });
});

client.on("interactionCreate", async (interaction) => {
    if (!interaction.isChatInputCommand() || interaction.commandName !== "verify") return;
    
    const discordID = interaction.user.id;
    const member = await interaction.guild.members.fetch(discordID);
    const hasVerifiedRole = member.roles.cache.has(VERIFIED_ROLE_ID);
    const hasWhitelistRole = member.roles.cache.has(WHITELIST_ROLE_ID);

    if (!hasVerifiedRole || !hasWhitelistRole) {
        return interaction.reply({ 
            content: "❌ Aby użyć tej komendy, musisz posiadać rolę `zweryfikowany` oraz `whitelist`.", 
            ephemeral: true 
        });
    }
    if (usedDiscordIDs.has(discordID)) {
        return interaction.reply({ content: "❌ Twoje konto Discord zostało już zweryfikowane.", ephemeral: true });
    }

    if (verificationCodes.some(data => data.discordID === discordID)) {
        return interaction.reply({ content: "❌ Możesz wygenerować nowy kod dopiero po 60 sekundach.", ephemeral: true });
    }

    const code = crypto.randomInt(100000, 999999).toString();
    verificationCodes.set(code, { discordID, username: interaction.user.username });

    const timeout = setTimeout(() => {
        verificationCodes.delete(code);
        codeTimers.delete(discordID);
    }, CODE_EXPIRATION_TIME);
    codeTimers.set(discordID, timeout);

    try {
        await interaction.user.send(`Twój kod weryfikacyjny: **${code}**. Wpisz go na serwerze w editboxie.`);
        await interaction.reply({ content: "📩 Sprawdź wiadomość prywatną (DM) po kod!", ephemeral: true });
    } catch (error) {
        console.error("Błąd wysyłania DM:", error);
        await interaction.reply({ content: "❌ Nie mogę wysłać wiadomości prywatnej. Sprawdź ustawienia!", ephemeral: true });
    }
});

client.on("interactionCreate", async (interaction) => {
    if (!interaction.isChatInputCommand() || interaction.commandName !== "changepassword") return;

    const discordID = interaction.user.id;
    const member = await interaction.guild.members.fetch(discordID);
    const hasVerifiedRole = member.roles.cache.has(VERIFIED_ROLE_ID);
    const hasWhitelistRole = member.roles.cache.has(WHITELIST_ROLE_ID);

    if (!hasVerifiedRole || !hasWhitelistRole) {
        return interaction.reply({
            content: "❌ Aby użyć tej komendy, musisz posiadać rolę `zweryfikowany` oraz `whitelist`.",
            ephemeral: true
        });
    }

    const newPassword = interaction.options.getString("newpassword");

    if (newPassword.length < 6 || newPassword.length > 32) {
        return interaction.reply({
            content: "❌ Hasło musi mieć od 6 do 32 znaków.",
            ephemeral: true
        });
    }

    let hashedPassword = await bcrypt.hash(newPassword, 10);
    hashedPassword = hashedPassword.replace(/^\$2b\$/, "$2y$");

    db.query("SELECT id FROM users WHERE discordID = ?", [discordID], (err, results) => {
        if (err) {
            console.error("Błąd bazy danych:", err);
            return interaction.reply({ content: "❌ Wystąpił błąd serwera.", ephemeral: true });
        }

        if (results.length === 0) {
            return interaction.reply({ content: "❌ Nie znaleziono Twojego konta w bazie. Zweryfikuj się najpierw!", ephemeral: true });
        }

        db.query("UPDATE users SET password = ? WHERE discordID = ?", [hashedPassword, discordID], (updateErr) => {
            if (updateErr) {
                console.error("Błąd aktualizacji hasła:", updateErr);
                return interaction.reply({ content: "❌ Nie udało się zmienić hasła.", ephemeral: true });
            }

            interaction.reply({ content: "✅ Twoje hasło zostało pomyślnie zmienione!", ephemeral: true });
        });
    });
});

app.post("/verify-code", (req, res) => {
    console.log("🔍 Otrzymano żądanie:", req.body);
    console.log("📜 Obecne kody:", verificationCodes);

    const { code } = req.body;
    if (!code) {
        return res.status(400).json({ success: false, error: "Brak kodu weryfikacyjnego." });
    }

    if (verificationCodes.has(code)) {
        const userData = verificationCodes.get(code);
        verificationCodes.delete(code);
        usedDiscordIDs.add(userData.discordID);
        saveVerifiedUsers();

        if (codeTimers.has(userData.discordID)) {
            clearTimeout(codeTimers.get(userData.discordID));
            codeTimers.delete(userData.discordID);
        }

        return res.json({ success: true, discordID: userData.discordID, username: userData.username });
    }

    return res.status(400).json({ success: false, error: "Niepoprawny kod weryfikacyjny." });
});

client.once("ready", () => console.log(`🤖 Bot zalogowany jako ${client.user.tag}`));
client.login(DISCORD_BOT_TOKEN);

app.listen(PORT, () => console.log(`🚀 API działa na http://localhost:${PORT}`));