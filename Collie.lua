local filter = ''
local filterTable = {}

local Search = CreateFrame('EditBox', 'MountSearch', MountJournal, 'SearchBoxTemplate')
Search:SetSize(145, 20)
Search:SetPoint('LEFT', MountJournal.MountCount, 'RIGHT', 15, 0)
Search:SetMaxLetters(40)
Search:SetScript('OnTextChanged', function(self)
	local text = self:GetText()
	if(text == SEARCH) then
		filter = ''
	else
		filter = text
	end

	MountJournal_UpdateMountList()
end)

function MountJournal_UpdateMountList()
	local scroll = MountJournal.ListScrollFrame
	local offset = HybridScrollFrame_GetOffset(scroll)
	local mounts = GetNumCompanions('MOUNT')

	if(UnitLevel('player') < 20 or mounts < 1) then
		scroll:Hide()
		MountJournal.MountDisplay.NoMounts:Show()
		MountJournal.selectedSpellID = 0
		MountJournal_UpdateMountDisplay()
		MountJournal.MountCount:SetText(0)
		MountJournal.MountButton:SetEnabled(false)
		return
	else
		scroll:Show()
		MountJournal.MountDisplay.NoMounts:Hide()
		MountJournal.MountButton:SetEnabled(true)
	end

	table.wipe(filterTable)

	for index = 1, mounts do
		local id, name, spell, icon, active = GetCompanionInfo('MOUNT', index)
		if(name:lower():find(filter)) then
			table.insert(filterTable, index)
		end
	end

	local buttons = scroll.buttons
	for j = 1, #buttons do
		local button = buttons[j]
		local index = j + offset
		if(index <= #filterTable) then
			local _, name, spell, icon, active = GetCompanionInfo('MOUNT', filterTable[index])
			button.name:SetText(name)
			button.icon:SetTexture(icon)
			button.index = filterTable[index]
			button.spellID = spell
			button.active = active

			if(active) then
				button.DragButton.ActiveTexture:Show()
			else
				button.DragButton.ActiveTexture:Hide()
			end

			button:Show()

			if(MountJournal.selectedSpellID == spell) then
				button.selected = true
				button.selectedTexture:Show()
			else
				button.selected = false
				button.selectedTexture:Hide()
			end

			button:SetEnabled(true)

			button.DragButton:SetEnabled(true)
			button.additionalText = nil
			button.icon:SetDesaturated(false)
			button.icon:SetAlpha(1)
			button.name:SetFontObject('GameFontNormal')

			if(button.showingTooltip) then
				MountJournalMountButton_UpdateTooltip(button)
			end
		else
			button:Hide()
		end
	end

	HybridScrollFrame_Update(scroll, #filterTable * 46, scroll:GetHeight())
	MountJournal.MountCount.Count:SetText(mounts)
end

MountJournal.ListScrollFrame.update = MountJournal_UpdateMountList
