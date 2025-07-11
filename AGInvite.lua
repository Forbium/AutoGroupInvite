function GetFriendsList()
    index = 1
    while GetFriendInfo(index) do
        
        DEFAULT_CHAT_FRAME:AddMessage(GetFriendInfo(index), 1.0, 1.0, 0.0)
        index = index + 1
    end
end

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

FriendAutoGroup = {}
FriendCheckBox = {}
for i = 1, GetNumFriends() do
    -- Создаём галочку https://github.com/tekkub/wow-ui-source/blob/live/FrameXML/FriendsFrame.lua
    --checkbox[i] = CreateFrame("CheckButton", "MyCheckbox"..i, getglobal("FriendsFrameFriendButton"..i), "UICheckButtonTemplate")
    FriendCheckBox[i] = CreateFrame("CheckButton", "MyCheckbox"..i, getglobal("FriendsFrameFriendButton"..i), "UICheckButtonTemplate")

    -- Устанавливаем позицию относительно элемента
    FriendCheckBox[i]:SetPoint("LEFT", getglobal("FriendsFrameFriendButton"..i), "LEFT", -20, 0)

    -- Меняем размер (по умолчанию большая)
    FriendCheckBox[i]:SetWidth(20)
    FriendCheckBox[i]:SetHeight(20)

    -- Устанавливаем состояние (отмечена или нет)
    FriendCheckBox[i]:SetChecked(false)
    FriendCheckBox[i].i = i

    local checkbox = FriendCheckBox[i]

    checkbox:SetScript("OnClick", function()
        local index = checkbox.i
        --local name, level, class, area, connected, status = GetFriendInfo(index)
        if checkbox:GetChecked() then
            DEFAULT_CHAT_FRAME:AddMessage("Галочка установлена на "..index.."!")
            local name = GetFriendInfo(index)
            FriendAutoGroup[index] = name
            --DEFAULT_CHAT_FRAME:AddMessage(FriendAutoGroup[index])
        else
            DEFAULT_CHAT_FRAME:AddMessage("Галочка снята на "..index.."!")
            FriendAutoGroup[index] = nil
        end
    end)
end


function AGInvite_OnLoad()
    this:RegisterEvent("PLAYER_ENTERING_WORLD")
    this:RegisterEvent("FRIENDLIST_UPDATE")
    this:RegisterEvent("PARTY_INVITE_REQUEST")
    DEFAULT_CHAT_FRAME:AddMessage("AGInvite is loaded", 1.0, 1.0, 0.0)
end

local onlineFriends = {}

function AGInvite_OnEvent(event)
    if event == "PLAYER_ENTERING_WORLD" then
        local index = 1
        for k in pairs(onlineFriends) do
            onlineFriends[k] = nil
        end
        for index = 1, GetNumFriends() do
            local name, level, class, area, connected, status = GetFriendInfo(index)
            if connected then
                onlineFriends[name] = true
                if status ~= "PARTY" and IsPartyLeader() then
                    if name then
                        InviteByName(name)
                        DEFAULT_CHAT_FRAME:AddMessage("Invited "..name)
                    else
                        DEFAULT_CHAT_FRAME:AddMessage("Ошибка: имя друга nil на индексе "..index)
                    end
                end
            end
        end


    elseif event == "FRIENDLIST_UPDATE" then
        for i = 1, GetNumFriends() do
            local name, level, class, area, connected, status = GetFriendInfo(i)
            if name and connected and not onlineFriends[name] and status ~= "PARTY" and (IsPartyLeader() or (GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0)) then
                --DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Ваш друг зашел в игру:|r "..name)
                --InviteUnit(name)
                InviteByName(name)
                onlineFriends[name] = true
            elseif not connected and onlineFriends[name] then
                onlineFriends[name] = nil
            end
        end

    elseif event == "PARTY_INVITE_REQUEST" then
        -- https://stackoverflow.com/questions/61544551/is-there-a-way-to-get-the-last-chat-massage-in-shout-or-say

        local inviter = arg1
        DEFAULT_CHAT_FRAME:AddMessage("inviter is " .. inviter)

        if UnitIsInFriendList(inviter) then
            AcceptGroup()
            DEFAULT_CHAT_FRAME:AddMessage("Accepted invite from: " .. inviter)
            StaticPopup_Hide("PARTY_INVITE")
        else
            --DEFAULT_CHAT_FRAME:AddMessage(inviter.." is not your Friend")
        end
    end
end

function UnitIsInFriendList(unit)
    --local index = 1
    --while FriendAutoGroup[index] do
    for index = 1, GetNumFriends() do
        if FriendAutoGroup[index] ~= nil then
            --DEFAULT_CHAT_FRAME:AddMessage(index .. " = " .. FriendAutoGroup[index])
            if unit == FriendAutoGroup[index] then
                --DEFAULT_CHAT_FRAME:AddMessage(unit .." проверку прошел ")
                return true
            end
        end
    end
    return false
end