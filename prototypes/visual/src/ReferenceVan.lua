-- Original Blender geometry and UV paint. Data is local; no model/network downloads.
local ReferenceVan={}
local textureIds={
    ["body_left.png"]="rbxassetid://124178059947244",
    ["body_right.png"]="rbxassetid://74080269615682",
    ["body_front.png"]="rbxassetid://74214412134340",
    ["body_roof.png"]="rbxassetid://110655122093649",
}
local function srgb(c)
    if c<=.0031308 then return c*12.92 end
    return 1.055*c^(1/2.4)-.055
end

function ReferenceVan.build(parent,frame)
    local chunks=script.Parent:WaitForChild("ReferenceVanMeshData"):GetChildren()
    table.sort(chunks,function(a,b) return a.Name<b.Name end)
    local strings={}
    for _,chunk in ipairs(chunks) do strings[#strings+1]=chunk.Value end
    local data=game:GetService("HttpService"):JSONDecode(table.concat(strings))
    assert(data.reference=="kfc_racer_van.png" and #data.groups==13,"Unexpected reference export")
    local model=Instance.new("Model")
    model.Name="RedDeliveryVan"
    model.WorldPivot=frame
    local meshes={}
    model.Destroying:Connect(function()
        for _,editable in ipairs(meshes) do editable:Destroy() end
    end)
    local triangleCount=0
    for _,group in ipairs(data.groups) do
        assert(#group.vertices<=60000 and #group.faces<=20000,"Mesh exceeds editor limits")
        assert(#group.vertices==#group.normals and #group.vertices==#group.uv,"Missing vertex attributes")
        local lo,hi=Vector3.new(math.huge,math.huge,math.huge),Vector3.new(-math.huge,-math.huge,-math.huge)
        for _,v in ipairs(group.vertices) do
            local p=Vector3.new(v[1],v[2],v[3])
            lo=lo:Min(p); hi=hi:Max(p)
        end
        local center=(lo+hi)/2
        local editable=game:GetService("AssetService"):CreateEditableMesh()
        assert(editable,"Editable mesh memory budget exhausted")
        meshes[#meshes+1]=editable
        local vertices,normals,uvs={},{},{}
        for i,v in ipairs(group.vertices) do
            vertices[i]=editable:AddVertex(Vector3.new(v[1],v[2],v[3])-center)
            local n,uv=group.normals[i],group.uv[i]
            normals[i]=editable:AddNormal(Vector3.new(n[1],n[2],n[3]))
            uvs[i]=editable:AddUV(Vector2.new(uv[1],uv[2]))
            if i%1000==0 then task.wait() end
        end
        for i,face in ipairs(group.faces) do
            local a,b,c=face[1]+1,face[2]+1,face[3]+1
            local id=editable:AddTriangle(vertices[a],vertices[b],vertices[c])
            editable:SetFaceNormals(id,{normals[a],normals[b],normals[c]})
            editable:SetFaceUVs(id,{uvs[a],uvs[b],uvs[c]})
            if i%1000==0 then task.wait() end
        end
        local part=game:GetService("AssetService"):CreateMeshPartAsync(Content.fromObject(editable))
        part.Name,part.CFrame=group.name,frame*CFrame.new(center)
        part.Anchored,part.CanCollide,part.CanTouch,part.CanQuery=true,false,false,false
        part.DoubleSided=false
        part.Color=Color3.new(srgb(group.color[1]),srgb(group.color[2]),srgb(group.color[3]))
        part.Material=group.metallic>.7 and Enum.Material.Metal or Enum.Material.SmoothPlastic
        if group.name=="Rubber" then part.Material=Enum.Material.Rubber end
        if group.texture then
            assert(textureIds[group.texture],"Unexpected paint map")
            part.Color=Color3.new(1,1,1)
            local appearance=Instance.new("SurfaceAppearance")
            appearance.ColorMap=textureIds[group.texture]
            appearance.MetalnessMap="rbxassetid://112811015235632"
            appearance.RoughnessMap="rbxassetid://132458418620921"
            appearance.Parent=part
        end
        part:SetAttribute("TriangleCount",#group.faces)
        part.Parent=model
        triangleCount=triangleCount+#group.faces
        task.wait()
    end
    model:SetAttribute("Reference","kfc_racer_van.png")
    model:SetAttribute("TriangleCount",triangleCount)
    model:SetAttribute("Purpose","Original Blender static art review; UV paint on actual body")
    model.Parent=parent
    return model
end

return ReferenceVan
