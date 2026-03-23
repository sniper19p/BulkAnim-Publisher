local AssetService = game:GetService("AssetService")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local TOOLBAR_NAME = "Animation Tools"
local BUTTON_NAME = "BulkAnim Publisher"
local BUTTON_TOOLTIP = "Upload selected rig animations and organize them in ServerStorage"
local BUTTON_ICON = "rbxassetid://110061709835310"
local WIDGET_ID = "AutoAnimationUploaderWidget"
local SETTINGS_GROUP_ID_KEY = "AutoAnimationUploader_GroupId"
local SETTINGS_REQUIREMENTS_SEEN_KEY = "AutoAnimationUploader_RequirementsSeen"
local PANEL_COLOR = Color3.fromRGB(24, 28, 36)
local PANEL_BORDER_COLOR = Color3.fromRGB(66, 74, 92)
local TEXT_PRIMARY_COLOR = Color3.fromRGB(241, 245, 255)
local TEXT_SECONDARY_COLOR = Color3.fromRGB(186, 196, 216)
local STATUS_SUCCESS_COLOR = Color3.fromRGB(89, 255, 106)
local STATUS_ERROR_COLOR = Color3.fromRGB(255, 120, 120)
local INPUT_BG_COLOR = Color3.fromRGB(33, 38, 50)
local INPUT_BORDER_COLOR = Color3.fromRGB(90, 103, 133)
local INPUT_FOCUS_BG_COLOR = Color3.fromRGB(36, 42, 56)
local INPUT_FOCUS_BORDER_COLOR = Color3.fromRGB(108, 128, 166)
local ACCENT_COLOR = Color3.fromRGB(84, 172, 255)
local RUN_BUTTON_DISABLED_COLOR = Color3.fromRGB(88, 96, 113)

local toolbar = plugin:CreateToolbar(TOOLBAR_NAME)
local button = toolbar:CreateButton(BUTTON_NAME, BUTTON_TOOLTIP, BUTTON_ICON)
button.ClickableWhenViewportHidden = true

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	420,
	300,
	320,
	260
)

local widget = plugin:CreateDockWidgetPluginGui(WIDGET_ID, widgetInfo)
widget.Title = "BulkAnim Publisher"
widget.Enabled = false

local rootFrame = Instance.new("Frame")
rootFrame.Size = UDim2.fromScale(1, 1)
rootFrame.BackgroundTransparency = 0
rootFrame.BackgroundColor3 = PANEL_COLOR
rootFrame.Parent = widget

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0, 10)
rootCorner.Parent = rootFrame

local rootStroke = Instance.new("UIStroke")
rootStroke.Color = PANEL_BORDER_COLOR
rootStroke.Thickness = 1
rootStroke.Transparency = 0.35
rootStroke.Parent = rootFrame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = rootFrame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = rootFrame

local titleRow = Instance.new("Frame")
titleRow.Size = UDim2.new(1, 0, 0, 38)
titleRow.BackgroundTransparency = 1
titleRow.Parent = rootFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.62, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.TextColor3 = TEXT_PRIMARY_COLOR
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.Text = "BulkAnim Publisher"
title.Parent = titleRow

local headerStatusLabel = Instance.new("TextLabel")
headerStatusLabel.Size = UDim2.new(0.38, 0, 1, 0)
headerStatusLabel.Position = UDim2.fromScale(0.62, 0)
headerStatusLabel.BackgroundTransparency = 1
headerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
headerStatusLabel.TextYAlignment = Enum.TextYAlignment.Center
headerStatusLabel.TextWrapped = true
headerStatusLabel.TextColor3 = TEXT_SECONDARY_COLOR
headerStatusLabel.Font = Enum.Font.GothamBold
headerStatusLabel.TextSize = 12
headerStatusLabel.RichText = true
headerStatusLabel.Text = ""
headerStatusLabel.Parent = titleRow

local instructions = Instance.new("TextLabel")
instructions.Size = UDim2.new(1, 0, 0, 64)
instructions.BackgroundTransparency = 1
instructions.TextWrapped = true
instructions.TextXAlignment = Enum.TextXAlignment.Left
instructions.TextYAlignment = Enum.TextYAlignment.Top
instructions.TextColor3 = TEXT_SECONDARY_COLOR
instructions.Font = Enum.Font.Gotham
instructions.TextSize = 13
instructions.Text = "How to use:\n1) Select one or more rig models\n2) Optional: enter Group ID\n3) Click Run Upload"
instructions.Parent = rootFrame

