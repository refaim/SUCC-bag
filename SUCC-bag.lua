local function isSortingAddonLoaded()
	return SortBags ~= nil and SortBankBags ~= nil or Clean_Up ~= nil
end

local function sortItems(where, reversed)
	if SortBags ~= nil and SortBankBags ~= nil then
		local oldReversed = GetSortBagsRightToLeft()
		SetSortBagsRightToLeft(reversed)
		if where == "bags" then
			SortBags()
		elseif where == "bank" then
			SortBankBags()
		end
		SetSortBagsRightToLeft(oldReversed)
	elseif Clean_Up ~= nil then
		Clean_Up(where, reversed)
	end
end

local function SUCC_bagDefaults()
	SUCC_bagOptions = {}
	SUCC_bagOptions.colors = {}
	SUCC_bagOptions.colors.highlight = {1, 0.2, 0.2 }
	SUCC_bagOptions.colors.quest = {0.96, 0.64, 0.94}
	SUCC_bagOptions.colors.ammo = {0.8, 0.8, 0.3}
	SUCC_bagOptions.colors.BG = {0.98, 0.95, 0}
	SUCC_bagOptions.colors.border = {1, 1, 1}
	SUCC_bagOptions.colors.backdrop = {0.3, 0.3, 0.3}
	SUCC_bagOptions.colors.bag = {}
	SUCC_bagOptions.colors.bag['Bag'] = {0.3, 0.3, 0.3}
	SUCC_bagOptions.colors.bag['Soul Bag'] = {0.678, 0.549, 1}
	SUCC_bagOptions.colors.bag['Herb Bag'] = {0.3, 0.8, 0.3}
	SUCC_bagOptions.colors.bag['Enchanting Bag'] = {0.5, 0.4, 0.8}
	SUCC_bagOptions.colors.override = false
	SUCC_bagOptions.layout = {}
	SUCC_bagOptions.layout.spacing = 4
	SUCC_bagOptions.layout.columns ={}
	SUCC_bagOptions.layout.columns.bag = 11
	SUCC_bagOptions.layout.columns.bank = 11
	SUCC_bagOptions.Clean_Up = 1
	SUCC_bagOptions.position = {}
	SUCC_bagOptions.position["SUCC_bag"] = {1000.0, 380.0}
	SUCC_bagOptions.position["SUCC_bagBank"] = {640.0, 440.0}
	SUCC_bagOptions.position["SUCC_bagKeyring"] = {760.0, 740.0}
	return SUCC_bagOptions
end

-- debug
local function print(mes)
	DEFAULT_CHAT_FRAME:AddMessage(mes)
end

