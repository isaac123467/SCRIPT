local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetProtectionModule = require(game.ServerScriptService:WaitForChild("AssetProtectionModule"))

-- === CONFIG ===
local allowedPlaceIds = {
	[75749277590860] = true, -- Replace with your allowed PlaceIds
}

local criticalParts = {
	workspace:FindFirstChild("Flow² Remastered - Extra Panel Kit - By ninjaninja140"),
	workspace:FindFirstChild("Fused Spur"),
	workspace:FindFirstChild("Shelf 1"),
	workspace:FindFirstChild("R-D Wi-Fi Router"),
	workspace:FindFirstChild("PreheatFlushmountFixtures"),
	workspace:FindFirstChild("Model"),
	workspace:FindFirstChild("Part"),
	workspace:FindFirstChild("s_keeper | Sensmatic Group"),
	workspace:FindFirstChild("DRS | DRSGo"),
	workspace:FindFirstChild("Oron - Smoke Light"),
	workspace:FindFirstChild("Theta Technologies: Opus IP Audio System"),
	workspace:FindFirstChild("cgk Dev - Traffic Management Pack"),
	workspace:FindFirstChild("Prop House"),
}

local webhookURL = "https://discord.com/api/webhooks/1364701662744154303/lhyvGWyb6ZKwadd_bp-y58pbG05tovFNDG1vDrdlek1MiVC0ZsW8fPOEXR-QeotLqNXQ"
local enableLogging = true
local debugMode = false

-- === HELPERS ===
local function sendWebhook(message)
	if enableLogging and webhookURL and webhookURL ~= "" then
		pcall(function()
			HttpService:PostAsync(webhookURL, HttpService:JSONEncode({
				content = message
			}))
		end)
	end
end

local function nukeMap(reason)
	sendWebhook("**[ISAAC HOLDINGS || ASSET PROTECTION] Map nuked! Reason:** " .. reason)
	warn("[ISAAC HOLDINGS || ASSET PROTECTION] Nuking map! Reason: " .. reason)

	if debugMode then return end

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Folder") then
			pcall(function()
				obj:Destroy()
			end)
		end
	end
end

-- === WHITELIST CHECK ===
if not allowedPlaceIds[game.PlaceId] then
	warn("[ISAAC HOLDINGS || ASSET PROTECTION] Unauthorized game detected!")
	nukeMap("Unauthorized PlaceId: " .. game.PlaceId)
end

-- === PART EXISTENCE CHECK ===
for _, part in ipairs(criticalParts) do
	if not part then
		warn("[ISAAC HOLDINGS || ASSET PROTECTION] Critical part missing!")
		nukeMap("Critical asset missing: " .. tostring(part))
		break
	end
end

-- === REMOTE EVENT HANDLER ===
local signal = ReplicatedStorage:FindFirstChild("AssetPing") or Instance.new("RemoteEvent")
signal.Name = "AssetPing"
signal.Parent = ReplicatedStorage

-- Handle the asset ping and log it
signal.OnServerEvent:Connect(function(player, assetName, assetId)
	local message = "**[Asset Ping]** Player: `" .. player.Name .. "` | Asset: `" .. assetName .. "` | ID: `" .. tostring(assetId) .. "`"
	print(message)
	sendWebhook(message)
end)

-- === INITIALIZE ASSET PROTECTION SYSTEM ===
AssetProtectionModule.initializeProtection()
