local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck
local error = Private.error
local frame_metatable = Private.frame_metatable

local registerEvent = frame_metatable.__index.RegisterEvent
local registerUnitEvent = frame_metatable.__index.RegisterUnitEvent
local unregisterEvent = frame_metatable.__index.UnregisterEvent
local isEventRegistered = frame_metatable.__index.IsEventRegistered

local unitEvents = {}

function Private.UpdateUnits(frame, unit, realUnit)
	if(unit == realUnit) then
		realUnit = nil
	end

	if(frame.unit ~= unit or frame.realUnit ~= realUnit) then
		for event in next, unitEvents do
			local registered, unit1 = isEventRegistered(frame, event)
			if(registered and unit1 ~= unit) then
				registerUnitEvent(frame, event, unit, realUnit)
			end
		end

		frame.unit = unit
		frame.realUnit = realUnit
		frame.id = unit:match('^.-(%d+)')
		return true
	end
end

local function onEvent(self, event, ...)
	if(self:IsVisible() or event == 'UNIT_COMBO_POINTS') then
		return self[event](self, event, ...)
	end
end

local event_metatable = {
	__call = function(funcs, self, ...)
		for _, func in next, funcs do
			func(self, ...)
		end
	end,
}

function frame_metatable.__index:RegisterEvent(event, func, unitless)
	-- Block OnUpdate polled frames from registering events except for
	-- UNIT_PORTRAIT_UPDATE and UNIT_MODEL_CHANGED which are used for
	-- portrait updates.
	if(self.__eventless and event ~= 'UNIT_PORTRAIT_UPDATE' and event ~= 'UNIT_MODEL_CHANGED') then return end

	argcheck(event, 2, 'string')

	if(type(func) == 'string' and type(self[func]) == 'function') then
		func = self[func]
	end

	if(not unitless and not (unitEvents[event] or event:match('^UNIT_'))) then
		unitless = true
	end

	local curev = self[event]
	local kind = type(curev)
	if(curev and func) then
		if(kind == 'function' and curev ~= func) then
			self[event] = setmetatable({curev, func}, event_metatable)
		elseif(kind == 'table') then
			for _, infunc in next, curev do
				if(infunc == func) then return end
			end

			table.insert(curev, func)
		end
	elseif(isEventRegistered(self, event)) then
		return
	else
		if(type(func) == 'function') then
			self[event] = func
		elseif(not self[event]) then
			return error("Style [%s] attempted to register event [%s] on unit [%s] with a handler that doesn't exist.", self.style, event, self.unit or 'unknown')
		end

		if not self:GetScript('OnEvent') then
			self:SetScript('OnEvent', onEvent)
		end

		if unitless then
			registerEvent(self, event)
		else
			unitEvents[event] = true
			registerUnitEvent(self, event, self.unit)
		end
	end
end

function frame_metatable.__index:UnregisterEvent(event, func)
	argcheck(event, 2, 'string')

	local cleanUp = false
	local curev = self[event]
	if(type(curev) == 'table' and func) then
		for k, infunc in next, curev do
			if(infunc == func) then
				curev[k] = nil
				break
			end
		end
	if(not next(curev)) then
			cleanUp = true
		end
	end

	if(cleanUp or curev == func) then
		self[event] = nil
		unregisterEvent(self, event)
	end
end