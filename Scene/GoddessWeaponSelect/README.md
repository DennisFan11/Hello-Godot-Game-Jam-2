# 女神武器選擇場景 (GoddessWeaponSelect)

## 🎯 場景介紹

這是一個女神武器選擇場景，參考經典對話遊戲的設計。玩家進入場景後會看到女神角色，並通過對話系統選擇起始武器。

## 🎮 場景功能

### 📜 對話系統

- **打字機效果**：對話文字逐字顯示，增加沉浸感
- **多段對話**：女神會說多段開場白介紹背景
- **互動性**：玩家可以點擊繼續按鈕或按空格鍵推進對話

### ⚔️ 武器選擇

- **三種武器選項**：

  - 🗡️ **光明之劍**：散發神聖光芒，對邪惡有額外傷害
  - 🏹 **風暴之弓**：召喚風暴，攻擊範圍廣闊
  - 🔮 **水晶法杖**：蘊含魔法能量，釋放強大法術

- **美觀界面**：
  - 武器按鈕包含圖標、名稱和描述
  - 懸停效果和點擊反饋
  - 水平排列，方便選擇

### 🎭 女神回應

- **個性化反應**：根據玩家選擇的武器，女神會給出對應的祝福話語
- **場景轉換**：選擇完成後平滑轉跳到下一個場景

## 🏗️ 技術架構

### 全域背包系統

```gdscript
# 在 CoreManager 中管理
CoreManager.add_weapon(weapon_id, weapon_name, description)
CoreManager.get_selected_weapon()
CoreManager.get_player_inventory()
```

### 場景管理

```gdscript
# 場景轉跳
CoreManager.goto_scene("GoddessWeaponSelect")
CoreManager.goddess_scene_complete()  # 女神場景結束後的轉跳
```

## 🎨 UI 結構

```
GoddessWeaponSelect (Control)
├── Background (ColorRect) - 深藍色背景
├── GoddessPortrait (TextureRect) - 女神肖像（可替換圖片）
├── DialoguePanel (Panel) - 對話面板
│   └── DialogueContainer (VBoxContainer)
│       ├── DialogueLabel (RichTextLabel) - 對話文字
│       └── ContinueButton (Button) - 繼續按鈕
└── WeaponSelectionPanel (Panel) - 武器選擇面板
    └── WeaponButtonsContainer (HBoxContainer) - 武器按鈕容器
```

## 📝 使用方法

### 從其他場景進入

```gdscript
# 在任何場景中調用
await CoreManager.goto_scene("GoddessWeaponSelect")
```

### 自定義女神肖像

1. 將女神圖片放入專案中
2. 在場景編輯器中設置 `GoddessPortrait` 節點的紋理

### 修改武器配置

在 `GoddessWeaponSelect.gd` 中修改 `weapons_config` 陣列：

```gdscript
var weapons_config: Array[Dictionary] = [
    {
        "id": "weapon_id",
        "name": "武器名稱",
        "description": "武器描述",
        "icon": "🗡️",
        "response": "女神的回應文字"
    }
]
```

### 修改轉跳目標

在 `CoreManager.gd` 中修改 `goddess_scene_complete()` 方法：

```gdscript
func goddess_scene_complete():
    """女神場景完成後的轉跳方法"""
    print("女神賜予完成，前往下一個場景...")
    await goto_scene("你的目標場景名稱")
```

## ✨ 特色功能

- **響應式設計**：支援不同螢幕尺寸
- **動畫效果**：淡入淡出，打字機效果
- **音效支援**：可輕鬆添加背景音樂和音效
- **可擴展性**：容易添加更多武器或修改對話
- **全域管理**：武器資料保存在 CoreManager 中，跨場景持久

## 🔧 開發說明

- 所有武器資料都會自動保存到 CoreManager 的背包系統
- 場景支援鍵盤和滑鼠操作
- 使用 Godot 4 的現代 UI 系統
- 完全整合到專案的 CoreManager 架構中
