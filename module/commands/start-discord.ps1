# CONFIG
$guildId   = "689497286488883364"
$channelId = "690534096711188480"

# Open Discord and join voice channel
Start-Process "discord://discord.com/channels/$guildId/$channelId"

# Run AutoHotkey script
Start-Process ".\discord_mute.ahk"