local function	moneyToString(money)
	local coins = {}
	local wealth = GetMoney()
	local string = ''
	coins['|cFFFFFF00g|cFFFFFFFF '] = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
	coins['|cFFAAAAAAs|cFFFFFFFF '] = floor((money - (coins['|cFFFFFF00g|cFFFFFFFF '] * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
	coins['|cFFEE9944c'] = mod(money, COPPER_PER_SILVER)
	for k, i in pairs(coins) do
		if i > 0 then
			if wealth < money then
				i = '|cFFFF0000' .. i
			end
			string = string .. i .. k
		end
	end
	return string
end

local function FrameTrimToSize(frame)
	local frameName = frame:GetName()
	local slot, height, width
	if not frame.size or frame.size == 0 then
		height = 64
		width = 256
	else
		local slot = frame.size + 1
		local button = getglobal(frameName .. 'Item'.. slot)
		while button do
			button:Hide()
			slot = slot + 1
			button = getglobal(frameName .. 'Item'.. slot)
		end
		if frame.size < frame.cols then
			width = (37 + frame.space) * frame.size + 14 - frame.space
		else
			width = (37 + frame.space) * frame.cols + 14 - frame.space
		end
		height = (37 + frame.space) * math.ceil(frame.size / frame.cols)  + 32 - frame.space
	end
	frame:SetWidth(width)
	frame:SetHeight(height)
end

local function TitleLayout(frame)
	if not frame.slotFrame then return end
	if frame.cuBag and SUCC_bagOptions.Clean_Up == 1 then
		frame.title:ClearAllPoints()
		frame.title:SetPoint('LEFT', frame.cuBag, 'RIGHT', 3, 0)
		frame.cuBag:SetPoint('LEFT', frame.toggleButton, 'RIGHT', 3, 0)
		if not frame.cuBag:IsVisible() then frame.cuBag:Show() end
	else
		if frame.cuBag then frame.cuBag:Hide() end
		frame.title:ClearAllPoints()
		frame.title:SetPoint('LEFT', frame.toggleButton, 'RIGHT', 3, 0)
	end
end

local function SlotFrameSetup(frame)
	frame.slotFrame:SetFrameLevel(0)
	frame.slotFrame:SetPoint('TOPRIGHT', frame, 'TOPLEFT', 8, -16)
	frame.slotFrame:SetBackdrop({
		bgFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\marble',
		edgeFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\BagSlotFrame',
		tile = true,
		tileSize = 128,
		edgeSize = 32,
		insets = {
			left = 5,
			right = 0,
			top = 5,
			bottom = 5
		}
	})
	frame.slotFrame:SetBackdropBorderColor(unpack(SUCC_bagOptions.colors.border))
	frame.slotFrame:SetBackdropColor(unpack(SUCC_bagOptions.colors.backdrop))
	frame.slotFrame:Hide()
end

local function FrameLayout(frame, cols)
	if not frame.size then return end
	local frameName = frame:GetName()
	if not cols then
		cols = frame.cols or SUCC_bagOptions.layout.columns.bag or 8
	end
	frame.cols = cols
	local space = SUCC_bagOptions.layout.spacing or 4
	frame.space = space
	local rows = math.ceil(frame.size / cols)
	local button = getglobal(frameName .. 'Item1')
	if button then
		local index = 1
		button:ClearAllPoints()
		button:SetPoint('TOPLEFT', frame, 9, -25)
		for i = 1, rows, 1 do
			for j = 1, cols, 1 do
				index = index + 1
				button = getglobal(frameName .. 'Item' .. index)
				if not button then break end
				button:ClearAllPoints()
				button:SetPoint('LEFT', frameName .. 'Item' .. index - 1, 'RIGHT', space, 0)
			end
			button = getglobal(frameName .. 'Item' .. index)
			if not button then break end
			button:ClearAllPoints()
			button:SetPoint('TOP', frameName .. 'Item' .. index - cols, 'BOTTOM', 0, -space)
		end
	end
	if frame.slotFrame then
		local totalslots = table.getn(frame.slotFrame.slot)
		local bagcols, slot = math.ceil(totalslots / rows), 2
		frame.slotFrame.slot[1]:ClearAllPoints()
		frame.slotFrame.slot[1]:SetPoint('TOPLEFT', frame.slotFrame, 7, -9)
		frame.slotFrame:SetWidth((37 + SUCC_bagOptions.layout.spacing) * bagcols + 14 - SUCC_bagOptions.layout.spacing)
		for i = 1, rows, 1 do
			if bagcols > 1 then
				for j = 2, bagcols, 1 do
					if not frame.slotFrame.slot[slot] then break end
					frame.slotFrame.slot[slot]:ClearAllPoints()
					frame.slotFrame.slot[slot]:SetPoint('LEFT', frame.slotFrame.slot[slot - 1], 'RIGHT', space, 0)
					slot = slot + 1
				end
			end
			if not frame.slotFrame.slot[slot] then
				frame.slotFrame:SetHeight((37 + SUCC_bagOptions.layout.spacing) * i  + 14 - SUCC_bagOptions.layout.spacing)
				break
			end
			frame.slotFrame.slot[slot]:ClearAllPoints()
			frame.slotFrame.slot[slot]:SetPoint('TOP', frame.slotFrame.slot[slot - bagcols], 'BOTTOM', 0, -space)
			slot = slot + 1
		end
	end
	FrameTrimToSize(frame)
end

local function BagType (bagID)
	if bagID > 0 then
		local link = GetInventoryItemLink('player', ContainerIDToInventoryID(bagID))
		if(link) then
			local _, _, id = string.find(link, "item:(%d+)")
			local _, _, _, _, itemType, subType = GetItemInfo(id)
			if itemType == 'Quiver' then
				return SUCC_bagOptions.colors.ammo
			else
				return SUCC_bagOptions.colors.bag[subType], subType == 'Bag'
			end
		end
	end
	return SUCC_bagOptions.colors.bag.Bag, true
end

local function ItemUpdateBorder(button, option)
	if option then
		button:GetNormalTexture():SetVertexColor(unpack(SUCC_bagOptions.colors.highlight))
	elseif not button:GetParent().colorLocked then
		local bagID = button:GetParent():GetID()
		local v, c = BagType(bagID)
		if c or SUCC_bagOptions.colors.override then
			local link = GetContainerItemLink(bagID, button:GetID())
			if link then
				local _, _, id = string.find(link, "item:(%d+)")
				local n, _, q, _, _, t = GetItemInfo(id)
				if n ~= nil and string.find(n, 'Mark of Honor') then
					button:GetNormalTexture():SetVertexColor(unpack(SUCC_bagOptions.colors.BG))
					return
				elseif t == 'Quest' then
					button:GetNormalTexture():SetVertexColor(unpack(SUCC_bagOptions.colors.quest))
					return
				elseif q ~= nil and q > 1 then
					button:GetNormalTexture():SetVertexColor(GetItemQualityColor(q))
					return
				end
			end
		end
		button:GetNormalTexture():SetVertexColor(unpack(v))
	end
end

local function HighlightBagSlots(bagID, option)
	local frame = getglobal('SUCC_bagDummyBag' .. bagID)
	if frame then
		local items = {frame:GetChildren()}
		if option then frame.colorLocked = 1 else  frame.colorLocked = nil end
		for _, item in pairs(items) do
			ItemUpdateBorder(item, option)
		end
	end
end

local function ItemUpdate(item)
	local texture, itemCount, readable, locked
	texture, itemCount, locked, _, readable = GetContainerItemInfo(item:GetParent():GetID(), item:GetID())
	ItemUpdateBorder(item)
	if texture then
		ContainerFrame_UpdateCooldown(item:GetParent():GetID() , item)
		item.hasItem = 1
	else
		getglobal(item:GetName() .. 'Cooldown'):Hide()
		item.hasItem = nil
	end
	SetItemButtonDesaturated(item, locked, 0.5, 0.5, 0.5)
	SetItemButtonTexture( item, texture )
	SetItemButtonCount( item, itemCount )
	local showSell = nil
	if GameTooltip:IsOwned(item) then
		if texture then
			local hasCooldown, repairCost = GameTooltip:SetBagItem(item:GetParent():GetID(),item:GetID())
			if ( InRepairMode() and (repairCost > 0) ) then
				GameTooltip:AddLine(TEXT(REPAIR_COST), "", 1, 1, 1)
				SetTooltipMoney(GameTooltip, repairCost)
				GameTooltip:Show()
			elseif ( MerchantFrame:IsShown() and not locked) then
				showSell = 1
			end
		else
			GameTooltip:Hide()
		end
		if showSell then
			ShowContainerSellCursor(item:GetParent():GetID(), item:GetID())
		elseif readable then
			ShowInspectCursor()
		else
			ResetCursor()
		end
	end
end

local function ItemCreate(name, parent)
	local button
	if parent:GetID() == -1 then
		button = CreateFrame('Button', name, parent, 'BankItemButtonGenericTemplate')
		CreateFrame('Model', name .. 'Cooldown', button, 'CooldownFrameTemplate')
	else
		button = CreateFrame('Button', name, parent, 'ContainerFrameItemButtonTemplate')
	end
	button:SetNormalTexture('Interface\\AddOns\\SUCC-bag\\Textures\\Slot')
	button.bg = button:CreateTexture(nil, 'BACKGROUND')
	button.bg:SetTexture[[Interface\PaperDoll\UI-Backpack-EmptySlot]]
	button.bg:SetAlpha(.75)
	button.bg:SetAllPoints()
	button:SetAlpha(parent:GetParent():GetAlpha())
	return button
end

local dummyBag = {}

local function CreateDummyBag(parent, bagID)
	local dummyBag = CreateFrame('Frame', 'SUCC_bagDummyBag' .. bagID, parent)
	dummyBag:SetID(bagID)
	return dummyBag
end

local function AddBag(frame, bagID)
	if not dummyBag[bagID] then
		dummyBag[bagID] = CreateDummyBag(frame, bagID)
	end
	if dummyBag.removed == bagID then dummyBag.removed = nil return end
	local frameName = frame:GetName()
	local slot = frame.size
	local bagSize
	if(bagID == KEYRING_CONTAINER) then
		bagSize = GetKeyRingSize()
	else
		bagSize = GetContainerNumSlots(bagID)
	end
	dummyBag[bagID].size = bagSize
	for index = 1, bagSize, 1 do
		slot = slot + 1
		local item = getglobal( frameName .. 'Item'.. slot) or ItemCreate(frameName .. 'Item'.. slot, dummyBag[bagID])
		item:SetID(index)
		item:SetParent(dummyBag[bagID])
		item:Show()
		ItemUpdate(item)
	end
	frame.size = frame.size + bagSize
end

local function FrameGenerate(frame)
	frame.size = 0
	local frameName = frame:GetName()
	if frame.moneyFrame then
		MoneyFrame_Update(frameName .. 'MoneyFrame', GetMoney())
	end
	for _, bagID in pairs(frame.bags) do
		AddBag(frame, bagID)
	end
	FrameLayout(frame)
	frame:Show()
end

local function RemoveBag(frame, bagID, bagSize)
	if dummyBag[bagID] and dummyBag[bagID].size ~= bagSize then
		FrameGenerate(frame)
		return 1
	else
		return nil
	end
end

local function FrameUpdate(frame, bagID)
	local frameName = frame:GetName()
	local startSlot = 1
	local endSlot
	if not bagID then
		endSlot = frame.size
	else
		if bagID == KEYRING_CONTAINER then
			endSlot = GetKeyRingSize()
			frameName = SUCC_bag.keyring:GetName()
		else
			if not frame.size --[[or RemoveBag(frame, bagID, GetContainerNumSlots(bagID))]] then return end
			for _, bag in pairs(frame.bags) do
				if bag == bagID then
					endSlot = startSlot + GetContainerNumSlots(bag) - 1
					break
				else
					startSlot = startSlot + GetContainerNumSlots(bag)
				end
			end
		end
	end
	for slot = startSlot, endSlot do
		local item = getglobal(frameName .. 'Item' .. slot)
		if item then
			ItemUpdate(item)
		end
	end
end

local function FrameUpdateLock(frame)
	if not frame.size then return end
	local frameName = frame:GetName()
	for slot = 1, frame.size do
		local item = getglobal(frameName .. 'Item' .. slot)
		local _, _, locked = GetContainerItemInfo(item:GetParent():GetID(), item:GetID())
		SetItemButtonDesaturated(item, locked, 0.5, 0.5, 0.5)
	end
end

local function SUCC_search()
	local search = CreateFrame("Frame", nil, SUCC_bag)
	search:SetPoint("TOPLEFT", SUCC_bag, "BOTTOMLEFT", 4, 4)
	search:SetHeight(29)
	search:SetWidth(115) -- 132
	search:SetBackdrop({
		bgFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\marble',
		edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
		tile = true, tileSize = 8, edgeSize = 16,
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	})
	search:SetBackdropBorderColor(.5,.5,.5,1)
	search:SetBackdropColor(unpack(SUCC_bagOptions.colors.backdrop))

	search.text = search:CreateFontString(nil, "HIGH", "GameTooltipTextSmall")
	local font, size = search.text:GetFont()
	
	search.edit = CreateFrame("EditBox", nil, search, "InputBoxTemplate")
	search.edit:SetMaxLetters(14)	
	search.edit:SetPoint("LEFT", search, "LEFT", 10, 0)
	search.edit:SetHeight(20)
	search.edit:SetWidth(100)
	search.edit:SetFont(font, size, "OUTLINE")
	search.edit:SetAutoFocus(false)
	search.edit:SetText("Search")
	search.edit:SetTextColor(1,1,1,1)

	search.button = CreateFrame("Button", nil, search.edit)
	search.button:SetFrameStrata("LOW")	
	search.button:SetWidth(25)
	search.button:SetHeight(25)
	search.button:SetPoint("LEFT", search.edit, "RIGHT", 0, 0)
	search.button:SetBackdrop({
		bgFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\marble',
		edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
		tile = true, tileSize = 8, edgeSize = 16,
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	})
	search.button:SetBackdropBorderColor(.5,.5,.5,1)
	search.button:SetBackdropColor(unpack(SUCC_bagOptions.colors.backdrop))
	search.button:EnableMouse(true) 
	search.button:Hide()
	
	search.icon = search.edit:CreateTexture(nil, "OVERLAY")
	search.icon:SetPoint("CENTER", search.button, "CENTER", 1, 0)
	search.icon:SetWidth(27)
	search.icon:SetHeight(27)
	search.icon:SetTexture('Interface\\Buttons\\UI-Panel-MinimizeButton-Disabled')
	search.icon:Hide()

	local function buttons(frame, a)
		if frame:IsVisible() then
			local name = frame:GetName()
			for slot=1, frame.size do
				getglobal(name.."Item"..slot):SetAlpha(a)
			end
		end
	end

	local function searchBag(frame)
		if frame:IsVisible() then
			local name = frame:GetName()
			for slot = 1, frame.size do
				local item = getglobal(name.."Item"..slot)
				local _, itemCount = GetContainerItemInfo(item:GetParent():GetID(), item:GetID())
				if itemCount then
					local itemLink = GetContainerItemLink(item:GetParent():GetID(), item:GetID())
					local itemstring = string.sub(itemLink, string.find(itemLink, "%[")+1, string.find(itemLink, "%]")-1)
					if strfind(strlower(itemstring), strlower(string.gsub(this:GetText(), "([^%w])", "%%%1"))) then
						item:SetAlpha(1)
					end
				end
			end
		end
	end

	local function reset()        
		search.edit:SetText("Search")
		buttons(SUCC_bag, 1)
		buttons(SUCC_bag.bank, 1)
		buttons(SUCC_bag.keyring, 1)
		search.button:Hide()
		search.icon:Hide()
        search.edit:UnregisterEvent("BAG_UPDATE")
	end

	search.edit:SetScript("OnEditFocusGained", function()
		search.edit:SetText("")
        search.edit:RegisterEvent("BAG_UPDATE")
	end)

	search.edit:SetScript("OnEditFocusLost", function()
		reset()			
	end)

	search.edit:SetScript("OnTabPressed", function()
		search.edit:ClearFocus()
		reset()
	end)

	search.button:SetScript("OnClick", function()
		search.edit:ClearFocus()
		reset()
	end)	

	search.edit:SetScript("OnTextChanged", function()
		if this:GetText() == "Search" then return end
		buttons(SUCC_bag, .25)
		buttons(SUCC_bag.bank, .25)
		buttons(SUCC_bag.keyring, .25)

		searchBag(SUCC_bag)
		searchBag(SUCC_bag.bank)
		searchBag(SUCC_bag.keyring)

		if not search.button:IsVisible() then
			search.button:Show()
			search.icon:Show()
		end
	end)

    search.edit:SetScript("OnEvent", function()
        if this:GetText() == "Search" then return end
		buttons(SUCC_bag, .25)
		buttons(SUCC_bag.bank, .25)
		buttons(SUCC_bag.keyring, .25)

		searchBag(SUCC_bag)
		searchBag(SUCC_bag.bank)
		searchBag(SUCC_bag.keyring)

		if not search.button:IsVisible() then
			search.button:Show()
			search.icon:Show()
		end
    end)
end

local function Essentials(frame)
	local t = frame:GetName()
	if not SUCC_bagOptions.position then
		SUCC_bagOptions.position = {}
	end
	if not SUCC_bagOptions.position[t] then
		SUCC_bagOptions.position[t] = {frame:GetCenter()}
	end
	frame:SetScript('OnMouseDown', function() this:StartMoving() end)
	frame:SetScript('OnMouseUp', function()
		this:StopMovingOrSizing()
		SUCC_bagOptions.position[t] = {frame:GetCenter()}
	end)
	frame:SetToplevel()
	frame:EnableMouse()
	frame:SetMovable()
	frame:SetUserPlaced(true)
	frame:SetClampedToScreen()
	frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", unpack(SUCC_bagOptions.position[t] or {frame:GetCenter()}))
	frame:SetBackdrop({
		bgFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\marble',
		edgeFile = 'Interface\\AddOns\\SUCC-bag\\Textures\\BagFrame',
		tile = true,
		tileSize = 128,
		edgeSize = 32,
		insets = {
			left = 5,
			right = 5,
			top = 22,
			bottom = 5
		},
	})
	frame:SetBackdropBorderColor(unpack(SUCC_bagOptions.colors.border))
	frame:SetBackdropColor(unpack(SUCC_bagOptions.colors.backdrop))
	frame:Hide()
	tinsert(UISpecialFrames, t)
	frame.closeButton = CreateFrame('Button', t .. 'CloseButton', frame, 'UIPanelCloseButton')
	frame.closeButton:SetPoint('TOPRIGHT', frame, 4, 4)
	frame.closeButton:SetScript('OnClick', function() SBFrameClose(frame) end)
	frame.title = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	frame.title:SetPoint('TOPLEFT', frame, 11, -6)
	frame.title.t = string.sub(t, 9, -1)
	frame.title:SetText(frame.title.t ~= '' and frame.title.t ~= nil and frame.title.t or 'Bag')
	if frame.slotFrame then
		SlotFrameSetup(frame)
		frame.toggleButton = CreateFrame('Button', t .. 'ToggleButton', frame)
		frame.toggleButton:SetHeight(12)
		frame.toggleButton:SetWidth(12)
		frame.toggleButton:SetPoint('TOPLEFT', 10, -6)
		frame.toggleButton:SetNormalTexture('Interface\\QuestFrame\\UI-Quest-BulletPoint')
		frame.toggleButton:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
		frame.toggleButton:SetPushedTexture('Interface\\QuestFrame\\UI-Quest-BulletPoint')
		frame.toggleButton:GetNormalTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
		frame.toggleButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		frame.toggleButton:SetScript('OnClick', function()
			local slotFrame = frame.slotFrame
			if arg1 == 'RightButton' then
				ToggleKeyRing()
			else
				PlaySound('igMainMenuOption')
				if slotFrame:IsVisible() then
					slotFrame:Hide()
				else
					slotFrame:Show()
				end
			end
		end)
		frame.toggleButton:SetScript('OnEnter', function()
			GameTooltip:SetOwner(this, 'ANCHOR_LEFT')
			GameTooltip:AddLine('Left Click: Open bags', 1, 1, 1)
			GameTooltip:AddLine('Right Click: Open keyring' , 0.3, 0.8, 1)
			GameTooltip:Show()
		end)
		frame.toggleButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
		if isSortingAddonLoaded() then
			frame.cuBag = CreateFrame('Button', t .. 'CU_button', frame)
			frame.cuBag:SetHeight(12)
			frame.cuBag:SetWidth(12)
			frame.cuBag:SetNormalTexture('Interface\\QuestFrame\\UI-Quest-BulletPoint')
			frame.cuBag:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
			frame.cuBag:SetPushedTexture('Interface\\QuestFrame\\UI-Quest-BulletPoint')
			frame.cuBag:GetNormalTexture():SetVertexColor(0.1, 1, 0.3)
			frame.cuBag:GetNormalTexture():SetTexCoord(0.25, 0.75, 0.25, 0.75)
			frame.cuBag:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
			frame.cuBag:SetScript('OnClick', function()
				local c = frame.title.t ~= '' and frame.title.t ~= nil and string.lower(frame.title.t) or 'bags'
				sortItems(c, arg1 == 'RightButton')
			end)
			frame.cuBag:SetScript('OnEnter', function()
				GameTooltip:SetOwner(this, 'ANCHOR_LEFT')
				GameTooltip:AddLine('Left Click: Sort', 1, 1, 1)
				GameTooltip:AddLine('Right Click: Reverse order' , 0.3, 0.8, 1)
				GameTooltip:Show()
			end)
			frame.cuBag:SetScript('OnLeave', function() GameTooltip:Hide() end)
		end
		frame.slotFrame:SetScript('OnHide', function() frame.toggleButton:GetNormalTexture():SetVertexColor(1, 1, 1) end)
		frame.slotFrame:SetScript('OnShow', function() frame.toggleButton:GetNormalTexture():SetVertexColor(1, 0, 0) end)
		TitleLayout(frame)
		frame.moneyFrame = CreateFrame('Frame', t .. 'MoneyFrame', frame, 'SmallMoneyFrameTemplate')
		frame.moneyFrame:SetPoint('RIGHT', frame.closeButton, 'LEFT', 12, 0)
	end
end

local function BankUpdateBagSlotStatus()
	local slots, full = GetNumBankSlots()
	for i=1, NUM_BANKBAGSLOTS, 1 do
		local button = getglobal('SUCC_bagBBag'..i)
		local tooltipText
		if button then
			if ( i <= slots ) then
				SetItemButtonTextureVertexColor(button, 1.0,1.0,1.0)
				button.tooltipText = BANK_BAG
				button:SetScript('OnClick', function()
					if not CursorHasItem() then
						if ( IsShiftKeyDown() ) then
							PickupBagFromSlot(this:GetInventorySlot())
							this:SetChecked(not this:GetChecked())	-- slot name issue
						else
							if not this:GetChecked() then
								HighlightBagSlots(this:GetID())
							else
								HighlightBagSlots(this:GetID(), 'highlight')
							end
							PlaySound('igMainMenuOptionFaerTab')
						end
					else
						this:SetChecked(not this:GetChecked())
						PutItemInBag(this:GetInventorySlot())
					end
				end)
			else
				SetItemButtonTextureVertexColor(button, 1.0,0.1,0.1)
				local cost = GetBankSlotCost(slots)
				SUCC_bag.bank.nextSlotCost = cost
				button.tooltipText = BANK_BAG_PURCHASE .. '|nCost: ' .. moneyToString(cost)
				button:SetScript('OnClick', function()
					this:SetChecked(not this:GetChecked())	-- slot name issue
					PlaySound('igMainMenuOption')
					StaticPopup_Show('CONFIRM_BUY_SUCCBANK_SLOT')
				end)
			end
		end
	end
end

local function PrepareBank(frame)
	if frame.bank then return frame.bank end
	frame.bank = CreateFrame('Frame', 'SUCC_bagBank', UIParent)
	-- frame.bank:SetPoint('TOPLEFT', 53, -116)
	frame.bank.bags = {-1, 5, 6, 7, 8, 9, 10}
	frame.bank.cols = SUCC_bagOptions.layout.columns.bank or 8
	frame.bank.slotFrame = CreateFrame('Frame', 'SUCC_bagBankSlotFrame', frame.bank)
	frame.bank.slotFrame.slot = {}
	for i = 1, NUM_BANKBAGSLOTS, 1 do
		frame.bank.slotFrame.slot[i] = CreateFrame('CheckButton', 'SUCC_bagBBag' .. i, frame.bank.slotFrame, 'BankItemButtonBagTemplate')
		frame.bank.slotFrame.slot[i]:SetID(i + 4)
		frame.bank.slotFrame.slot[i]:SetNormalTexture('Interface\\AddOns\\SUCC-bag\\Textures\\Slot')
		frame.bank.slotFrame.slot[i]:SetCheckedTexture('Interface\\Buttons\\CheckButtonHilight')
		frame.bank.slotFrame.slot[i]:SetScript('OnReceiveDrag', function()
			PutItemInBag(this:GetInventorySlot())
		end)
		frame.bank.slotFrame.slot[i]:SetScript('OnEnter', function()
			HighlightBagSlots(this:GetID(), 'highlight')
			GameTooltip:SetOwner(this, 'ANCHOR_RIGHT')
			if ( not GameTooltip:SetInventoryItem('player', this:GetInventorySlot()) ) then
					GameTooltip:SetText(this.tooltipText)
			end
			CursorUpdate()
		end)
		frame.bank.slotFrame.slot[i]:SetScript('OnLeave', function()
			if not this:GetChecked() then
				HighlightBagSlots(this:GetID())
			end
			GameTooltip:Hide()
			ResetCursor()
		end)
	end
	StaticPopupDialogs['CONFIRM_BUY_SUCCBANK_SLOT'] = {
		text = TEXT(CONFIRM_BUY_BANK_SLOT),
		button1 = TEXT(YES),
		button2 = TEXT(NO),
		OnAccept = function()
			PurchaseSlot()
		end,
		OnShow = function()
			MoneyFrame_Update(this:GetName()..'MoneyFrame', frame.bank.nextSlotCost)
		end,
		hasMoneyFrame = 1,
		timeout = 0,
		hideOnEscape = 1,
	}
	Essentials(frame.bank)
	frame.bank:SetScript('OnHide', function()
        for slot=1, SUCC_bag.bank.size do
            getglobal(SUCC_bag.bank:GetName().."Item"..slot):SetAlpha(1)
        end
		CloseBankFrame()
		PlaySound('igMainMenuClose')
	end)
	return frame.bank
end

local function OnEvent()
	if event == 'BAG_UPDATE' or event == 'BAG_UPDATE_COOLDOWN' then
		if dummyBag[arg1] then
			FrameUpdate(dummyBag[arg1]:GetParent(), arg1)
		end
	elseif event == 'BAG_CLOSED' then
		if dummyBag[arg1] then
			dummyBag.removed = arg1
			dummyBag[arg1].size = 0
			local parent = dummyBag[arg1]:GetParent()
			if parent:IsVisible() then
				FrameGenerate(parent)
			end
		end
	elseif event == 'ITEM_LOCK_CHANGED' then
		if this:IsVisible() then
			FrameUpdateLock(this)
		end
	elseif event == 'BANKFRAME_OPENED' then
		this:RegisterEvent('PLAYERBANKSLOTS_CHANGED')
		this:RegisterEvent('PLAYER_MONEY')
		SBFrameOpen(this, 1)
		SBFrameOpen(this.bank)
		PlaySound('igMainMenuOpen')
		BankUpdateBagSlotStatus()
	elseif event == 'BANKFRAME_CLOSED' then
		this:UnregisterEvent('PLAYERBANKSLOTS_CHANGED')
		this:UnregisterEvent('PLAYER_MONEY')
		SBFrameClose(this, 1)
		SBFrameClose(SUCC_bag.bank)
	elseif event == 'PLAYERBANKSLOTS_CHANGED' then
		FrameUpdate(SUCC_bag.bank, -1)
	elseif ( event == 'PLAYER_MONEY' or event == 'PLAYERBANKBAGSLOTS_CHANGED' ) then
		BankUpdateBagSlotStatus()
	elseif event == 'ADDON_LOADED' and arg1 == 'SUCC-bag' then
		SUCC_bagOptions = SUCC_bagOptions or SUCC_bagDefaults()
		this:UnregisterEvent('ADDON_LOADED')
		BankFrame:UnregisterEvent('BANKFRAME_OPENED')
		this:RegisterEvent('BAG_CLOSED')
		this:RegisterEvent('BAG_UPDATE')
		this:RegisterEvent('ITEM_LOCK_CHANGED')
		this:RegisterEvent('BAG_UPDATE_COOLDOWN')
		this:RegisterEvent('CURSOR_UPDATE')
		this:RegisterEvent('BANKFRAME_OPENED')
		this:RegisterEvent('BANKFRAME_CLOSED')
		-- this:RegisterEvent("PLAYER_ENTERING_WORLD")
		this.bags = {0, 1, 2, 3, 4}
		Essentials(this)
		Essentials(this.keyring)
		PrepareBank(this)
		ToggleBag = function() SBFrameToggle(SUCC_bag) end
		ToggleBackpack = ToggleBag
		OpenAllBags = ToggleBag
		OpenBag = function() SBFrameOpen(SUCC_bag) end
		OpenBackpack = OpenBag
		CloseBag = function() SBFrameClose(SUCC_bag) end
		CloseBackpack = CloseBag
		CloseAllBags = function() SBFrameClose(SUCC_bag) end
		ToggleKeyRing = function() SBFrameToggle(SUCC_bag.keyring) end
		SUCC_search()
		-- configuration
		SLASH_SUCC_BAG1 = '/succbag'
		print('|cFFF6A3EFSUCC-bag loaded. /succbag - configuration')
	-- elseif event == 'PLAYER_ENTERING_WORLD' then
	-- 	SBFrameClose(SUCC_bag.bank)
	end
end

SUCC_bag = CreateFrame('Frame', 'SUCC_bag', UIParent)
-- SUCC_bag:SetPoint('BOTTOMRIGHT', UIParent, -55, 55)
SUCC_bag:RegisterEvent('ADDON_LOADED')
SUCC_bag:SetScript('OnEvent', OnEvent)
SUCC_bag:SetScript('OnShow', function()
	PlaySound('igInventoryOepn')
end)
SUCC_bag:SetScript('OnHide', function()
    for slot=1, (SUCC_bag.size or 0) do
        getglobal(SUCC_bag:GetName().."Item"..slot):SetAlpha(1)
    end
	PlaySound('igInventoryClose')
end)
SUCC_bag.slotFrame = CreateFrame('Frame', 'SUCC_bagSlotFrame', SUCC_bag)
SUCC_bag.slotFrame.slot = {}
for i = 1, NUM_BAG_SLOTS, 1 do
	SUCC_bag.slotFrame.slot[i] = CreateFrame('CheckButton', 'SUCC_bagIBag' .. i - 1 ..'Slot', SUCC_bag.slotFrame, 'BagSlotButtonTemplate')
	SUCC_bag.slotFrame.slot[i]:SetNormalTexture('Interface\\AddOns\\SUCC-bag\\Textures\\Slot')
	SUCC_bag.slotFrame.slot[i]:SetScript('OnClick', function()
		local bagID = this:GetID()
		if not CursorHasItem() then
			if ( IsShiftKeyDown() ) then
				BagSlotButton_OnDrag()
			else
				PlaySound('igMainMenuOptionFaerTab')
				if not this:GetChecked() then
					HighlightBagSlots(bagID - 19)
				else
					HighlightBagSlots(bagID - 19, 'highlight')
				end
			end
		else
			this:SetChecked(not this:GetChecked())
			PutItemInBag(bagID)
		end
	end)
	SUCC_bag.slotFrame.slot[i]:SetScript('OnEnter', function()
		HighlightBagSlots(this:GetID() - 19, 'highlight')
		BagSlotButton_OnEnter()
	end)
	SUCC_bag.slotFrame.slot[i]:SetScript('OnLeave', function()
		if not this:GetChecked() then
			HighlightBagSlots(this:GetID() - 19)
		end
		GameTooltip:Hide()
		ResetCursor()
	end)
	SUCC_bag.slotFrame.slot[i]:SetScript('OnReceiveDrag', function()
		PutItemInBag(this:GetID())
	end)
end

SUCC_bag.keyring = CreateFrame('Frame', 'SUCC_bagKeyring', UIParent)
-- SUCC_bag.keyring:SetPoint('BOTTOMRIGHT', UIParent, -55, 55)
SUCC_bag.keyring.bags = {-2}
SUCC_bag.keyring:SetScript('OnShow', function()
	if SUCC_bag:IsVisible() then
		this:ClearAllPoints()
		this:SetPoint('BOTTOMLEFT', SUCC_bag, 'TOPLEFT', 0, 0)
	end
	PlaySound('KeyRingOpen')
end)
SUCC_bag.keyring:SetScript('OnHide', function()
    for slot=1, (SUCC_bag.keyring.size or 0)do
        getglobal(SUCC_bag.keyring:GetName().."Item"..slot):SetAlpha(1)
    end
	PlaySound('KeyRingClose')
end)

-- overrides
function SBFrameOpen(frame, automatic)
	FrameGenerate(frame)
	if frame and not automatic then
		frame.manOpened = 1
	end
end

function SBFrameClose(frame, automatic)
	if not(automatic and frame.manOpened) then
		frame:Hide()
		frame.manOpened = nil
	end
end

function SBFrameToggle(frame)
	if frame:IsVisible() then
		SBFrameClose(frame)
	else
		SBFrameOpen(frame)
	end
end


-- configuration

local menu

local function SlidersState(frame, disable)
	local frameName = frame:GetName()
	local thumb = getglobal(frameName .. 'Thumb')
	local string = getglobal(frameName .. 'Text')
	local low = getglobal(frameName .. 'Low')
	local high = getglobal(frameName .. 'High')
	if disable == 1 then
		thumb:Hide()
		string:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		low:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		high:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		frame:EnableMouse(false)
	else
		thumb:Show()
		string:SetVertexColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b)
		low:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		high:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		frame:EnableMouse()
	end
end

local function SetColumns()
	local l, n = this:GetValue(), string.sub(this:GetName(), 5, -8)
	SUCC_bagOptions.layout.columns[n] = l
	if n == 'bag' then FrameLayout(SUCC_bag, l) else FrameLayout(SUCC_bag.bank, l) end
end

local function SetColor()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	ColorPickerFrame.frame.swatch:SetVertexColor(r, g, b)
	ColorPickerFrame.frame.func(r, g, b)
end

local function ResetColor(reset)
	local r, g, b = unpack(reset)
	ColorPickerFrame.frame.swatch:SetVertexColor(r, g, b)
	ColorPickerFrame.frame.func(r, g, b)
end

local function ColorPicker(frame, reset)
	ColorPickerFrame:ClearAllPoints()
	ColorPickerFrame:SetPoint('LEFT', menu, 'RIGHT')
	ColorPickerFrame:SetToplevel()
	ColorPickerFrame.frame = frame
	ColorPickerFrame.func = SetColor
	ColorPickerFrame.cancelFunc = ResetColor
	ColorPickerFrame:SetColorRGB(unpack(reset))
	ColorPickerFrame.previousValues = reset
	ShowUIPanel(ColorPickerFrame)
end

local function CreateMenuFrame()
	local function color(n, l, c, r, a)
		local k = CreateFrame('Button', n, menu)
		k:SetWidth(90)
		k:SetHeight(16)
		if r then k:SetPoint(a and 'TOP' or 'LEFT', r, a and 'BOTTOM' or 'RIGHT', a and 0 or 20, 0) end
		k.t = k:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		k.t:SetPoint('Left', k)
		k.t:SetText(l .. ':')
		k.swatch = k:CreateTexture(k:GetName() .. 'SwatchBg', 'BACKGROUND')
		k.swatch:SetTexture('Interface\\ChatFrame\\ChatFrameColorSwatch')
		k.swatch:SetPoint('RIGHT', k)
		k.swatch:SetWidth(16)
		k.swatch:SetHeight(16)
		k.swatch:SetVertexColor(unpack(c))
		k:SetScript('OnClick', function() ColorPicker(this, c) end)
		return k
	end

	local function slider(n, l, s, v, r, a)
		local k = CreateFrame('Slider', n, menu, 'OptionsSliderTemplate')
		k:SetWidth(90)
		k:SetHeight(20)
		if r then k:SetPoint(a and 'TOP' or 'LEFT', r, a and 'BOTTOM' or 'RIGHT', a and 0 or 20, a and -25 or 0) end
		k:SetMinMaxValues(unpack(s))
		k:SetValue(v[1])
		k:SetValueStep(v[2])
		getglobal(n .. 'Text'):SetText(l[1])
		getglobal(n .. 'Low'):SetText(l[2])
		getglobal(n .. 'High'):SetText(l[3])
		return k
	end

	menu = CreateFrame('Frame', 'SUCC_bagMenu', UIParent)
	menu:SetWidth(270) menu:SetHeight(300)
	menu:SetPoint('CENTER', UIParent)
	menu:SetBackdrop(
		{
			bgFile   = 'Interface\\Tooltips\\UI-Tooltip-Background',
			edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
			insets   = {left = 11, right = 12, top = 12, bottom = 11},
		}
	)
	menu:SetBackdropColor(0, 0, 0, .7)
	menu:SetToplevel()
	menu:SetMovable()
	menu:SetUserPlaced(false)
	menu:RegisterForDrag('LeftButton')
	menu:EnableMouse()
	menu:SetScript('OnDragStart', function() menu:StartMoving() end)
	menu:SetScript('OnDragStop', function() menu:StopMovingOrSizing() end)
	menu:Hide()
	tinsert(UISpecialFrames, 'SUCC_bagMenu')

	menu.header = menu:CreateTexture(nil, 'ARTWORK')
	menu.header:SetWidth(256) menu.header:SetHeight(64)
	menu.header:SetPoint('TOP', menu, 0, 12)
	menu.header:SetTexture('Interface\\DialogFrame\\UI-DialogBox-Header')
	menu.header.t = menu:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	menu.header.t:SetPoint('TOP', menu.header, 0, -14)
	menu.header.t:SetText('SUCC-bag options')

	menu.bag = {}
	menu.bank = {}

	menu.bag.columns = slider('SBC_bagColumns', {'Bag Columns', '4', '32'}, {4, 32}, {SUCC_bagOptions.layout.columns.bag, 1})
	menu.bag.columns:SetPoint('TOPLEFT', menu, 35, -45)
	menu.bag.columns:SetScript('OnValueChanged', SetColumns)

	menu.bank.columns = slider('SBC_bankColumns', {'Bank Columns', '4', '32'}, {4, 32}, {SUCC_bagOptions.layout.columns.bank, 1}, menu.bag.columns)
	menu.bank.columns:SetScript('OnValueChanged', SetColumns)

	menu.spacing = slider('SBC_itemSpacing', {'Item spacing', '0', '20'}, {0, 20}, {SUCC_bagOptions.layout.spacing, 1}, menu.bag.columns, 1)
	menu.spacing:SetScript('OnValueChanged', function()
		local l, n = this:GetValue(), string.sub(this:GetName(), 1, -8)
		SUCC_bagOptions.layout.spacing = l
		if SUCC_bag:IsVisible() then FrameLayout(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameLayout(SUCC_bag.bank) end
		if SUCC_bag.keyring:IsVisible() then FrameLayout(SUCC_bag.keyring) end
	end)

	menu.border = color('SBC_borderColor', 'Border', SUCC_bagOptions.colors.border)
	menu.border:SetPoint('TOP', menu.spacing, 'BOTTOM', 0, -25)
	menu.border.func = function(r, g, b)
		SUCC_bagOptions.colors.border = {r, g, b}
		SUCC_bag:SetBackdropBorderColor(r, g, b)
		SUCC_bag.bank:SetBackdropBorderColor(r, g, b)
		SUCC_bag.keyring:SetBackdropBorderColor(r, g, b)
		SUCC_bag.slotFrame:SetBackdropBorderColor(r, g, b)
		SUCC_bag.bank.slotFrame:SetBackdropBorderColor(r, g, b)
	end

	menu.backdrop  = color('SBC_backdropColor', 'Backdrop', SUCC_bagOptions.colors.backdrop, menu.border)
	menu.backdrop.func = function(r, g, b)
		SUCC_bagOptions.colors.backdrop = {r, g, b}
		SUCC_bag:SetBackdropColor(r, g, b)
		SUCC_bag.bank:SetBackdropColor(r, g, b)
		SUCC_bag.keyring:SetBackdropColor(r, g, b)
		SUCC_bag.slotFrame:SetBackdropColor(r, g, b)
		SUCC_bag.bank.slotFrame:SetBackdropColor(r, g, b)
	end

	menu.item = color('SBC_itemColor', 'Item border', SUCC_bagOptions.colors.bag.Bag, menu.border, 1)
	menu.item.func = function(r, g, b)
		SUCC_bagOptions.colors.bag.Bag = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
		if SUCC_bag.keyring:IsVisible() then FrameUpdate(SUCC_bag.keyring) end
	end

	menu.quest = color('SBC_questColor', 'Quest item', SUCC_bagOptions.colors.quest, menu.item)
	menu.quest.func = function(r, g, b)
		SUCC_bagOptions.colors.quest = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.highlight = color('SBC_highlightColor', 'Highlight', SUCC_bagOptions.colors.highlight, menu.item, 1)
	menu.highlight.func = function(r, g, b)
		SUCC_bagOptions.colors.highlight = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.bg = color('SBC_BGColor', 'BG marks', SUCC_bagOptions.colors.BG, menu.highlight)
	menu.bg.func = function(r, g, b)
		SUCC_bagOptions.colors.BG = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.soul = color('SBC_soulColor', 'Soul bag', SUCC_bagOptions.colors.bag['Soul Bag'], menu.highlight, 1)
	menu.soul.func = function(r, g, b)
		SUCC_bagOptions.colors.bag['Soul Bag'] = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.herb = color('SBC_herbColor', 'Herb bag', SUCC_bagOptions.colors.bag['Herb Bag'], menu.soul)
	menu.herb.func = function(r, g, b)
		SUCC_bagOptions.colors.bag['Herb Bag'] = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.enchanting = color('SBC_enchantingColor', 'Enchanting', SUCC_bagOptions.colors.bag['Enchanting Bag'], menu.soul, 1)
	menu.enchanting.func = function(r, g, b)
		SUCC_bagOptions.colors.bag['Enchanting Bag'] = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.ammo = color('SBC_ammoColor', 'Ammo bag', SUCC_bagOptions.colors.ammo, menu.enchanting)
	menu.ammo.func = function(r, g, b)
		SUCC_bagOptions.colors.ammo = {r, g, b}
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end

	menu.override = CreateFrame('CheckButton', 'SBC_ColorBagOverride', menu, 'UICheckButtonTemplate')
	menu.override:SetHeight(25)
	menu.override:SetWidth(25)
	menu.override:SetPoint('TOPRIGHT', menu.ammo, 'BOTTOMRIGHT', 4, -10)
	menu.override:SetChecked(SUCC_bagOptions.colors.override)
	menu.override:SetScript('OnClick', function()
		if this:GetChecked() == 1 then
			SUCC_bagOptions.colors.override = true
		else
			SUCC_bagOptions.colors.override = false
		end
		if SUCC_bag:IsVisible() then FrameUpdate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameUpdate(SUCC_bag.bank) end
	end)
	menu.override.t = menu.override:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	menu.override.t:SetPoint('RIGHT', menu.override, 'LEFT', 10, 0)
	menu.override.t:SetWidth(200)
	menu.override.t:SetText('Quality color above bag color:')

	if isSortingAddonLoaded() then
		menu.cleanup = CreateFrame('CheckButton', 'SBC_cleanUp', menu, 'UICheckButtonTemplate')
		menu.cleanup:SetHeight(25)
		menu.cleanup:SetWidth(25)
		menu.cleanup:SetPoint('TOPRIGHT', menu.bank.columns, 'BOTTOMRIGHT', 4, -21)
		menu.cleanup:SetChecked(SUCC_bagOptions.Clean_Up)
		menu.cleanup:SetScript('OnClick', function()
			if this:GetChecked() == 1 then
				SUCC_bagOptions.Clean_Up = 1
			else
				SUCC_bagOptions.Clean_Up = nil
			end
			TitleLayout(SUCC_bag)
			TitleLayout(SUCC_bag.bank)
		end)
		menu.cleanup.t = menu.cleanup:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
		menu.cleanup.t:SetPoint('RIGHT', menu.cleanup, 'LEFT', 10, 0)
		menu.cleanup.t:SetWidth(90)
		menu.cleanup.t:SetText('Clean_Up:')
	end

	menu.reset = CreateFrame('Button', nil, menu, 'UIPanelButtonTemplate')
	menu.reset:SetWidth(100) menu.reset:SetHeight(25)
	menu.reset:SetText('Reset')
	menu.reset:SetPoint('BOTTOMLEFT', menu, 25, 20)
	menu.reset:SetScript('OnClick', function()
		SUCC_bagOptions = SUCC_bagDefaults()
		menu.border.func(unpack(SUCC_bagOptions.colors.border))
		menu.backdrop.func(unpack(SUCC_bagOptions.colors.backdrop))
		menu.bag.columns:SetValue(SUCC_bagOptions.layout.columns.bag)
		menu.bank.columns:SetValue(SUCC_bagOptions.layout.columns.bank)
		menu.spacing:SetValue(SUCC_bagOptions.layout.spacing)
		if SUCC_bag:IsVisible() then FrameGenerate(SUCC_bag) end
		if SUCC_bag.bank:IsVisible() then FrameGenerate(SUCC_bag.bank) end
		if SUCC_bag.keyring:IsVisible() then FrameGenerate(SUCC_bag.keyring) end
	end)

	menu.close = CreateFrame('Button', nil, menu, 'UIPanelButtonTemplate')
	menu.close:SetWidth(100) menu.close:SetHeight(25)
	menu.close:SetText('Close')
	menu.close:SetPoint('BOTTOMRIGHT', menu, -25, 20)
	menu.close:SetScript('OnClick', function() menu:Hide() end)
end

SlashCmdList['SUCC_BAG'] = function()
	if not menu then CreateMenuFrame() end
	if menu:IsShown() then menu:Hide() else menu:Show() end
end
