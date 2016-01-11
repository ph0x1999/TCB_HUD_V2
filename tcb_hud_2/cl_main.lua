/*---------------------------------------------------------------------------
	
	Creator: TheCodingBeast - TheCodingBeast.com
	This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
	To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
	
---------------------------------------------------------------------------*/

/*--  HUD Settings --*/
local HUD 	= {}

-- Edit settings here.
HUD.X = "left" 			-- left / center / right
HUD.Y = "bottom"; 		-- bottom / center / top

HUD.HealthColor = Color(192, 57, 43, 255)
HUD.ArmorColor 	= Color(41, 128, 185, 255)

-- Don't edit anything below this line.
HUD.Width 	= 200
HUD.Height 	= 75

HUD.Border 	= 10

HUD.PosX 	= 0
HUD.PosY	= 0

/*--  Hide Default HUD Elements --*/
local hideHUDElements = {
	["DarkRP_HUD"]				= true,
	["DarkRP_EntityDisplay"] 	= true,
	["DarkRP_ZombieInfo"] 		= true,
	["DarkRP_LocalPlayerHUD"] 	= true,
	["DarkRP_Hungermod"] 		= true,
	["DarkRP_Agenda"] 			= true,
}

/*-- Hide HUD Elements --*/
local function hideElements(name)

	if name == "CHudHealth" or name == "CHudBattery" or name == "CHudSuitPower" then
		return false
	end
	
	if hideHUDElements[name] then
		return false
	end
	
end
hook.Add("HUDShouldDraw", "hideElements", hideElements)

/*-- Process Settings --*/
if HUD.X == "left" then
	HUD.PosX = HUD.Border
elseif HUD.X == "center" then
	HUD.PosX = ScrW() / 2 - HUD.Width / 2
elseif HUD.X == "right" then
	HUD.PosX = ScrW() - HUD.Border
else
	HUD.PosX = HUD.Border
end

if HUD.Y == "bottom" then
	HUD.PosY = ScrH() - HUD.Height - HUD.Border
elseif HUD.Y == "center" then
	HUD.PosY = ScrH() / 2 - HUD.Height / 2
elseif HUD.Y == "top" then
		HUD.PosY = HUD.Border
else
	HUD.PosY = ScrH() - Border
end

/*-- Format Number Function --*/
local function formatNumber(n)
	if not n then return "" end
	if n >= 1e14 then return tostring(n) end
	n = tostring(n)
	local sep = sep or ","
	local dp = string.find(n, "%.") or #n+1
	for i=dp-4, 1, -3 do
		n = n:sub(1, i) .. sep .. n:sub(i+1)
	end
	return n
end

/*-- HUD Elements --*/

HUD.BHeight = HUD.Height / 2 - 15
HUD.BPosY = HUD.PosY + HUD.Height / 2 + HUD.Border

HUD.BHeight1 = HUD.BHeight / 2 - 10
HUD.BPosY1 = HUD.BPosY + 3
HUD.BPosY2 = HUD.BPosY + 27

HUD.BarWidth = HUD.Width - 90

HUD.HHeight = HUD.Height / 2 + 11

local function Base()
	
	-- Background
	draw.RoundedBox(4, HUD.PosX-1, HUD.PosY-1, HUD.Width+2, HUD.Height+2, Color(30,30,30,255))
	draw.RoundedBox(4, HUD.PosX, HUD.PosY, HUD.Width, HUD.Height, Color(50,50,50,255))

	-- Sections
	draw.RoundedBoxEx(4, HUD.PosX, HUD.BPosY, HUD.Width, HUD.BHeight, Color(70,70,70,255), false, false, true, true)
	draw.RoundedBoxEx(4, HUD.PosX + HUD.Width - 50, HUD.PosY, 50, HUD.HHeight, Color(60,60,60,255), false, true, false, false)
	draw.RoundedBoxEx(4, HUD.PosX, HUD.PosY, 75, HUD.HHeight, Color(70,70,70,255), true, false, false, false)
	
	-- Borders
	draw.RoundedBox(0, HUD.PosX, HUD.BPosY-4, HUD.Width, 2, Color(30,30,30,255))
	draw.RoundedBox(0, HUD.PosX, HUD.BPosY-2, HUD.Width, 2, Color(90,90,90,255))
	
	draw.RoundedBox(0, HUD.PosX + HUD.Width - 50 - 4, HUD.PosY, 2, HUD.HHeight, Color(30,30,30,255))
	draw.RoundedBox(0, HUD.PosX + HUD.Width - 50 - 2, HUD.PosY, 2, HUD.HHeight, Color(90,90,90,255))
	
	draw.RoundedBox(0, HUD.PosX + 75 + 2, HUD.PosY, 2, HUD.HHeight, Color(30,30,30,255))
	draw.RoundedBox(0, HUD.PosX + 75, HUD.PosY, 2, HUD.HHeight, Color(90,90,90,255))
	
