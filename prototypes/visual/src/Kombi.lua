-- Display geometry only. Import the credited source into ServerStorage in Edit mode.
-- No third-party scripts, chassis, joints, audio, UI or remotes are copied.
local Kombi = {}
local red=Color3.fromRGB(185,18,32)
local white=Color3.fromRGB(245,243,235)
local imageId="rbxassetid://380913763"

local function detail(parent,cf,name,size,offset,color)
    local p=Instance.new("Part")
    p.Name,p.Size,p.CFrame=name,size,cf*offset
    p.Color,p.Material=color,Enum.Material.SmoothPlastic
    p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,false,false,false
    p.TopSurface,p.BottomSurface=Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

function Kombi.build(parent,frame)
    local source=game.ServerStorage:FindFirstChild("KombiReviewSource")
    assert(source and source:IsA("Model"),"Import the credited Kombi source into ServerStorage.KombiReviewSource in Studio Edit mode; see visual README")
    local model=Instance.new("Model")
    model.Name="RedDeliveryVan"
    for _,object in ipairs(source:GetDescendants()) do
        if object:IsA("BasePart") and not object:IsA("Seat") and not object:IsA("VehicleSeat") and object.Transparency<1 then
            local copy=object:Clone()
            for _,child in ipairs(copy:GetChildren()) do
                if not child:IsA("DataModelMesh") then child:Destroy() end
            end
            -- Mesh children are data, but never retain descendants from an import.
            for _,child in ipairs(copy:GetDescendants()) do
                if child.Parent~=copy then child:Destroy() end
            end
            copy.Anchored,copy.CanCollide,copy.CanTouch,copy.CanQuery=true,false,false,false
            copy.Parent=model
        end
    end
    model.WorldPivot=select(1,source:GetBoundingBox())
    model:ScaleTo(.82)
    local cf=model:GetPivot()
    local wheels={}
    for _,object in ipairs(model:GetChildren()) do
        local position=cf:PointToObjectSpace(object.Position)
        local bluePaint=object.Color.B>.45 and object.Color.R<.3
        local lightBody=object.Transparency==0 and object.Color.R>.85 and position.Y>-1.3 and object.Size.Magnitude>1
        if bluePaint or lightBody then
            object.Color,object.Reflectance=red,.03
            if object:IsA("UnionOperation") then object.UsePartColor=true end
        end
        if object.Name=="FR" or object.Name=="FL" or object.Name=="RR" or object.Name=="RL" then
            wheels[#wheels+1]=position
        end
    end
    assert(#wheels==4,"The reviewed source must have four named wheel assemblies")
    for _,wheel in ipairs(wheels) do
        local side=wheel.Z<0 and -1 or 1
        local rim=detail(model,cf,"ChromeHubcap",Vector3.new(.13,1.23,1.23),CFrame.new(wheel.X,wheel.Y,side*2.77)*CFrame.Angles(0,math.pi/2,0),Color3.fromRGB(205,210,215))
        rim.Shape,rim.Material,rim.Reflectance=Enum.PartType.Cylinder,Enum.Material.Metal,.25
    end
    for _,side in ipairs({-1,1}) do
        local panel=detail(model,cf,"RedBrandedCargoSide",Vector3.new(8.6,3.4,.025),CFrame.new(1,.75,side*2.79),red)
        local gui=Instance.new("SurfaceGui")
        gui.Name="ColonelBranding"
        gui.Face=side<0 and Enum.NormalId.Front or Enum.NormalId.Back
        gui.SizingMode,gui.CanvasSize=Enum.SurfaceGuiSizingMode.FixedSize,Vector2.new(860,340)
        gui.LightInfluence,gui.Parent=1,panel
        local portrait=Instance.new("ImageLabel")
        portrait.Name,portrait.Image="ColonelSanders",imageId
        portrait.BackgroundTransparency=1
        portrait.Position,portrait.Size=UDim2.fromScale(.015,.03),UDim2.fromScale(.47,.94)
        portrait.ScaleType,portrait.Parent=Enum.ScaleType.Fit,gui
        local wordmark=Instance.new("TextLabel")
        wordmark.Name,wordmark.Text="KFC","KFC"
        wordmark.BackgroundTransparency=1
        wordmark.Position,wordmark.Size=UDim2.fromScale(.47,.18),UDim2.fromScale(.5,.5)
        wordmark.TextScaled,wordmark.Font,wordmark.TextColor3=true,Enum.Font.GothamBlack,white
        wordmark.Parent=gui
        local slogan=wordmark:Clone()
        slogan.Name,slogan.Text="Slogan","FINGER LICKIN' GOOD"
        slogan.Position,slogan.Size=UDim2.fromScale(.48,.72),UDim2.fromScale(.48,.15)
        slogan.Parent=gui
    end
    model:SetAttribute("SourceAssetId","3925293648")
    model:SetAttribute("ColonelImageId","380913763")
    model:SetAttribute("Purpose","Static art review only; uses no imported chassis or scripts")
    model:PivotTo(frame*CFrame.new(0,3.1,0)*CFrame.Angles(0,-math.pi/2,0))
    model.Parent=parent
    return model
end

return Kombi
