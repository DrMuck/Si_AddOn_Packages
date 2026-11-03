# Installation — Market Package

[Si_Market](https://github.com/DrMuck/Si_Market) — a stock market that lasts one round. Each faction gets a coin (**SolCoin**, **CentCoin**, **CrabCoin**); players buy and sell coins with their `/buy` credits, prices follow the faction's strength and player demand, and a coin crashes to 0 when its faction is eliminated. Anyone may hold any coin, including the enemy's.

## Prerequisites

1. [MelonLoader](https://github.com/LavaGang/MelonLoader) on the dedicated server
2. [Silica Admin Mod](https://github.com/data-bomb/Silica) (`Si_AdminMod.dll`)
3. **Buy_Package** from the same release — `Si_Buy.dll` **1.4.0 or newer** holds the credits. With an older Si_Buy, trading works, but `/buy` cannot pay with coins.
4. Optional: **ModUI_Package** — the market gets its own page (price table, buy/sell pickers, auto-sell switch, holdings)

## Install

Copy the contents of this package on top of your Silica dedicated server directory:

```
Mods/Si_Market.dll
UserData/cfg/Market/Si_Market_Config.example.json   (rename to *.json, or let the mod write one)
```

The config is written with defaults on first start; unknown or missing fields fall back to the defaults.

## Quick start

1. Start the server. Trading opens about 20 s after a round starts, once the bases exist.
2. Players type `/coin` for prices, their credits, coins and profit/loss.
3. `/coin buy sol 200` spends 200 credits on SolCoin (`all`, `half`, `25%` also work); `/coin sell crab all` sells; `/coin sell all` liquidates everything.
4. `/coin auto on|off` — when a `/buy` purchase is short of credits, the biggest coin holding is sold to cover it (on by default).
5. `/coin top` shows the best traders; they are also announced at round end. All holdings vanish with the round, like the credits.

## Admin commands

| Command | |
|--|--|
| `/coin enabled on\|off` | Master switch. Off drops the open holdings |
| `/coin set` | List every setting with its current value |
| `/coin set <key> <value>` | Change one, e.g. `/coin set float 1000`, `/coin set fee 3%` |
| `/coin reload` | Re-read the config after editing the file by hand |

Changes from chat or ModUI are saved to the config at once. `startprice`, `float`, `shares` and `premium` take effect at the next listing (next round); everything else at once.

## Settings

`UserData/cfg/Market/Si_Market_Config.json`:

| Key (`/coin set`) | JSON field | Default | |
|--|--|--|--|
| `startprice` * | `StartPrice` | 10 | Credits per share at listing |
| `float` * | `FreeFloat` | 5000 | Shares players can hold per coin; smaller = each trade moves the price more |
| `shares` * | `SharesOutstanding` | 100000 | Only for the market cap shown in `/coin` |
| `premium` * | `DemandPremium` | 0.5 | Price at a sold-out float = fundamental × (1 + this) |
| `fee` | `TradeFee` | 0.03 | Fee on every buy and sell |
| `mintrade` | `MinTradeCredits` | 10 | |
| `army` / `buildings` / `bank` | `ArmyWeight` / `StructureWeight` / `BankWeight` | 1 / 1 / 0.5 | Strength weights |
| `sample` | `SampleSeconds` | 10 | How often strength is read |
| `growth` | `MarketGrowth` | 0.5 | 0 = zero-sum, 1 = each coin follows only its own faction |
| `smoothing` | `SmoothingSeconds` | 60 | How fast the price follows strength |
| `listingdelay` | `ListingDelaySeconds` | 20 | Delay after round start before trading opens |
| `autosell` | `AutoSellDefault` | on | Auto-sell for players who never typed `/coin auto` |
| `announce` | `PriceAnnouncementSeconds` | 240 | Price line in all chat every N seconds (0 = off) |
| `announcetrades` | `AnnounceTrades` | on | Every buy and sell in all chat |
| `toptraders` | `TopTradersAtRoundEnd` | 3 | 0 = no announcement |

\* takes effect from the next round.

**Sizing tip:** with the default float of 5000 shares, player demand barely moves prices. A float of about 1000 shares with 10000 outstanding makes demand noticeable (a 300 cr buy moves the price about +1.5 %, a 3k buy about +15 %).
