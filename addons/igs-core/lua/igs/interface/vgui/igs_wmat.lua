--[[-------------------------------------------------------------------------
	Запрещено использовать DOCK.
	Размер должен быть указан единоразово и четко

	:SetURL указывать ПОСЛЕ :SetSize
---------------------------------------------------------------------------]]
local PANEL = {}


function PANEL:GetTexture()
	return texture.Get(self.url)
end

function PANEL:GetURL()
	return self.url
end

function PANEL:RenderTexture()
	self.Rendering = true

	-- print("Render",self:GetURL())
	-- print("Size",self:GetSize())

	texture.Delete(self:GetURL())
	texture.Create(self:GetURL())
		:SetSize(self:GetSize())
		:SetFormat(self:GetURL():sub(-3) == "jpg" and "jpg" or "png")
		:Download(self:GetURL(), function()
			if not IsValid(self) then return end

			self.Rendering 	= false
			self.LastURL 	= self:GetURL()
		end, function()
			if not IsValid(self) then return end

			self.Rendering = false
		end)
end

function PANEL:Paint(w,h)
	if (not self:GetTexture() and not self.Rendering) or (self:GetURL() ~= self.LastURL and not self.Rendering) then
		self:RenderTexture()

	elseif self:GetTexture() then
		surface.SetDrawColor(IGS.col.ICON)
		surface.SetMaterial( self:GetTexture() )
		surface.DrawTexturedRect(0,0,w,h)
	end
end

function PANEL:SetURL(sUrl)
	self.url = sUrl or IGS.C.DefaultIcon
end


vgui.Register("igs_wmat",PANEL,"Panel")
-- IGS.UI()