end

local function PlayerModel()

	PlayerModel = vgui.Create("DModelPanel")
	function PlayerModel:LayoutEntity( Entity ) return end
	PlayerModel:SetModel( LocalPlayer():GetModel() )
	PlayerModel:SetPos(HUD.PosX, HUD.PosY)
	PlayerModel:SetSize(75, HUD.HHeight)
	PlayerModel:SetCamPos(Vector( 16, 0, 65 ))
	PlayerModel:SetLookAt(Vector( 0, 0, 65 ))
   
	timer.Create( "UpdatePlayerModel", 0.5, 0, function()
			if LocalPlayer():GetModel() != PlayerModel.Entity:GetModel() then
					PlayerModel:Remove()
					PlayerModel = vgui.Create("DModelPanel")
					function PlayerModel:LayoutEntity( Entity ) return end         
					PlayerModel:SetModel( LocalPlayer():GetModel())
					PlayerModel:SetPos(HUD.PosX, HUD.PosY)
					PlayerModel:SetSize(75, HUD.HHeight)
					PlayerModel:SetCamPos(Vector( 16, 0, 65 ))
					PlayerModel:SetLookAt(Vector( 0, 0, 65 ))
			end
	end)

end

hook.Add("InitPostEntity", "PlayerModel", PlayerModel)