local sourceHint = Instance.new("TextLabel")
sourceHint.Size = UDim2.new(1, 0, 0, 32)
sourceHint.BackgroundTransparency = 1
sourceHint.TextWrapped = true
sourceHint.TextXAlignment = Enum.TextXAlignment.Left
sourceHint.TextYAlignment = Enum.TextYAlignment.Top
sourceHint.TextColor3 = TEXT_SECONDARY_COLOR
sourceHint.Font = Enum.Font.Gotham
sourceHint.TextSize = 12
sourceHint.Text = "Looks for AnimSaves inside rigs and in ServerStorage/RBX_ANIMSAVES/<Rig>/AnimSaves"
sourceHint.Parent = rootFrame

local groupLabel = Instance.new("TextLabel")
groupLabel.Size = UDim2.new(1, 0, 0, 18)
groupLabel.BackgroundTransparency = 1
groupLabel.TextXAlignment = Enum.TextXAlignment.Left
groupLabel.TextColor3 = TEXT_PRIMARY_COLOR
groupLabel.Font = Enum.Font.GothamSemibold
groupLabel.TextSize = 13
groupLabel.Text = "Upload To Group ID (optional)"
groupLabel.Parent = rootFrame

local groupBox = Instance.new("TextBox")
groupBox.Size = UDim2.new(1, 0, 0, 36)
groupBox.ClearTextOnFocus = false
groupBox.PlaceholderText = "Blank = personal upload (e.g. 12345678 for group)"
groupBox.PlaceholderColor3 = TEXT_SECONDARY_COLOR
groupBox.BackgroundColor3 = INPUT_BG_COLOR
groupBox.BorderSizePixel = 0
groupBox.TextColor3 = TEXT_PRIMARY_COLOR
groupBox.Font = Enum.Font.Gotham
groupBox.TextSize = 14
groupBox.TextXAlignment = Enum.TextXAlignment.Left
groupBox.Text = ""
groupBox.Parent = rootFrame

local groupBoxPadding = Instance.new("UIPadding")
groupBoxPadding.PaddingLeft = UDim.new(0, 10)
groupBoxPadding.PaddingRight = UDim.new(0, 10)
groupBoxPadding.Parent = groupBox

local groupBoxCorner = Instance.new("UICorner")
groupBoxCorner.CornerRadius = UDim.new(0, 7)
groupBoxCorner.Parent = groupBox

local groupBoxStroke = Instance.new("UIStroke")
groupBoxStroke.Color = INPUT_BORDER_COLOR
groupBoxStroke.Thickness = 1
groupBoxStroke.Transparency = 0.2
groupBoxStroke.Parent = groupBox

local groupHelp = Instance.new("TextLabel")
groupHelp.Size = UDim2.new(1, 0, 0, 16)
groupHelp.BackgroundTransparency = 1
groupHelp.TextXAlignment = Enum.TextXAlignment.Left
groupHelp.TextColor3 = TEXT_SECONDARY_COLOR
groupHelp.Font = Enum.Font.Gotham
groupHelp.TextSize = 11
groupHelp.Text = "Only numbers are valid. Leave empty to upload to your own account."
groupHelp.Parent = rootFrame

local runButton = Instance.new("TextButton")
runButton.Size = UDim2.new(1, 0, 0, 34)
runButton.BackgroundColor3 = ACCENT_COLOR
runButton.BorderSizePixel = 0
runButton.TextColor3 = Color3.fromRGB(13, 20, 31)
runButton.Font = Enum.Font.GothamBold
runButton.TextSize = 14
runButton.Text = "Run Upload"
runButton.Parent = rootFrame

local runButtonCorner = Instance.new("UICorner")
runButtonCorner.CornerRadius = UDim.new(0, 8)
runButtonCorner.Parent = runButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.BackgroundTransparency = 1
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.TextWrapped = true
statusLabel.TextColor3 = TEXT_SECONDARY_COLOR
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.RichText = true
statusLabel.Text = "Idle"
statusLabel.Parent = rootFrame

local requirementsPage = Instance.new("Frame")
requirementsPage.Size = UDim2.fromScale(1, 1)
requirementsPage.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
requirementsPage.BorderSizePixel = 0
requirementsPage.Visible = false
requirementsPage.ZIndex = 10
requirementsPage.Parent = widget

