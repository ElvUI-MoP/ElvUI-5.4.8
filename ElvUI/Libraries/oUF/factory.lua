local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck
local tinsert = table.insert

local queue = {}
local factory = CreateFrame('Frame')
factory:SetScript('OnEvent', function(self, event, ...)
	return self[event](self, event, ...)
end)

factory:RegisterEvent('PLAYER_LOGIN')
factory.active = true

function factory:PLAYER_LOGIN()
	if(not self.active) then return end

	for _, func in next, queue do
		func(oUF)
	end

	wipe(queue)
end

function oUF:Factory(func)
	argcheck(func, 2, 'function')

	if(IsLoggedIn() and factory.active) then
		return func(self)
	else
		tinsert(queue, func)
	end
end

function oUF:EnableFactory()
	factory.active = true
end

function oUF:DisableFactory()
	factory.active = nil
end

function oUF:RunFactoryQueue()
	factory:PLAYER_LOGIN()
end