local function Health()
	
	-- Values
	local Health = LocalPlayer():Health() or 0
	local FullHealth = LocalPlayer():Health() or 0
	if Health < 0 then Health = 0 elseif Health > 100 then Health = 100 end
	local DrawHealth = math.Min(Health/GAMEMODE.Config.startinghealth, 1)
	
	-- Title
	draw.DrawText("Health", "TCB_BebasNeue_1", HUD.PosX + 10 + 1, HUD.BPosY1 + 6 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText("Health", "TCB_BebasNeue_1", HUD.PosX + 10, HUD.BPosY1 + 6, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	-- Background Bar
	draw.RoundedBox(4, HUD.PosX + 80, HUD.BPosY1 + 5, HUD.BarWidth, HUD.BHeight1, Color(30,30,30,255))
	
	-- Bar
	if Health != 0 then
		draw.RoundedBox(4, HUD.PosX + 80 + 1, HUD.BPosY1 + 5 + 1, (HUD.BarWidth - 2) * DrawHealth, HUD.BHeight1 - 2, HUD.HealthColor)
	end
	
	draw.DrawText(FullHealth, "TCB_BebasNeue_1", HUD.PosX + 80 + HUD.BarWidth / 2, HUD.BPosY1 + 6 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.DrawText(FullHealth, "TCB_BebasNeue_1", HUD.PosX + 80 + HUD.BarWidth / 2, HUD.BPosY1 + 6, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
end

local function Armor()
	
	-- Values
	local Armor = LocalPlayer():Armor() or 0
	local FullArmor = LocalPlayer():Armor() or 0
	if Armor < 0 then Armor = 0 elseif Armor > 100 then Armor = 100 end
	
	-- Title
	draw.DrawText("Armor", "TCB_BebasNeue_1", HUD.PosX + 10 + 1, HUD.BPosY2 + 6 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText("Armor", "TCB_BebasNeue_1", HUD.PosX + 10, HUD.BPosY2 + 6, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	-- Background Bar
	draw.RoundedBox(4, HUD.PosX + 80, HUD.BPosY2 + 5, HUD.BarWidth, HUD.BHeight1, Color(30,30,30,255))
	
	-- Bar
	if Armor != 0 then
		draw.RoundedBox(4, HUD.PosX + 80 + 1, HUD.BPosY2 + 5 + 1, (HUD.BarWidth - 2) * Armor / 100, HUD.BHeight1 - 2, HUD.ArmorColor)
	end
	
	draw.DrawText(Armor, "TCB_BebasNeue_1", HUD.PosX + 80 + HUD.BarWidth / 2, HUD.BPosY2 + 6 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.DrawText(Armor, "TCB_BebasNeue_1", HUD.PosX + 80 + HUD.BarWidth / 2, HUD.BPosY2 + 6, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
end

local function PlayerInfo()

	-- Values
	local VAL_Name 		= LocalPlayer():Nick() or ""
	local VAL_Job 		= LocalPlayer():getDarkRPVar("job") or ""
	local VAL_Wallet 	= "$"..formatNumber(LocalPlayer():getDarkRPVar("money") or 0)
	local VAL_Salary 	= "$"..formatNumber(LocalPlayer():getDarkRPVar("salary") or 0)

	-- Name
	draw.DrawText("Name: ", "TCB_BebasNeue_2", HUD.PosX + 85 + 1, HUD.PosY + 18 * 0 + 2.5 * 1 + 1, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText("Name: ", "TCB_BebasNeue_1", HUD.PosX + 85, HUD.PosY + 18 * 0 + 2.5 * 1, Color(192, 57, 43, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText(VAL_Name, "TCB_BebasNeue_1", HUD.PosX + 140 + 1, HUD.PosY + 18 * 0 + 2.5 * 1 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText(VAL_Name, "TCB_BebasNeue_1", HUD.PosX + 140, HUD.PosY + 18 * 0 + 2.5 * 1, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	-- Job
	draw.DrawText("Job: ", "TCB_BebasNeue_1", HUD.PosX + 85 + 1, HUD.PosY + 18 * 1 + 2.5 * 2 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText("Job: ", "TCB_BebasNeue_1", HUD.PosX + 85, HUD.PosY + 18 * 1 + 2.5 * 2, Color(192, 57, 43, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText(VAL_Job, "TCB_BebasNeue_1", HUD.PosX + 140 + 1, HUD.PosY + 18 * 1 + 2.5 * 2 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText(VAL_Job, "TCB_BebasNeue_1", HUD.PosX + 140, HUD.PosY + 18 * 1 + 2.5 * 2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	-- Wallet
	draw.DrawText("Wallet: ", "TCB_BebasNeue_1", HUD.PosX + 85 + 1, HUD.PosY + 18 * 2 + 2.5 * 3 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText("Wallet: ", "TCB_BebasNeue_1", HUD.PosX + 85, HUD.PosY + 18 * 2 + 2.5 * 3, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText(VAL_Wallet, "TCB_BebasNeue_1", HUD.PosX + 140 + 1, HUD.PosY + 18 * 2 + 2.5 * 3 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText(VAL_Wallet, "TCB_BebasNeue_1", HUD.PosX + 140, HUD.PosY + 18 * 2 + 2.5 * 3, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	-- Salary
	draw.DrawText("Salary: ", "TCB_BebasNeue_1", HUD.PosX + 85 + 1, HUD.PosY + 18 * 3 + 2.5 * 4 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText("Salary: ", "TCB_BebasNeue_1", HUD.PosX + 85, HUD.PosY + 18 * 3 + 2.5 * 4, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText(VAL_Salary, "TCB_BebasNeue_1", HUD.PosX + 140 + 1, HUD.PosY + 18 * 3 + 2.5 * 4 + 1, Color(0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.DrawText(VAL_Salary, "TCB_BebasNeue_1", HUD.PosX + 140, HUD.PosY + 18 * 3 + 2.5 * 4, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
end

local IconLicense 	= "icon16/page_red.png"
local IconWanted	= "icon16/exclamation.png"

local function PlayerIcons()

	if LocalPlayer():getDarkRPVar("HasGunlicense") then
		surface.SetDrawColor(255,255,255,255)
	else
		surface.SetDrawColor(25,25,25,255)
	end
	surface.SetMaterial(Material(IconLicense))
	surface.DrawTexturedRect( HUD.PosX + HUD.Width - 25 + 10, HUD.PosY + 15, 20, 20)
	
	if LocalPlayer():getDarkRPVar("wanted") then
		surface.SetDrawColor(255,255,255,255)
	else
		surface.SetDrawColor(25,25,25,255)
	end
	surface.SetMaterial(Material(IconWanted))
	surface.DrawTexturedRect( HUD.PosX + HUD.Width - 50 + 15, HUD.PosY + 50, 20, 20)
	
end

/*-- Default HUD Elements --*/

local function Agenda()
	local agenda = LocalPlayer():getAgendaTable()
	if not agenda then return end

	draw.RoundedBox(10, 10, 10, 460, 110, Color(0, 0, 0, 155))
	draw.RoundedBox(10, 12, 12, 456, 106, Color(51, 58, 51,100))
	draw.RoundedBox(10, 12, 12, 456, 20, Color(0, 0, 70, 100))

	draw.DrawNonParsedText(agenda.Title, "DarkRPHUD1", 30, 12, Color(255, 0, 0, 255), 0)

	local text = LocalPlayer():getDarkRPVar("agenda") or ""

	text = text:gsub("//", "\n"):gsub("\\n", "\n")
	text = DarkRP.textWrap(text, "DarkRPHUD1", 440)
	draw.DrawNonParsedText(text, "DarkRPHUD1", 30, 35, Color(255, 255, 255, 255), 0)
end

local VoiceChatTexture = surface.GetTextureID("voice/icntlk_pl")
local function DrawVoiceChat()
	if LocalPlayer().DRPIsTalking then
		local chbxX, chboxY = chat.GetChatBoxPos()

		local Rotating = math.sin(CurTime()*3)
		local backwards = 0
		if Rotating < 0 then
			Rotating = 1-(1+Rotating)
			backwards = 180
		end
		surface.SetTexture(VoiceChatTexture)
		surface.SetDrawColor(Color(140,0,0,180))
		surface.DrawTexturedRectRotated(ScrW() - 100, chboxY, Rotating*96, 96, backwards)
	end
end

CreateConVar("DarkRP_LockDown", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
local function LockDown()
	local chbxX, chboxY = chat.GetChatBoxPos()
	if util.tobool(GetConVarNumber("DarkRP_LockDown")) then
		local cin = (math.sin(CurTime()) + 1) / 2
		local chatBoxSize = math.floor(ScrH() / 4)
		draw.DrawNonParsedText(DarkRP.getPhrase("lockdown_started"), "ScoreboardSubtitle", chbxX, chboxY + chatBoxSize, Color(cin * 255, 0, 255 - (cin * 255), 255), TEXT_ALIGN_LEFT)
	end
end

if HUD.Y != "top" then
	ArrestedY = HUD.PosY - 23
	ArrestedX = HUD.PosX + HUD.Width / 2
else
	ArrestedY = ScrH() - ScrH()/12
	ArrestedX = ScrW()/2
end

local Arrested = function() end

usermessage.Hook("GotArrested", function(msg)
	local StartArrested = CurTime()
	local ArrestedUntil = msg:ReadFloat()

	Arrested = function()
		if CurTime() - StartArrested <= ArrestedUntil and LocalPlayer():getDarkRPVar("Arrested") then
		draw.DrawNonParsedText(DarkRP.getPhrase("youre_arrested", math.ceil(ArrestedUntil - (CurTime() - StartArrested))), "DarkRPHUD1", ArrestedX, ArrestedY, Color(255, 255, 255, 255), 1)
		elseif not LocalPlayer():getDarkRPVar("Arrested") then
			Arrested = function() end
		end
	end
end)

local AdminTell = function() end

usermessage.Hook("AdminTell", function(msg)
	timer.Destroy("DarkRP_AdminTell")
	local Message = msg:ReadString()

	AdminTell = function()
		draw.RoundedBox(4, 10, 10, ScrW() - 20, 100, Color(0, 0, 0, 200))
		draw.DrawNonParsedText(DarkRP.getPhrase("listen_up"), "GModToolName", ScrW() / 2 + 10, 10, Color(255, 255, 255, 255), 1)
		draw.DrawNonParsedText(Message, "ChatFont", ScrW() / 2 + 10, 80, Color(200, 30, 30, 255), 1)
	end

	timer.Create("DarkRP_AdminTell", 10, 1, function()
		AdminTell = function() end
	end)
end)

local function DrawPlayerInfo(ply)
	local pos = ply:EyePos()

	pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
	pos = pos:ToScreen()
	pos.y = pos.y - 50 -- Move the text up a few pixels to compensate for the height of the text

	-- Background
	draw.RoundedBox(4, pos.x - 101, pos.y-1, 200+2, 85+2, Color(30, 30, 30, 255))
	draw.RoundedBox(4, pos.x - 100, pos.y, 200, 85, Color(50, 50, 50, 255))
	
	draw.RoundedBoxEx(4, pos.x - 100, pos.y, 200, 80 / 3, Color(70, 70, 70, 255), true, true, false, false)
	
	draw.RoundedBox(0, pos.x - 100, pos.y + 80/3+2, 200, 2, Color(30, 30, 30, 255))
	draw.RoundedBox(0, pos.x - 100, pos.y + 80/3+0, 200, 2, Color(90,90,90,255))
	
	-- Info
	
	draw.DrawText(ply:Nick(), "TCB_BebasNeue_1", pos.x + 1, pos.y + 5 + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.DrawText(ply:Nick(), "TCB_BebasNeue_1", pos.x, pos.y + 5, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	draw.DrawText(DarkRP.getPhrase("health", ply:Health()), "TCB_BebasNeue_1", pos.x + 1, pos.y + 35 + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.DrawText(DarkRP.getPhrase("health", ply:Health()), "TCB_BebasNeue_1", pos.x, pos.y + 35, Color(192, 57, 43, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	local teamname = team.GetName(ply:Team())
	draw.DrawText("Job: "..ply:getDarkRPVar("job") or teamname, "TCB_BebasNeue_1", pos.x + 1, pos.y + 60 + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.DrawText("Job: "..ply:getDarkRPVar("job") or teamname, "TCB_BebasNeue_1", pos.x, pos.y + 60, team.GetColor(ply:Team()), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if ply:getDarkRPVar("HasGunlicense") then
		surface.SetMaterial(Material(IconLicense))
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(pos.x-16, pos.y - 60, 32, 32)
		
		draw.DrawText("Have Gun License", "TCB_BebasNeue_1", pos.x + 1, pos.y - 25 + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.DrawText("Have Gun License", "TCB_BebasNeue_1", pos.x, pos.y - 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		surface.SetMaterial(Material(IconLicense))
		surface.SetDrawColor(25,25,25,255)
		surface.DrawTexturedRect(pos.x-16, pos.y - 60, 32, 32)
		
		draw.DrawText("No Gun License", "TCB_BebasNeue_1", pos.x + 1, pos.y - 25 + 1, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.DrawText("No Gun License", "TCB_BebasNeue_1", pos.x, pos.y - 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

end

local function DrawWantedInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()
	if not pos:isInSight({LocalPlayer(), ply}) then return end

	pos.z = pos.z + 10
	pos = pos:ToScreen()
	pos.y = pos.y - 50
	
	local wantedText = "WANTED" --DarkRP.getPhrase("wanted", tostring(ply:getDarkRPVar("wantedReason")))
	
	draw.RoundedBox(4, pos.x - 51, pos.y - 100 - 5, 100+2, 30+2, Color(30, 30, 30, 255))
	draw.RoundedBox(4, pos.x - 50, pos.y - 99 - 5, 100, 30, Color(70, 70, 70, 255))
	
	draw.DrawText(wantedText, "TCB_BebasNeue_1", pos.x + 1, pos.y - 99, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.DrawText(wantedText, "TCB_BebasNeue_1", pos.x, pos.y - 100, Color(255, 0, 0, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function DrawEntityDisplay()
	local shootPos = LocalPlayer():GetShootPos()
	local aimVec = LocalPlayer():GetAimVector()

	for k, ply in pairs(players or player.GetAll()) do
		if not ply:Alive() or ply == LocalPlayer() then continue end
		local hisPos = ply:GetShootPos()
		if ply:getDarkRPVar("wanted") then DrawWantedInfo(ply) end

		if GAMEMODE.Config.globalshow then
			DrawPlayerInfo(ply)
		-- Draw when you're (almost) looking at him
		elseif not GAMEMODE.Config.globalshow and hisPos:DistToSqr(shootPos) < 160000 then
			local pos = hisPos - shootPos
			local unitPos = pos:GetNormalized()
			if unitPos:Dot(aimVec) > 0.95 then
				local trace = util.QuickTrace(shootPos, pos, LocalPlayer())
				if trace.Hit and trace.Entity ~= ply then return end
				DrawPlayerInfo(ply)
			end
		end
	end

	local tr = LocalPlayer():GetEyeTrace()

	if IsValid(tr.Entity) and tr.Entity:isKeysOwnable() and tr.Entity:GetPos():Distance(LocalPlayer():GetPos()) < 200 then
		tr.Entity:drawOwnableInfo()
	end
end

function GAMEMODE:DrawDeathNotice(x, y)
	if not GAMEMODE.Config.showdeaths then return end
	self.BaseClass:DrawDeathNotice(x, y)
end

local function DisplayNotify(msg)
	local txt = msg:ReadString()
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
	surface.PlaySound("buttons/lightswitch2.wav")

	-- Log to client console
	print(txt)
end
usermessage.Hook("_Notify", DisplayNotify)

function DisableDrawInfo()
	return false
end
hook.Add("HUDDrawTargetID", "DisableDrawInfo", DisableDrawInfo)

/*-- Draw HUD Elements --*/
local function DrawTCB()
	
	-- Custom
	Base()
	Health()
	Armor()
	PlayerInfo()
	PlayerIcons()
	
	-- Default
	Agenda()
	DrawVoiceChat()
	LockDown()
	
	Arrested()
	AdminTell()
	
	--
	DrawEntityDisplay()
	
end
hook.Add("HUDPaint", "DrawTCB", DrawTCB)