local requirementsPadding = Instance.new("UIPadding")
requirementsPadding.PaddingTop = UDim.new(0, 16)
requirementsPadding.PaddingBottom = UDim.new(0, 16)
requirementsPadding.PaddingLeft = UDim.new(0, 16)
requirementsPadding.PaddingRight = UDim.new(0, 16)
requirementsPadding.Parent = requirementsPage

local requirementsList = Instance.new("UIListLayout")
requirementsList.FillDirection = Enum.FillDirection.Vertical
requirementsList.HorizontalAlignment = Enum.HorizontalAlignment.Left
requirementsList.VerticalAlignment = Enum.VerticalAlignment.Top
requirementsList.Padding = UDim.new(0, 10)
requirementsList.Parent = requirementsPage

local requirementsTitle = Instance.new("TextLabel")
requirementsTitle.Size = UDim2.new(1, 0, 0, 28)
requirementsTitle.BackgroundTransparency = 1
requirementsTitle.TextXAlignment = Enum.TextXAlignment.Left
requirementsTitle.TextColor3 = TEXT_PRIMARY_COLOR
requirementsTitle.Font = Enum.Font.GothamBlack
requirementsTitle.TextSize = 22
requirementsTitle.Text = "Before You Start"
requirementsTitle.ZIndex = 11
requirementsTitle.Parent = requirementsPage

local requirementsBody = Instance.new("TextLabel")
requirementsBody.Size = UDim2.new(1, 0, 0, 120)
requirementsBody.BackgroundTransparency = 1
requirementsBody.TextXAlignment = Enum.TextXAlignment.Left
requirementsBody.TextYAlignment = Enum.TextYAlignment.Top
requirementsBody.TextWrapped = true
requirementsBody.TextColor3 = TEXT_SECONDARY_COLOR
requirementsBody.Font = Enum.Font.Gotham
requirementsBody.TextSize = 14
requirementsBody.Text = "This plugin needs CreateAssetAsync Lua API enabled.\n\nGo to: File > Beta Features > CreateAssetAsync Lua API\nThen restart Studio if prompted."
requirementsBody.ZIndex = 11
requirementsBody.Parent = requirementsPage

local requirementsReason = Instance.new("TextLabel")
requirementsReason.Size = UDim2.new(1, 0, 0, 32)
requirementsReason.BackgroundColor3 = Color3.fromRGB(52, 44, 20)
requirementsReason.BackgroundTransparency = 0.2
requirementsReason.BorderSizePixel = 0
requirementsReason.TextWrapped = true
requirementsReason.TextXAlignment = Enum.TextXAlignment.Left
requirementsReason.TextYAlignment = Enum.TextYAlignment.Center
requirementsReason.TextColor3 = Color3.fromRGB(255, 226, 150)
requirementsReason.Font = Enum.Font.GothamSemibold
requirementsReason.TextSize = 13
requirementsReason.Text = ""
requirementsReason.Visible = false
requirementsReason.ZIndex = 11
requirementsReason.Parent = requirementsPage

local requirementsReasonPadding = Instance.new("UIPadding")
requirementsReasonPadding.PaddingLeft = UDim.new(0, 8)
requirementsReasonPadding.PaddingRight = UDim.new(0, 8)
requirementsReasonPadding.Parent = requirementsReason

local requirementsReasonCorner = Instance.new("UICorner")
requirementsReasonCorner.CornerRadius = UDim.new(0, 6)
requirementsReasonCorner.Parent = requirementsReason

local openMainButton = Instance.new("TextButton")
openMainButton.Size = UDim2.new(0, 220, 0, 30)
openMainButton.BackgroundColor3 = ACCENT_COLOR
openMainButton.BorderSizePixel = 0
openMainButton.TextColor3 = Color3.fromRGB(13, 20, 31)
openMainButton.Font = Enum.Font.GothamBold
openMainButton.TextSize = 13
openMainButton.Text = "I Enabled It - Open Plugin"
openMainButton.AutoButtonColor = false
openMainButton.Active = false
openMainButton.ZIndex = 11
openMainButton.Parent = requirementsPage

local openMainButtonCorner = Instance.new("UICorner")
openMainButtonCorner.CornerRadius = UDim.new(0, 8)
openMainButtonCorner.Parent = openMainButton
local requirementsPageOpenToken = 0
local setStatusText

