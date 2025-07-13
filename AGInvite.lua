--/run local n,l,cl,a,c,s = GetFriendInfo(1) print(n.." "..l.." "..cl.." "..a.." "..c.." "..s)

--FriendsFrameAddFriendButton:Hide()
--FriendsFrame:SetWidth(FriendsFrame:GetWidth()+10)
-- /run FriendsFrame:SetHeight(FriendsFrame:GetHeight()+100)
--FriendsListFrameScrollFrame

--/run FriendsFrame:GetChildren()
--/run local f = FriendsFrame:GetChildren() print(f[1])
--/run HideUIPanel(FriendsFrame)
--/run ShowUIPanel(FriendsFrame)

--/run kids = { FriendsFrame:GetChildren() };for _,framechild in ipairs(kids) do print("-"..framechild:GetName() ); end

--/run FriendsFrameFriendButton1:SetPoint("TOP",0,-6)
--/run FriendsFrameFriendButton1:SetPoint("BOTTOM",0,400)

--/run local l = FriendsListFrame kids = { l:GetChildren() };for _,framechild in ipairs(kids) do print("-"..framechild:GetName() ); end

--/run local l = FriendsFrameFriendButton1 kids = { l:GetChildren() };for _,framechild in ipairs(kids) do print("-"..framechild:GetName() ); end
--print(FriendsFrameFriendsScrollFrame.scrollbar)

AI_FriendList = {}
AI_CheckBoxes = {}

--Remove Friends from SaveVariable that are not in friend list
function AGCleaning()
    if AI_FriendList ~= nil then
        for i=1, table.getn(AI_FriendList) do
            local InFriendList = false
            for j=1, GetNumFriends() do
                if AI_FriendList[i] == GetFriendInfo(j)then
                    InFriendList = true
                    break
                end
            end
            if InFriendList == false then
                table.remove(AI_FriendList, i)
            end
        end
    end
end

--Set value in checkboxes to all friend list
function SetCheckBoxesValue()
    for i=1, 10 do
        local offset = FriendsFrameFriendsScrollFrame.offset or 0
        local friendIndex = offset + i
        local name = GetFriendInfo(friendIndex)
        for j = 1, table.getn(AI_FriendList) do
            if AI_FriendList[j] == name then
                AI_CheckBoxes[i]:SetChecked(true)
                break
            else
                AI_CheckBoxes[i]:SetChecked(false)
            end
        end
    end
end

function MakeInviteButton()
    local AI_Button = CreateFrame("Button", "Invite", FriendsFrame, "UIPanelButtonTemplate")
    AI_Button:SetPoint("TOP", FriendsFrame, "TOP", 120, -40)
    AI_Button:SetWidth(60)
    AI_Button:SetHeight(24)
    AI_Button:SetText("Invite")
    AI_Button:SetScript("OnClick", AGSendToAllRequest)
end

function AGMakeCheckBoxes()
    MakeInviteButton()
    AI_CheckBoxes = {}
    for i = 1, 10 do
        AI_CheckBoxes[i] = CreateFrame("CheckButton", "MyCheckbox"..i, getglobal("FriendsFrameFriendButton"..i), "UICheckButtonTemplate")
        AI_CheckBoxes[i]:SetPoint("LEFT", getglobal("FriendsFrameFriendButton"..i), "LEFT", -20, 0)
        AI_CheckBoxes[i]:SetWidth(20)
        AI_CheckBoxes[i]:SetHeight(20)
        AI_CheckBoxes[i].index = i

        local AGcheckbox = AI_CheckBoxes[i]

        AGcheckbox:SetScript("OnClick", function()
            local index = AGcheckbox.index
            local offset = FriendsFrameFriendsScrollFrame.offset or 0
            local friendIndex = offset + index
            local name = GetFriendInfo(friendIndex)
            if AGcheckbox:GetChecked() then
                DEFAULT_CHAT_FRAME:AddMessage("Try to ADD ".. name, 1.0, 1.0, 0.0)
                table.insert(AI_FriendList, name)
            else
                DEFAULT_CHAT_FRAME:AddMessage("Try to REMOVE ".. name, 1.0, 1.0, 0.0)
                for j=1, table.getn(AI_FriendList) do
                    if name == AI_FriendList[j] then table.remove(AI_FriendList, j) end
                end
            end
        end)
    end
end

function AGSendToAllRequest() -- /run AGSendToAllRequest()
    if AI_FriendList ~= nil then
        for j = 1, table.getn(AI_FriendList) do
            InviteByName(AI_FriendList[j])
        end
    end
end

function UnitIsInFriendList(unit)
    for i = 1, GetNumFriends() do
        if AI_FriendList[i] ~= nil then
            if unit == AI_FriendList[i] then
                return true
            end
        end
    end
    return false
end

--[[
function MakeSettingsFrame()
    AGSettingsFrame:SetPoint("CENTER",0,0)
    AGSettingsFrame:SetWidth(160)
    AGSettingsFrame:SetHeight(200)
    AGSettingsFrame:Show()
end]]




local checkboxloadmaker = false
function AGInvite_OnEvent(event)
    if event == "PLAYER_ENTERING_WORLD" then
    elseif event == "FRIENDLIST_UPDATE" then
        AGCleaning()
        if checkboxloadmaker == true then
            checkboxloadmaker = false
            AGMakeCheckBoxes()
        end
        SetCheckBoxesValue()
    elseif event == "PARTY_INVITE_REQUEST" then
        if UnitIsInFriendList(arg1) then
            AcceptGroup()
            DEFAULT_CHAT_FRAME:AddMessage("Accepted invite from: " .. arg1)
            StaticPopup_Hide("PARTY_INVITE")
        end
    end
end

function AGInvite_OnLoad()
    this:RegisterEvent("PLAYER_ENTERING_WORLD")
    this:RegisterEvent("FRIENDLIST_UPDATE")
    this:RegisterEvent("PARTY_INVITE_REQUEST")
    DEFAULT_CHAT_FRAME:AddMessage("AGInvite_OnLoad...", 1.0, 1.0, 0.0)
    checkboxloadmaker = true
    local lastOffset = 0

    FriendsFrameFriendsScrollFrame:SetScript("OnUpdate", function()
        local offset = FriendsFrameFriendsScrollFrame.offset or 0
        if offset ~= lastOffset then
            lastOffset = offset
            --DEFAULT_CHAT_FRAME:AddMessage("Offset изменился: "..offset)
            SetCheckBoxesValue()
        end
    end)
end