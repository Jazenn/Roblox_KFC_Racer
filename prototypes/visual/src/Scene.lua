-- Throwaway in-engine art sample. Original procedural geometry; no asset downloads.
local Scene = {}
local red = Color3.fromRGB(185, 18, 32)
local white = Color3.fromRGB(244, 239, 225)
local black = Color3.fromRGB(23, 26, 30)
local steel = Color3.fromRGB(118, 127, 133)
local function group(parent, name)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent
    return model
end
local function part(parent, name, size, frame, color, material)
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame = name, size, frame
    p.Color, p.Material = color, material or Enum.Material.SmoothPlastic
    p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end
local function cylinder(parent, name, size, frame, color, material)
    local p = part(parent, name, size, frame, color, material)
    p.Shape = Enum.PartType.Cylinder
    return p
end
local function lettering(p, face, title, subtitle)
    local gui = Instance.new("SurfaceGui")
    gui.Name, gui.Face = "Livery", face
    gui.SizingMode, gui.PixelsPerStud = Enum.SurfaceGuiSizingMode.PixelsPerStud, 90
    gui.LightInfluence = 1
    gui.Parent = p
    local label = Instance.new("TextLabel")
    label.Size, label.Position = UDim2.fromScale(.9, .55), UDim2.fromScale(.05, .1)
    label.BackgroundTransparency, label.TextColor3 = 1, white
    label.Font, label.TextScaled, label.Text = Enum.Font.GothamBlack, true, title
    label.Parent = gui
    local small = label:Clone()
    small.Size, small.Position = UDim2.fromScale(.9, .18), UDim2.fromScale(.05, .68)
    small.Font, small.Text = Enum.Font.GothamBold, subtitle
    small.Parent = gui
    if subtitle == "ROBLOX FRIED CHICKEN" then
        label.Position, label.Size = UDim2.fromScale(.25,.12), UDim2.fromScale(.7,.5)
        small.Position, small.Size = UDim2.fromScale(.23,.68), UDim2.fromScale(.74,.16)
        -- Original chicken silhouette, drawn from UI shapes rather than a logo asset.
        for _,shape in ipairs({{.05,.4,.13,.26},{.11,.26,.08,.18},{.1,.19,.035,.09},{.135,.18,.035,.09}}) do
            local mark=Instance.new("Frame")
            mark.Position=UDim2.fromScale(shape[1],shape[2])
            mark.Size=UDim2.fromScale(shape[3],shape[4])
            mark.BackgroundColor3,mark.BorderSizePixel=white,0
            local round=Instance.new("UICorner")
            round.CornerRadius=UDim.new(1,0)
            round.Parent=mark
            mark.Parent=gui
        end
    end
    return gui
end

function Scene.van(parent, frame)
    return require(script.Parent:WaitForChild("VisualDirectionReferenceVan")).build(parent, frame)
end