local function setRequirementsButtonEnabled(enabled, label)
	openMainButton.Active = enabled
	openMainButton.AutoButtonColor = enabled
	openMainButton.BackgroundColor3 = enabled and ACCENT_COLOR or RUN_BUTTON_DISABLED_COLOR
	openMainButton.Text = label
end

local function showRequirementsPage(reasonText)
	requirementsPageOpenToken += 1
	local openToken = requirementsPageOpenToken
	requirementsPage.Visible = true
	requirementsReason.Visible = reasonText ~= nil and reasonText ~= ""
	requirementsReason.Text = reasonText or ""
	setStatusText("Enable CreateAssetAsync Lua API to continue", STATUS_ERROR_COLOR)

	setRequirementsButtonEnabled(false, "Open Plugin (3)")
	task.spawn(function()
		for seconds = 2, 1, -1 do
			task.wait(1)
			if requirementsPageOpenToken ~= openToken or not requirementsPage.Visible then
				return
			end
			setRequirementsButtonEnabled(false, string.format("Open Plugin (%d)", seconds))
		end

		task.wait(1)
		if requirementsPageOpenToken ~= openToken or not requirementsPage.Visible then
			return
		end

		setRequirementsButtonEnabled(true, "I Enabled It - Open Plugin")
	end)
end

local function hideRequirementsPage(markSeen)
	requirementsPage.Visible = false
	requirementsPageOpenToken += 1
	if markSeen then
		plugin:SetSetting(SETTINGS_REQUIREMENTS_SEEN_KEY, true)
	end
end

local function isCreateAssetApiDisabledError(message)
	local lower = string.lower(tostring(message or ""))
	if not string.find(lower, "createassetasync", 1, true) then
		return false
	end

	return string.find(lower, "beta", 1, true)
		or string.find(lower, "not enabled", 1, true)
		or string.find(lower, "not currently enabled", 1, true)
		or string.find(lower, "security", 1, true)
		or string.find(lower, "lua api", 1, true)
end

local function trim(text)
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function colorToHex(color)
	local function channelToHex(channel)
		return string.format("%02X", math.clamp(math.floor(channel * 255 + 0.5), 0, 255))
	end

	return "#" .. channelToHex(color.R) .. channelToHex(color.G) .. channelToHex(color.B)
end

