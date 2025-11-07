> [!WARNING]
> **Paragon Anniversary** is still in development!

___

<div align="center">

<img width="292" height="298" alt="Paragon_AI_Logo" src="https://github.com/user-attachments/assets/27482a85-186e-401a-b493-29622ce739b4" />
</div>

<div align="center">
  
# ⚡ Paragon System
### *for AzerothCore*

<img src="https://img.shields.io/badge/AzerothCore-3.3.5a-blue?style=for-the-badge&logo=world-of-warcraft" alt="AzerothCore Badge">
<img src="https://img.shields.io/badge/Language-Lua-purple?style=for-the-badge&logo=lua" alt="Lua Badge">
<img src="https://img.shields.io/badge/Engine-ALE-orange?style=for-the-badge" alt="ALE Badge">

*Endless progression system - Continue growing beyond max level*

</div>

---

## 🌟 What's This?

The **Paragon System** introduces an endgame progression mechanic for AzerothCore servers. After reaching max level, players continue to earn **paragon experience** and unlock **stat bonuses** through a point-based talent system.

### ✨ Key Features

- **📊 Paragon Levels**: Unlimited progression beyond max level
- **⚡ Stat Bonuses**: Invest points in Combat Ratings, Stats, and Special Auras
- **🎯 Three Categories**:
  - **Combat**: Hit, Crit, Haste, Expertise, Armor Penetration
  - **Stats**: Strength, Agility, Stamina, Resistances, HP/Mana
  - **Auras**: Loot, Reputation, and Experience bonuses
- **🎮 Multi-Source Experience**: Gain paragon XP from creatures, achievements, quests, and skills
- **💰 Point System**: Earn points to distribute among available statistics
- **🔄 Client Integration**: In-game interface via custom addon
- **💾 Persistent**: All progress saved to database

---

## 🏗️ Architecture

<table>
<tr>
<td width="50%">

### 📦 **Components**

- `paragon_constant.lua` - Constants & DB queries
- `paragon_repository.lua` - Database access layer
- `paragon_config.lua` - Configuration service
- `paragon_class.lua` - Paragon business logic
- `paragon_hook.lua` - Event handlers & client comm

</td>
<td width="50%">

### 🗄️ **Database**

**Configuration Tables:**
- `paragon_config_category` - Stat categories
- `paragon_config_statistic` - Available stats
- `paragon_config` - General settings
- `paragon_config_experience_creature` - Creature experience rewards
- `paragon_config_experience_achievement` - Achievement experience rewards
- `paragon_config_experience_skill` - Skill experience rewards
- `paragon_config_experience_quest` - Quest experience rewards

**Character Data:**
- `character_paragon` - Player levels & XP
- `character_paragon_stats` - Invested points

</td>
</tr>
</table>

---

## 🚀 Installation

### Server-Side (Lua Scripts)

1. 📁 Copy the `paragon` folder to your ALE scripts directory
2. 🗃️ Database tables are created automatically on first server start
3. ⚙️ Configure `paragon_config` table with your desired settings
4. 🔄 Restart your AzerothCore server

### Client-Side (Addon)

1. 📥 Install the **ParagonAnniversary** addon in your WoW client
2. 🎮 Interface displays paragon level and experience in-game

> **📝 Note**: Requires ALE engine installed on AzerothCore

---

## ⚙️ Configuration

Configure the system via database entries in `paragon_config`:

| Field | Description | Example |
|-------|-------------|---------|
| `BASE_MAX_EXPERIENCE` | XP needed per level (multiplied by level) | `1000` |
| `POINTS_PER_LEVEL` | Points awarded per paragon level | `1` |
| `UNIVERSAL_CREATURE_EXPERIENCE` | Default experience reward for creature kills | `50` |
| `UNIVERSAL_ACHIEVEVEMENT_EXPERIENCE` | Default experience reward for achievements | `100` |
| `UNIVERSAL_SKILL_EXPERIENCE` | Default experience reward for skill increases | `25` |
| `UNIVERSAL_QUEST_EXPERIENCE` | Default experience reward for quest completion | `75` |

### Adding Custom Stats

1. Add categories to `paragon_config_category`
2. Define statistics in `paragon_config_statistic`
3. Configure `type`, `factor`, and `limit` for each stat

**Stat Configuration Fields:**
- `type`: `AURA`, `COMBAT_RATING`, or `UNIT_MODS`
- `type_value`: The specific stat ID from Constants
- `factor`: Multiplier for each point invested
- `limit`: Maximum points that can be invested (max 255)
- `application`: How the stat bonus is applied

---

## 🎮 Stat Types

<table>
<tr>
<td width="33%">

### ⚔️ **Combat Rating**
- Weapon Skill
- Defense / Dodge / Parry / Block
- Hit (Melee/Ranged/Spell)
- Crit (Melee/Ranged/Spell)
- Haste (Melee/Ranged/Spell)
- Expertise
- Armor Penetration

</td>
<td width="33%">