function Scene.circuit(parent, frame)
    local circuit=group(parent,"CircuitSample")
    local function p(name,size,offset,color,material)
        return part(circuit,name,size,frame*CFrame.new(offset),color,material)
    end
    local grass=p("Grass",Vector3.new(250,1,290),Vector3.new(20,-.55,-15),Color3.fromRGB(79,102,59),Enum.Material.Grass)
    grass.CanCollide,grass.CanQuery=true,true
    local road=p("Asphalt",Vector3.new(38,.18,180),Vector3.new(0,.04,10),Color3.fromRGB(48,51,55),Enum.Material.Asphalt)
    road.CanCollide,road.CanQuery=true,true
    p("GravelRunoff",Vector3.new(27,.15,75),Vector3.new(-35,.03,-40),Color3.fromRGB(163,153,132),Enum.Material.Pebble)
    p("ConcreteApron",Vector3.new(19,.15,100),Vector3.new(33,.03,24),Color3.fromRGB(150,148,139),Enum.Material.Concrete)
    for _,side in ipairs({-1,1}) do
        p("WhiteEdge",Vector3.new(.22,.02,180),Vector3.new(side*18.3,.145,10),white)
        for i=1,36 do
            p("Kerb",Vector3.new(2.5,.22,5),Vector3.new(side*20,.16,102.5-i*5),i%2==0 and red or white,Enum.Material.Concrete)
        end
    end
    for i=0,35 do
        local angle=math.pi+i*math.pi/70
        local at=frame*CFrame.new(45+math.cos(angle)*45,.04+i*.001,-80+math.sin(angle)*45)*CFrame.Angles(0,-angle,0)
        local segment=part(circuit,"BendAsphalt",Vector3.new(38,.18,3.1),at,road.Color,Enum.Material.Asphalt)
        segment.CanCollide,segment.CanQuery=true,true
        for _,r in ipairs({25,65}) do
            part(circuit,"BendKerb",Vector3.new(2.5,.22,3),frame*CFrame.new(45+math.cos(angle)*r,.16+i*.001,-80+math.sin(angle)*r)*CFrame.Angles(0,-angle,0),i%2==0 and red or white,Enum.Material.Concrete)
        end
        if i%8==0 then task.wait() end
    end
    for i=1,14 do
        for layer=1,3 do
            cylinder(circuit,"TireBarrier",Vector3.new(.7,2.5,2.5),frame*CFrame.new(-52,.35+(layer-1)*.7,-82+i*2.5)*CFrame.Angles(0,0,math.pi/2),black,Enum.Material.Rubber)
        end
    end
    for i=1,12 do
        p("GuardrailPost",Vector3.new(.18,2.8,.18),Vector3.new(27,1.4,-75+i*12),steel,Enum.Material.Metal)
        p("FencePost",Vector3.new(.12,7,.12),Vector3.new(29,3.5,-75+i*12),steel,Enum.Material.Metal)
    end
    for y=1,11 do
        p("FenceWire",Vector3.new(.025,.025,144),Vector3.new(29,y*.6,-3),steel,Enum.Material.Metal)
    end
    for i=1,144 do
        p("FenceWire",Vector3.new(.025,6.6,.025),Vector3.new(29,3.6,-75+i),steel,Enum.Material.Metal)
        if i%30==0 then task.wait() end
    end
    for y=1,3 do p("Guardrail",Vector3.new(.12,.3,145),Vector3.new(27,y*.65,-3),steel,Enum.Material.Metal) end
    for row=1,5 do
        p("ConcreteRiser",Vector3.new(3,1+row*1.2,72),Vector3.new(39+row*3,(1+row*1.2)/2,12),Color3.fromRGB(137,139,136),Enum.Material.Concrete)
        for column=1,16 do
            p("Seat",Vector3.new(1.7,.18,2.2),Vector3.new(39+row*3,1.25+row*1.2,-24+column*4.3),column%2==0 and red or black)
            p("SeatBack",Vector3.new(.18,1.2,2.2),Vector3.new(39.8+row*3,1.8+row*1.2,-24+column*4.3),red)
        end
        task.wait()
    end
    for _,z in ipairs({-27,12,51}) do
        p("RoofColumn",Vector3.new(.4,15,.4),Vector3.new(58,7.5,z),steel,Enum.Material.Metal)
        p("RoofBeam",Vector3.new(24,.35,.35),Vector3.new(47,15,z),steel,Enum.Material.Metal)
    end
    p("GrandstandRoof",Vector3.new(27,.25,82),Vector3.new(47,15.4,12),Color3.fromRGB(203,205,200),Enum.Material.Metal)
    local banner=p("CircuitBanner",Vector3.new(.18,2.7,48),Vector3.new(35,12.8,12),red)
    lettering(banner,Enum.NormalId.Left,"RFC MOTOR CIRCUIT","FRESH CHICKEN / FULL THROTTLE")
    local crowd=group(circuit,"Spectators")
    local shirts={red,white,Color3.fromRGB(39,61,86),Color3.fromRGB(203,159,74)}
    for i=1,42 do
        local row=(i*3)%5+1
        local column=(i*7)%16+1
        local x,y,z=38.7+row*3,2.5+row*1.2,-24+column*4.3
        local person=group(crowd,"Spectator")
        local shirt=shirts[i%#shirts+1]
        part(person,"Torso",Vector3.new(.65,1.05,.9),frame*CFrame.new(x,y,z),shirt)
        local head=part(person,"Head",Vector3.new(.65,.7,.65),frame*CFrame.new(x,y+.85,z),Color3.fromRGB(166+i%4*20,120+i%4*18,92+i%4*17))
        head.Shape=Enum.PartType.Ball
        for _,side in ipairs({-1,1}) do
            part(person,"Arm",Vector3.new(.55,.65,.27),frame*CFrame.new(x-.3,y-.1,z+side*.63),shirt)
            part(person,"Leg",Vector3.new(1,.3,.33),frame*CFrame.new(x-.45,y-.73,z+side*.27),black)
        end
        if i%10==0 then task.wait() end
    end
    return circuit
end

function Scene.build()
    assert(not workspace:FindFirstChild("VisualDirectionPrototype"),"Remove the previous art sample explicitly before rebuilding")
    local root=group(workspace,"VisualDirectionPrototype")
    root:SetAttribute("Purpose","Throwaway art direction sample; not a race or chassis replacement")
    root:SetAttribute("AssetProvenance","Original Blender van from owner PNG; vector Colonel and original procedural circuit; see visual README")
    local origin=CFrame.new(800,3,0)
    Scene.circuit(root,origin)
    local vanFrame=origin*CFrame.new(-5,.18,28)*CFrame.Angles(0,math.rad(-15),0)
    Scene.van(root,vanFrame)
    root:SetAttribute("DriverFrame",vanFrame*CFrame.new(-1.25,3.6,-3.7))
    local lighting=game:GetService("Lighting")
    lighting.ClockTime,lighting.Brightness=14,2.5
    lighting.Ambient=Color3.fromRGB(90,98,111)
    lighting.OutdoorAmbient=Color3.fromRGB(125,132,139)
    lighting.EnvironmentDiffuseScale,lighting.EnvironmentSpecularScale=1,1
    lighting.GlobalShadows=true
    return root
end

return Scene
