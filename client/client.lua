local RESULT, ENTITY, NAME, COORDS, PREVIOUS, ZONE, PREVIOUSZONE, SCALEX, SCALEY, SCALEZ

local hashes_file = LoadResourceFile(GetCurrentResourceName(), "hashes.json")
local hashes = json.decode(hashes_file)

local function round(num, numDecimalPlaces)
	local mult = 10 ^ (numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function parseBox(zone)
	return
			"{\n"
			..
			"\tcoords = " ..
			"vector3(" ..
			tostring(round(zone.center.x, 2)) ..
			", " .. tostring(round(zone.center.y, 2)) .. ", " .. tostring(round(zone.center.z, 2)) .. "),\n"
			.. "\tlength = " .. tostring(zone.length) .. ",\n"
			.. "\twidth = " .. tostring(zone.width) .. ",\n"
			.. "\tname = \"" .. zone.name .. "\",\n"
			.. "\theading = " .. zone.offsetRot .. ",\n"
			.. "\tminZ = " .. tostring(round(zone.minZ, 2)) .. ",\n"
			.. "\tmaxZ = " .. tostring(round(zone.maxZ, 2)) .. ",\n"
			.. "}\n"
end

local function destoryZone()
	if ZONE then ZONE:destroy() end
end

local function drawEntityZone()
	destoryZone()
	ZONE = EntityZone:Create(ENTITY, {
		name = NAME,
		debugPoly = true,
		useZ = true,
		scale = scale or { SCALEX, SCALEY, SCALEZ }
	})
end

RegisterCommand('polygunsave', function()
	if not Config.loopOn or not ZONE or ZONE == PREVIOUSZONE then return end
	local text = parseBox(ZONE)
	if Config.clipboard then lib.setClipboard(text) end
	TriggerServerEvent('polygun:save', ZONE, text)
	lib.notify({
		title = 'Box Zone Saved',
		duration = 7500,
		description = 'Check zones.txt inside the polygun resource',
		type = 'success'
	})
	PREVIOUSZONE = ZONE
end)

RegisterKeyMapping('polygunsave', 'Save selected polyzone', 'keyboard', Config.defaultSaveKey)

-- Thread that makes everything happen.
Citizen.CreateThread(function()                                  -- Create the thread.
	while true do                                                  -- Loop it infinitely.
		local pause = 250                                            -- If infos are off, set loop to every 250ms. Eats less resources.
		if Config.loopOn then                                        -- If the info is on then...
			pause = 5                                                  -- Only loop every 5ms (equivalent of 200fps).
			local player = PlayerId()
			if IsPlayerFreeAiming(player) then                         -- If the player is free-aiming (update texts)...
				local start = GetPedBoneCoords(PlayerPedId(), 57005, 0.0, 0.0, 0.0)
				local result, entity = GetEntityPlayerIsFreeAimingAt(player) -- Get what the player is aiming at. This isn't actually the function, that's below the thread.
				if result then
					RESULT = result
					ENTITY = entity
					COORDS = GetEntityCoords(ENTITY)
					if Config.debugAimLine then
						DrawLine(start.x, start.y, start.z, COORDS.x, COORDS.y, COORDS.z, 0, 255, 0, 255)
					end
				elseif Config.debugAimLine then
					local finish = GetWorldCoordFromScreenCoord(0.5, 0.5)
					DrawLine(start.x, start.y, start.z, finish.x, finish.y, finish.z, 0, 255, 0, 255)
				end
			end
			if RESULT then
				local heading = GetEntityHeading(ENTITY)
				local model = GetEntityModel(ENTITY)
				NAME = hashes[tostring(model)] or 'unknown'
				if Config.debugText then
					DrawInfos("Coordinates: " .. COORDS, "Heading: " .. heading, "Hash: " .. model, "Name: " .. NAME)
				end
				if ENTITY ~= PREVIOUS then
					SCALEX = 1.0
					SCALEY = 1.0
					SCALEZ = 1.0
					drawEntityZone()
					PREVIOUS = ENTITY
				end
				if IsControlJustPressed(0, 241) or IsDisabledControlPressed(1, 241) then -- Scroll Up
					SCALEX = SCALEX + Config.addX
					SCALEY = SCALEY + Config.addY
					SCALEZ = SCALEZ + Config.addZ
					drawEntityZone()
				end
				if IsControlJustPressed(0, 242) or IsDisabledControlPressed(1, 242) then -- Scroll down
					SCALEX = SCALEX - Config.subX
					SCALEY = SCALEY - Config.subY
					SCALEZ = SCALEZ - Config.subZ
					drawEntityZone()
				end

				if IsControlPressed(1, Config.addXControl) or IsDisabledControlPressed(1, Config.addXControl) then -- Up Arrow
					SCALEX = SCALEX + Config.addX
					drawEntityZone()
				end
				if IsControlPressed(1, Config.subXControl) or IsDisabledControlPressed(1, Config.subXControl) then -- Down Arrow
					SCALEX = SCALEX - Config.subZ
					drawEntityZone()
				end

				if IsControlPressed(1, Config.subYControl) or IsDisabledControlPressed(1, Config.subYControl) then -- Left Arrow
					SCALEY = SCALEY - Config.subY
					drawEntityZone()
				end
				if IsControlPressed(1, Config.addYControl) or IsDisabledControlPressed(1, Config.addYControl) then -- Right Arrow
					SCALEY = SCALEY + Config.addY
					drawEntityZone()
				end

				if IsControlPressed(1, Config.addZControl) or IsDisabledControlPressed(1, Config.addZControl) then -- Page Up
					SCALEZ = SCALEZ + Config.addZ
					drawEntityZone()
				end
				if IsControlPressed(1, Config.subZControl) or IsDisabledControlPressed(1, Config.subZControl) then -- Page Down
					SCALEZ = SCALEZ - Config.subZ
					drawEntityZone()
				end
			end
		end               -- Info is off, don't need to do anything.
		Citizen.Wait(pause) -- Now wait the specified time.
	end                 -- End (stop looping).
end)                  -- Endind the entire thread here.

-- Ends the function.
-- Function to draw the text.
function DrawInfos(...)
	local args = { ... }

	local ypos = Config.ypos
	for k, v in pairs(args) do
		SetTextColour(255, 255, 255, 255) -- Color
		SetTextFont(0)                   -- Font
		SetTextScale(0.4, 0.4)           -- Scale
		SetTextWrap(0.0, 1.0)            -- Wrap the text
		SetTextCentre(false)             -- Align to center(?)
		SetTextDropshadow(0, 0, 0, 0, 255) -- Shadow. Distance, R, G, B, Alpha.
		SetTextEdge(50, 0, 0, 0, 255)    -- Edge. Width, R, G, B, Alpha.
		SetTextOutline()                 -- Necessary to give it an outline.
		SetTextEntry("STRING")
		AddTextComponentString(v)
		DrawText(0.015, ypos) -- Position
		ypos = ypos + 0.028
	end
end

-- Creating the function to toggle the info.
ToggleInfos = function()           -- "ToggleInfos" is a function
	Config.loopOn = not Config.loopOn -- Switch them around
end                                -- Ending the function here.

-- Creating the command.
RegisterCommand("polygun", function() -- Listen for this command.
	destoryZone()
	ToggleInfos()                       -- Heard it! Let's toggle the function above.
end)                                  -- Ending the function here.
