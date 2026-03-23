# BulkAnim Publisher

BulkAnim Publisher is a Roblox Studio plugin that batch-uploads selected rig animations using `AssetService:CreateAssetAsync`, then organizes uploaded `Animation` instances in `ServerStorage`.

## What it does

- Adds a **BulkAnim Publisher** toolbar button in Studio.
- Reads animations from either:
  - `SelectedRig/AnimSaves`
  - `ServerStorage/RBX_ANIMSAVES/<RigName>/AnimSaves`
- Uploads each `KeyframeSequence` as a Roblox animation asset.
- Supports optional upload to a Group via Group ID.
- Writes uploaded assets to:
  - `ServerStorage/Uploaded_Animations/<RigName>/<AnimationName>`

## Requirements

- Roblox Studio plugin environment.
- `CreateAssetAsync Lua API` beta feature enabled in Studio:
  - **File → Beta Features → CreateAssetAsync Lua API**
- Proper upload permissions for your account or target group.

## Usage

1. Open the plugin panel from the **Animation Tools** toolbar.
2. Select one or more rig models in Studio.
3. (Optional) Enter a numeric Group ID to upload under a group.
4. Click **Run Upload**.
5. Check Studio Output/status text for success and error details.

## Source layout expected by the plugin

For each selected rig model, animations are discovered in this order:

1. `RigModel/AnimSaves`
2. `ServerStorage/RBX_ANIMSAVES/<RigModel.Name>/AnimSaves`

Only `KeyframeSequence` objects are uploaded.

## Result layout

After upload, generated `Animation` objects are created/updated under:

`ServerStorage/Uploaded_Animations/<RigName>/...`

Existing animations with the same name are replaced.

## Troubleshooting

- If upload fails with CreateAssetAsync/beta-related errors, enable the beta feature and reopen the plugin.
- If Group ID is invalid, leave it blank (personal upload) or enter numbers only.
- If nothing uploads, verify rigs are selected and each rig has a valid `AnimSaves` container with `KeyframeSequence` children.

## Project notes

This repository appears to be a Rojo-style project (`default.project.json`) with plugin logic in:

- `src/ServerScriptService/AnimationUploader.server.luau`
