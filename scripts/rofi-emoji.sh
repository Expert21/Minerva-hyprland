#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# Rofi Emoji Picker - Select emoji and copy to clipboard
# ═══════════════════════════════════════════════════════════════════════════════

# Common emoji list (extend as needed)
EMOJIS="😀 Grinning Face
😂 Face with Tears of Joy
🤣 Rolling on the Floor Laughing
😊 Smiling Face with Smiling Eyes
😍 Smiling Face with Heart-Eyes
🥰 Smiling Face with Hearts
😘 Face Blowing a Kiss
🤔 Thinking Face
🤨 Face with Raised Eyebrow
😏 Smirking Face
😎 Smiling Face with Sunglasses
🤩 Star-Struck
🥳 Partying Face
😢 Crying Face
😭 Loudly Crying Face
😤 Face with Steam From Nose
🤬 Face with Symbols on Mouth
💀 Skull
👻 Ghost
👽 Alien
🤖 Robot
💩 Pile of Poo
👍 Thumbs Up
👎 Thumbs Down
👏 Clapping Hands
🙌 Raising Hands
🤝 Handshake
✌️ Victory Hand
🤞 Crossed Fingers
🤟 Love-You Gesture
🤘 Sign of the Horns
👌 OK Hand
🔥 Fire
⭐ Star
✨ Sparkles
💫 Dizzy
💥 Collision
💢 Anger Symbol
💯 Hundred Points
❤️ Red Heart
🧡 Orange Heart
💛 Yellow Heart
💚 Green Heart
💙 Blue Heart
💜 Purple Heart
🖤 Black Heart
🤍 White Heart
💔 Broken Heart
✅ Check Mark Button
❌ Cross Mark
⚠️ Warning
🚫 Prohibited
💡 Light Bulb
🔒 Locked
🔓 Unlocked
🔑 Key
🔍 Magnifying Glass Left
🔎 Magnifying Glass Right
💻 Laptop
🖥️ Desktop Computer
⌨️ Keyboard
🖱️ Computer Mouse
🔧 Wrench
🔨 Hammer
⚙️ Gear
🛡️ Shield
⚔️ Crossed Swords
🎯 Bullseye
📁 File Folder
📂 Open File Folder
📄 Page Facing Up
📝 Memo
✏️ Pencil
📌 Pushpin
📎 Paperclip
📋 Clipboard
🗑️ Wastebasket
📧 E-Mail
📨 Incoming Envelope
🔔 Bell
🔕 Bell with Slash
🎵 Musical Note
🎶 Musical Notes
🔊 Speaker High Volume
🔇 Muted Speaker
📱 Mobile Phone
☎️ Telephone
🌐 Globe with Meridians
🔗 Link
⏰ Alarm Clock
⏳ Hourglass Not Done
⌛ Hourglass Done
🌙 Crescent Moon
☀️ Sun
⛅ Sun Behind Cloud
🌧️ Cloud with Rain
⚡ High Voltage
❄️ Snowflake
🌊 Water Wave
🎮 Video Game
🎲 Game Die
🏆 Trophy
🎖️ Military Medal
🚀 Rocket
✈️ Airplane
🚗 Automobile
🚲 Bicycle
⚓ Anchor
🗺️ World Map
🏠 House
🏢 Office Building
🏗️ Building Construction
🌲 Evergreen Tree
🌺 Hibiscus
🍕 Pizza
🍔 Hamburger
☕ Hot Beverage
🍺 Beer Mug
🍷 Wine Glass
🎂 Birthday Cake"

# Run rofi and get selection
SELECTED=$(echo "$EMOJIS" | rofi -dmenu -i -p "Emoji" -theme-str 'window {width: 400px;}')

if [ -n "$SELECTED" ]; then
    # Extract just the emoji (first character/grapheme)
    EMOJI=$(echo "$SELECTED" | cut -d' ' -f1)
    
    # Copy to clipboard
    echo -n "$EMOJI" | wl-copy
    
    # Notify
    notify-send "Emoji Copied" "$EMOJI" -t 1500
fi
