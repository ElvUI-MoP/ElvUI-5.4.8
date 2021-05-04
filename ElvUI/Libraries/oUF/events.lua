local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck
local error = Private.error
local frame_metatable = Private.frame_metatable

-- Original event methods
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
		-- don't let invalid units in, otherwise unit events will end up being
		-- registered as unitless
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
	if(self:IsVisible()) then
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

--[[ Events: frame:RegisterEvent(event, func)
Used to register a frame for a game event and add an event handler. OnUpdate polled frames are prevented from
registering events.

* self     - frame that will be registered for the given event.
* event    - name of the event to register (string)
* func     - a function that will be executed when the event fires. Multiple functions can be added for the same frame
             and event (function)
--]]
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
	if(curev) then
		if(kind == 'function' and curev ~= func) then
			self[event] = setmetatable({curev, func}, event_metatable)
		elseif(kind == 'table') then
			for _, infunc in next, curev do
				if(infunc == func) then return end
			end

			table.insert(curev, func)
		end
	else
		self[event] = func

		if(not self:GetScript('OnEvent')) then
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

--[[ Events: frame:UnregisterEvent(event, func)
Used to remove a function from the event handler list for a game event.

* self  - the frame registered for the event
* event - name of the registered event (string)
* func  - function to be removed from the list of event handlers. If this is the only handler for the given event, then
          the frame will be unregistered for the event (function)
--]]
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
		if(self.unitEvents) then
			self.unitEvents[event] = nil
		end

		unregisterEvent(self, event)
	end
end