local function escapeRichText(text)
	return tostring(text or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

setStatusText = function(message, color)
	statusLabel.Text = string.format('<font color="%s">%s</font>', colorToHex(color or TEXT_SECONDARY_COLOR), escapeRichText(message))
end

local function setUploadSummaryStatus(uploadedCount, errorCount, uploadedRigCount, totalRigCount)
	local uploaded = tonumber(uploadedCount) or 0
	local errors = tonumber(errorCount) or 0
	local errorColor = errors == 0 and STATUS_SUCCESS_COLOR or STATUS_ERROR_COLOR
	local uploadedRigs = tonumber(uploadedRigCount) or 0
	local totalRigs = tonumber(totalRigCount) or 0

	if totalRigs > 0 then
		headerStatusLabel.Text = string.format(
			'<font color="%s">UPLOADED: %d/%d Rigs</font>\n<font color="%s">%d errors</font>',
			colorToHex(STATUS_SUCCESS_COLOR),
			uploadedRigs,
			totalRigs,
			colorToHex(errorColor),
			errors
		)
	else
		headerStatusLabel.Text = ""
	end

	statusLabel.Text = string.format(
		'<font color="%s">UPLOADED: %d</font>  <font color="%s">%d errors</font>',
		colorToHex(STATUS_SUCCESS_COLOR),
		uploaded,
		colorToHex(errorColor),
		errors
	)
end

local function sortedKeys(dict)
	local keys = {}
	for key in pairs(dict) do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

local function findAnimSource(rig)
	local internal = rig:FindFirstChild("AnimSaves")
	if internal then
		return internal:GetChildren()
	end

	local rbxSaves = ServerStorage:FindFirstChild("RBX_ANIMSAVES")
	if rbxSaves then
		local rigContainer = rbxSaves:FindFirstChild(rig.Name)
		if rigContainer then
			local external = rigContainer:FindFirstChild("AnimSaves")
			if external then
				return external:GetChildren()
			end
		end
	end

	return nil
end

local function setRunningState(isRunning, message, messageColor)
	runButton.Active = not isRunning
	runButton.AutoButtonColor = not isRunning
	runButton.BackgroundColor3 = isRunning and RUN_BUTTON_DISABLED_COLOR or ACCENT_COLOR
	runButton.Text = isRunning and "Uploading..." or "Run Upload"
	if isRunning then
		headerStatusLabel.Text = ""
	end
	if message ~= nil then
		setStatusText(message, messageColor)
	end
end

local function buildBackupString(successMap)
	local lines = {"local animalAnims = {"}
	for _, animal in ipairs(sortedKeys(successMap)) do
		table.insert(lines, string.format("    [\"%s\"] = {", animal))
		for _, animName in ipairs(sortedKeys(successMap[animal])) do
			local id = successMap[animal][animName]
			table.insert(lines, string.format("        [\"%s\"] = \"%s\",", animName, id))
		end
		table.insert(lines, "    },")
	end
	table.insert(lines, "}")
	return table.concat(lines, "\n")
end
local function runBatchUpload(uploadToGroupId)
	local sessionResults = { success = {}, errors = {} }
	local apiDisabledDetected = false
	local totalSelectedRigs = 0
	local rigsWithSuccess = {}

	print("\n[Auto-Uploader] Starting Batch Process...")
	local selected = Selection:Get()
	if #selected == 0 then
		warn("[Auto-Uploader] No rigs selected. Please select models in the workspace.")
		return false, "No rigs selected", false
	end

	for _, rig in ipairs(selected) do
		if not rig:IsA("Model") then
			warn(string.format("[Skip] %s is not a Model.", rig:GetFullName()))
			continue
		end

		totalSelectedRigs += 1

		local animalName = rig.Name
		local sequences = findAnimSource(rig)

		if not sequences then
			warn("[Skip] No animations found for: " .. animalName)
			continue
		end

		sessionResults.success[animalName] = sessionResults.success[animalName] or {}

		for _, obj in ipairs(sequences) do
			if not obj:IsA("KeyframeSequence") then
				continue
			end

			local params = {
				Name = animalName .. " " .. obj.Name,
				Description = "Auto-uploaded Animation",
				CreatorType = uploadToGroupId and Enum.AssetCreatorType.Group or Enum.AssetCreatorType.User,
			}

			if uploadToGroupId then
				params.CreatorId = uploadToGroupId
			end

			local callSuccess, resultOrError, assetId = pcall(function()
				return AssetService:CreateAssetAsync(obj, Enum.AssetType.Animation, params)
			end)

			if callSuccess and resultOrError == Enum.CreateAssetResult.Success and assetId then
				local finalId = "rbxassetid://" .. tostring(assetId)
				sessionResults.success[animalName][obj.Name] = finalId
				rigsWithSuccess[animalName] = true
				print(string.format(" [+] Uploaded: %s -> %s (%s)", animalName, obj.Name, tostring(assetId)))
			else
				local errMessage
				if callSuccess then
					errMessage = string.format("CreateAssetAsync result: %s", tostring(resultOrError))
				else
					errMessage = tostring(resultOrError)
				end

				if isCreateAssetApiDisabledError(errMessage) then
					apiDisabledDetected = true
				end

				table.insert(sessionResults.errors, {
					animal = animalName,
					anim = obj.Name,
					err = errMessage,
				})
				warn(string.format(" [!] FAILED: %s -> %s | %s", animalName, obj.Name, errMessage))
			end
		end
	end

	print("\n[Auto-Uploader] Organizing Assets...")
	local root = ServerStorage:FindFirstChild("Uploaded_Animations") or Instance.new("Folder")
	root.Name = "Uploaded_Animations"
	root.Parent = ServerStorage

	for animal, anims in pairs(sessionResults.success) do
		local folder = root:FindFirstChild(animal) or Instance.new("Folder")
		folder.Name = animal
		folder.Parent = root

		for name, id in pairs(anims) do
			local existing = folder:FindFirstChild(name)
			if existing then
				existing:Destroy()
			end

			local animation = Instance.new("Animation")
			animation.Name = name
			animation.AnimationId = id
			animation.Parent = folder
		end
	end

	print("\n------------------------------------------------")
	print("PROCESS COMPLETE")
	print("Assets saved to: ServerStorage > Uploaded_Animations")

	if #sessionResults.errors > 0 then
		warn("ERRORS DETECTED: " .. #sessionResults.errors)
		for _, entry in ipairs(sessionResults.errors) do
			warn(string.format(" > %s (%s): %s", entry.animal, entry.anim, entry.err))
		end
	else
		print("Success: All animations uploaded cleanly.")
	end

	print("\n[Backup Table Data]")
	local backupString = buildBackupString(sessionResults.success)
	print(backupString)
	print("------------------------------------------------")

	local uploadedCount = 0
	for _, anims in pairs(sessionResults.success) do
		for _ in pairs(anims) do
			uploadedCount += 1
		end
	end

	local uploadedRigCount = 0
	for _ in pairs(rigsWithSuccess) do
		uploadedRigCount += 1
	end

	return true, string.format("Uploaded %d animation(s), %d error(s)", uploadedCount, #sessionResults.errors), apiDisabledDetected, {
		uploadedCount = uploadedCount,
		errorCount = #sessionResults.errors,
		uploadedRigCount = uploadedRigCount,
		totalRigCount = totalSelectedRigs,
	}
end

local savedGroupId = plugin:GetSetting(SETTINGS_GROUP_ID_KEY)
if typeof(savedGroupId) == "number" then
	groupBox.Text = tostring(savedGroupId)
elseif typeof(savedGroupId) == "string" then
	groupBox.Text = savedGroupId
end

local requirementsSeen = plugin:GetSetting(SETTINGS_REQUIREMENTS_SEEN_KEY)
if requirementsSeen ~= true then
	showRequirementsPage()
end

groupBox.Focused:Connect(function()
	groupBox.BackgroundColor3 = INPUT_FOCUS_BG_COLOR
	groupBoxStroke.Color = INPUT_FOCUS_BORDER_COLOR
	groupBoxStroke.Thickness = 1
	groupBoxStroke.Transparency = 0.05
end)

groupBox.FocusLost:Connect(function()
	groupBox.BackgroundColor3 = INPUT_BG_COLOR
	groupBoxStroke.Color = INPUT_BORDER_COLOR
	groupBoxStroke.Thickness = 1
	groupBoxStroke.Transparency = 0.2
end)

openMainButton.MouseButton1Click:Connect(function()
	hideRequirementsPage(true)
end)

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

runButton.MouseButton1Click:Connect(function()
	local rawText = trim(groupBox.Text)
	local uploadToGroupId = nil

	if rawText ~= "" then
		uploadToGroupId = tonumber(rawText)
		if not uploadToGroupId then
			setStatusText("Group ID must be a number, or blank for personal upload", STATUS_ERROR_COLOR)
			warn("[Auto-Uploader] Invalid Group ID. Enter a numeric ID or leave blank.")
			return
		end
	end

	plugin:SetSetting(SETTINGS_GROUP_ID_KEY, rawText)
	setRunningState(true, "Running...", TEXT_SECONDARY_COLOR)

	local ok, success, message, apiDisabledDetected, summary = pcall(function()
		return runBatchUpload(uploadToGroupId)
	end)

	if ok and success then
		setRunningState(false, nil)

		if typeof(summary) == "table" then
			setUploadSummaryStatus(summary.uploadedCount, summary.errorCount, summary.uploadedRigCount, summary.totalRigCount)
		else
			local uploadedCount, errorCount = string.match(message, "Uploaded (%d+) animation%(s%), (%d+) error%(s%)")
			if uploadedCount and errorCount then
				setUploadSummaryStatus(uploadedCount, errorCount)
			else
				setStatusText(message, STATUS_SUCCESS_COLOR)
			end
		end

		if apiDisabledDetected then
			showRequirementsPage("Upload failed because CreateAssetAsync Lua API appears to be disabled.")
		end
	elseif ok then
		headerStatusLabel.Text = ""
		setRunningState(false, message, STATUS_ERROR_COLOR)
	else
		headerStatusLabel.Text = ""
		setRunningState(false, "Failed. Check Output for details.", STATUS_ERROR_COLOR)
		warn("[Auto-Uploader] Batch run failed: " .. tostring(message))
		if isCreateAssetApiDisabledError(message) then
			showRequirementsPage("Upload failed because CreateAssetAsync Lua API appears to be disabled.")
		end
	end
end)

plugin.Unloading:Connect(function()
	if widget then
		widget.Enabled = false
	end
end)
