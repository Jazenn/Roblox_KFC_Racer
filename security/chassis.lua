-- ruleid: roblox-dynamic-code-execution
loadstring("untrusted")
-- ruleid: roblox-dynamic-code-execution
load("untrusted")
-- ruleid: roblox-numeric-module-require
require(123456)
-- ruleid: roblox-runtime-asset-loading
service:LoadAsset(123456)
-- ruleid: roblox-runtime-asset-loading
service:LoadAssetVersion(123456)
-- ruleid: roblox-runtime-asset-loading
service:GetObjects("asset")
-- ruleid: roblox-runtime-asset-loading
service:HttpGet("url")
-- ok: roblox-numeric-module-require
require(script.Parent.DriveModel)