### 💪 **Unit Modifiers**
- Primary Stats (Str/Agi/Sta/Int/Spi)
- Resources (HP/Mana/Rage/Energy/etc)
- Armor & Resistances
- Attack Power
- Damage (Mainhand/Offhand/Ranged)

</td>
<td width="33%">

### ✨ **Aura Bonuses**
- Loot Bonus (1900000)
- Reputation Gain (1900001)
- Experience Gain (1900002)

*Custom aura IDs: 1900000+*

</td>
</tr>
</table>

---

## 🔧 Technical Details

### Design Patterns
- **Singleton Pattern**: Config and Repository services
- **Repository Pattern**: Database abstraction layer
- **Object-Oriented**: Using classic.lua library

### Database
- **Async Queries**: Non-blocking database operations
- **Auto-Migration**: Tables created automatically on startup
- **Normalized Schema**: Separated config and character data

### Client Communication
- **Protocol**: `ParagonAnniversary` addon prefix
- **Commands**:
  - `1`: Load paragon data (sends level, experience, and all statistics)
  - `2`: Update statistics (receives updated stat values from client)

### Event Hooks
- **PLAYER_EVENT_ON_LOGIN (3)**: Load paragon data on login
- **PLAYER_EVENT_ON_LOGOUT (4)**: Save paragon data on logout
- **PLAYER_EVENT_ON_KILL_CREATURE (7)**: Award paragon experience for creature kills
- **PLAYER_EVENT_ON_ACHIEVEMENT_COMPLETE (45)**: Award paragon experience for achievements
- **PLAYER_EVENT_ON_QUEST_COMPLETE (54)**: Award paragon experience for quests
- **PLAYER_EVENT_ON_SKILL_UPDATE (62)**: Award paragon experience for skill increases
- **SERVER_EVENT_ON_LUA_STATE_OPEN (33)**: Reload paragon data for all players when Lua state opens
- **SERVER_EVENT_ON_LUA_STATE_CLOSE (16)**: Save paragon data for all players when Lua state closes

---

## 🎓 Experience & Points System

### Experience Sources
Paragon experience is awarded from multiple activities:
- **🐉 Creatures**: Kill monsters and bosses
- **🏆 Achievements**: Complete achievement goals
- **📜 Quests**: Complete quests
- **🎯 Skills**: Increase character skills

Experience rewards are configurable per source with:
- **Universal default**: Base experience reward value for each source type
- **Specific rewards**: Custom experience values per creature/achievement/quest/skill ID (overrides universal default)

### Points System
- **Earning**: Players earn a configurable number of points per paragon level (`POINTS_PER_LEVEL`)
- **Available Points**: Points = (Level × Points Per Level) - (Total Points Spent)
- **Investing**: Allocate points to statistics with configured limits per stat (max 255 points each)
- **Validation**: Server validates all point allocations before applying stat bonuses

---

## 📚 Code Documentation

All code is fully documented with **LuaDoc** comments:

```lua
--- Adds points to the available paragon points
-- @param points The amount of points to add
-- @return Self for method chaining
function Paragon:AddPoints(points)
    return self:SetPoints(self:GetPoints() + points)
end

--- Retrieves the paragon experience reward for a creature by entry ID
-- @param entry The creature entry ID
-- @return The experience reward value or nil if not configured
function Config:GetCreatureExperience(entry)
    return self.experience.creature[entry]
end
```

---

## 📊 Compatibility

| Component | Version | Status |
|-----------|---------|--------|
| 🎮 **AzerothCore** | 3.3.5a | ✅ **Tested** |
| 🔧 **ALE** | Latest | ✅ **Required** |
| 📚 **Classic** | Any | ✅ **Required** |
| 🔌 **SMH** | Any | ✅ **Required** |

---

## 📁 Project Structure

```
paragon/
├── lib/
│   ├── classic/
│   │   └── classic.ext
│   └── CSMH/
│       └── SMH.ext
├── paragon_constant.lua            # Constants, queries, stat enums
├── paragon_repository.lua          # Database access layer (Singleton)
├── paragon_config.lua              # Configuration service (Singleton)
├── paragon_class.lua               # Paragon entity class
├── paragon_hook.lua                # Event handlers & main entry point
└── README.md                       # This file
```

---

## 🔄 Data Flow

```
Player Login
    ↓
Hook.OnPlayerLogin (paragon_hook.lua)
    ↓
Create Paragon Instance (paragon_class.lua)
    ↓
Load Level & Statistics from DB (paragon_repository.lua)
    ↓
Callback: Hook.OnPlayerStatLoad
    ↓
Apply Statistics to Player & Send Data to Client (ParagonAnniversary addon)
```

---

## 🏆 Credits

- 🔧 **Development**: Custom system for AzerothCore
- 🎨 **Concept**: Inspired by retail WoW Paragon reputation systems
- 🙏 **Thanks**: AzerothCore & ALE communities

---

<div align="center">

### ⚡ **Ready to add endless progression?**

*This system is designed for AzerothCore private servers using ALE*

</div>
