sTitle = 'Default 7.0 Theme Adjuster'
reaper.ClearConsole()

OS = reaper.GetOS()
script_path = ({reaper.get_action_context()})[2]:match('^.*[/\\]'):sub(1,-2)
themes_path = reaper.GetResourcePath() .. "/ColorThemes"
activePage = reaper.GetExtState(sTitle,'activePage')

function getCurrentTheme()
  local reaperLastTheme = string.match(string.match(reaper.GetLastColorThemeFile(), '[^\\/]*$'),'(.*)%..*$') 
  if(reaper.file_exists(themes_path..'/'..reaperLastTheme..'.ReaperThemeZip')==true) or (reaper.file_exists(themes_path..'/'..reaperLastTheme..'.ReaperTheme')==true) then 
    return reaperLastTheme
  else return nil
  end
end

function themeCheck()
  if themeTitle ~= oldthemeTitle or themeTitle == nil then
    themeTitle = getCurrentTheme()
    last_theme_check = reaper.time_precise()
    switchTheme(themeTitle)
    oldthemeTitle = themeTitle
  else 
    local now = reaper.time_precise()
    if now > last_theme_check+1 and suspendSwitchTheme ~= true  then -- once per second see if the theme filename changed
      last_theme_check = now
      local tn = getCurrentTheme()
      if tn ~= themeTitle then
        switchTheme(themeTitle)
        themeTitle = tn
      end
    end
  end
end

function switchTheme(thisTheme)
  if thisTheme ~= 'Inglar_7.0' and thisTheme ~= 'Inglar_7.0_unpacked' then
    local v = reaper.ShowMessageBox('switch to Default 7.0 Theme?', 'Wrong theme in use', 1)
    if v==1 then
      if(reaper.file_exists(themes_path..'/Inglar_7.0_unpacked.ReaperTheme')==true) then 
        reaper.OpenColorThemeFile(themes_path..'/Inglar_7.0_unpacked.ReaperTheme')
      elseif(reaper.file_exists(themes_path..'/Inglar_7.0.ReaperThemeZip')==true) then 
        reaper.OpenColorThemeFile(themes_path..'/Inglar_7.0.ReaperThemeZip')
      else 
        reaper.ReaScriptError('!Default 7.0 Theme not found')
      end
    end
    if v==2 then reaper.ReaScriptError('!Wrong theme in use') end
  end
end



gfx.init(sTitle,
tonumber(reaper.GetExtState(sTitle,"wndw")) or 900,
tonumber(reaper.GetExtState(sTitle,"wndh")) or 600,
tonumber(reaper.GetExtState(sTitle,"dock")) or 0,
tonumber(reaper.GetExtState(sTitle,"wndx")) or 100,
tonumber(reaper.GetExtState(sTitle,"wndy")) or 50)

gfx.ext_retina = 1


  ---------- COLOURS -----------
  
function setCol(col)
  if col[1] and col[2] and col[3] then
    local r = col[1] / 255
    local g = col[2] / 255
    local b = col[3] / 255
    local a = 1
    if col[4] ~= nil then a = col[4] / 255 else a = 1 end
    gfx.set(r,g,b,a)
    gfx.a2=gfx.a
  end
end

--[[function getProjectCustCols()
  projectCustCols = {}
  for i=0, reaper.CountTracks(0)-1 do
    local c = reaper.GetTrackColor(reaper.GetTrack(0, i))
    if c ~= 0 then
      local r,g,b = reaper.ColorFromNative(c)
      table.insert(projectCustCols,{r,g,b})
    end
  end
end]]

  ---------- TEXT -----------

textPadding = 6

if OS:find("Win") ~= nil then

  gfx.setfont(1, "Calibri", 13)
  gfx.setfont(2, "Calibri", 15)
  gfx.setfont(3, "Calibri", 22)
  gfx.setfont(4, "Calibri", 50)
  
  gfx.setfont(5, "Calibri", 19)
  gfx.setfont(6, "Calibri", 22)
  gfx.setfont(7, "Calibri", 33)
  gfx.setfont(8, "Calibri", 75)
  
  gfx.setfont(9, "Calibri", 26)
  gfx.setfont(10, "Calibri", 30)
  gfx.setfont(11, "Calibri", 44)
  gfx.setfont(12, "Calibri", 100)
  
  baselineShift = {}

elseif OS == 'Other' then

  gfx.setfont(1, "Ubuntu", 10)
  gfx.setfont(2, "Ubuntu", 12)
  gfx.setfont(3, "Ubuntu", 15)
  gfx.setfont(4, "Ubuntu", 38)
  
  gfx.setfont(5, "Ubuntu", 14)
  gfx.setfont(6, "Ubuntu", 16)
  gfx.setfont(7, "Ubuntu", 24)
  gfx.setfont(8, "Ubuntu", 58)
  
  gfx.setfont(9, "Ubuntu", 19)
  gfx.setfont(10, "Ubuntu", 23)
  gfx.setfont(11, "Ubuntu", 33)
  gfx.setfont(12, "Ubuntu", 75)
  
  baselineShift = {0, 0, 3, 3,
                   1, 2, 3, 4,
                   2, 1, 3, 8}

else

  gfx.setfont(1, "Helvetica", 9)
  gfx.setfont(2, "Helvetica", 10)
  gfx.setfont(3, "Helvetica", 14)
  gfx.setfont(4, "Helvetica", 35)
  
  gfx.setfont(5, "Helvetica", 13)
  gfx.setfont(6, "Helvetica", 15)
  gfx.setfont(7, "Helvetica", 22)
  gfx.setfont(8, "Helvetica", 54)
  
  gfx.setfont(9, "Helvetica", 18)
  gfx.setfont(10, "Helvetica", 20)
  gfx.setfont(11, "Helvetica", 30)
  gfx.setfont(12, "Helvetica", 72)
  
  baselineShift = {}
  
end

function text(str,x,y,w,h,align,col,style,lineSpacing,vCenter,wrap)
  local lineSpace = lineSpacing or (11*scaleMult)
  setCol(col or {255,255,255})
  gfx.setfont(style or 1)
  local lines = nil
  if wrap == true then lines = textWrap(str,w)
  else
    lines = {}
    for s in string.gmatch(str, "([^#]+)") do
      table.insert(lines, s)
    end
  end
  if vCenter ~= false and #lines > 1 then y = y - lineSpace/2 end
  for k,v in ipairs(lines) do
    gfx.x, gfx.y = x,y
    gfx.drawstr(v,align or 0,x+(w or 0),y+(h or 0))
    y = y + lineSpace
  end
end

function textWrap(str,w) -- returns array of lines
  local lines,curlen,curline,last_sspace = {}, 0, "", false
  -- enumerate words
  for s in str:gmatch("([^%s-/]*[-/]* ?)") do
    local sspace = false -- set if space was the delimiter
    if s:match(' $') then
      sspace = true
      s = s:sub(1,-2)
    end
    local measure_s = s
    if curlen ~= 0 and last_sspace == true then
      measure_s = " " .. measure_s
    end
    last_sspace = sspace

    local length = gfx.measurestr(measure_s)
    if length > w then
      if curline ~= "" then
        table.insert(lines,curline)
        curline = ""
      end
      curlen = 0
      while length > w do -- split up a long word, decimating measure_s as we go
        local wlen = string.len(measure_s) - 1
        while wlen > 0 do
          local sstr = string.format("%s%s",measure_s:sub(1,wlen), wlen>1 and "-" or "")
          local slen = gfx.measurestr(sstr)
          if slen <= w or wlen == 1 then
            table.insert(lines,sstr)
            measure_s = measure_s:sub(wlen+1)
            length = gfx.measurestr(measure_s)
            break
          end
          wlen = wlen - 1
        end
      end
    end
    if measure_s ~= "" then
      if curlen == 0 or curlen + length <= w then
        curline = curline .. measure_s
        curlen = curlen + length
      else -- word would not fit, add without leading space and remeasure
        table.insert(lines,curline)
        curline = s
        curlen = gfx.measurestr(s)
      end
    end
  end
  if curline ~= "" then
    table.insert(lines,curline)
  end
  return lines
end





  --------- IMAGES ----------
  
imgBufferOffset = 500  

function loadImage(idx, name)

  local i = idx 
  if i then
    local scaleFolder = ''
    if scaleMult == 1.5 then scaleFolder = '/150' end
    if scaleMult == 2 then scaleFolder = '/200' end
    local str = script_path..'/'..'Default_7.0_theme_adjuster resources'.."/"..name..".png"
    if OS:find("Win") ~= nil then str = str:gsub("/","\\") end
    if gfx.loadimg(i, str) == -1 then reaper.ShowConsoleMsg("script image "..name.." not found\n") end
  end
  
  -- look for pink
    gfx.dest = idx
    gfx.x,gfx.y = 0,0
    if isPixelPink(gfx.getpixel()) then --top left is pink
      local bufW,bufH = gfx.getimgdim(idx)
      gfx.x,gfx.y = bufW-1,bufH-1
      if isPixelPink(gfx.getpixel()) then --bottom right also pink
        local tx, ly, bx, ry = 0,0,0,0
        
        gfx.x,gfx.y = 0,0 
        while isPixelPink(gfx.getpixel()) do
          tx = math.floor(gfx.x+1)
          gfx.x = gfx.x+1
        end
        
        gfx.x,gfx.y = 0,0
        while isPixelPink(gfx.getpixel()) do
          ly = math.floor(gfx.y+1)
          gfx.y = gfx.y+1
        end
        
        gfx.x,gfx.y = bufW-1,bufH-1 
        while isPixelPink(gfx.getpixel()) do
          bx = math.floor(bufW - gfx.x)
          gfx.x = gfx.x-1
        end
        
        gfx.x,gfx.y = bufW-1,bufH-1 
        while isPixelPink(gfx.getpixel()) do
          ry = math.floor(bufH - gfx.y)
          gfx.y = gfx.y-1
        end
        
        --reaper.ShowConsoleMsg('top x pink = '..tx..', left y pink = '..ly..', bottom x pink = '..bx..', right y pink = '..ry..'\n')
        bufferPinkValues[idx] = {tx=tx, ly=ly, bx=bx, ry=ry} -- apparently lua understands this, nice
        
      end
    end
  
end

function isPixelPink(r,g,b) 
  if (r==1 and g==0 and b==1) or (r==1 and g==1 and b==0) then -- yellow is also pink. The world's a weird place.
    return true 
  else return false 
  end 
end

function getImage(img)

  for b in ipairs(els) do -- iterate blocks 
    for z in ipairs(els[b]) do -- iterate z
      if els[b][z] ~= nil then
        for j,k in pairs(els[b][z]) do
          if k.img == img and k.imgIdx then
            --reaper.ShowConsoleMsg(img..' is already in buffer '..k.imgIdx..'\n')
            return k.imgIdx
          end
        end
      end
    end
  end
  --not already in a buffer, make a new one
  local buf = nil
  local i = imgBufferOffset
  while buf == nil do -- find the next empty buffer and assign
    local h,w = gfx.getimgdim(i)
    if h==0 then buf=i end
    i = i+1
  end
  --reaper.ShowConsoleMsg('image: '..img..' to '..buf..'\n')
  loadImage(buf, img)  
  return buf
end

function pinkBlit(img, srcx, srcy, destx, desty, tx, ly, bx, ry, unstretchedC2W, unstretchedR2H, stretchedC2W, stretchedR2H)
  --reaper.ShowConsoleMsg(img..' unstretchedC2W, unstretchedR2H = '..unstretchedC2W..', '..unstretchedR2H..',  stretchedC2W, stretchedR2H = '..stretchedC2W..', '..stretchedR2H..'\n')
  gfx.blit(img, 1, 0, srcx +1, srcy +1, tx-1, ly-1, destx, desty, tx-1, ly-1)
  gfx.blit(img, 1, 0, srcx +tx, srcy +1, unstretchedC2W, ly-1, destx+tx-1, desty, stretchedC2W, ly-1)
  gfx.blit(img, 1, 0, srcx +tx +unstretchedC2W, srcy +1, bx-1, ly-1, destx+tx-1+stretchedC2W, desty, bx-1, ly-1)
  
  gfx.blit(img, 1, 0, srcx+1, ly, tx-1, unstretchedR2H, destx, desty+ly-1, tx-1, stretchedR2H)
  gfx.blit(img, 1, 0, srcx +tx, ly, unstretchedC2W, unstretchedR2H, destx+tx-1, desty+ly-1, stretchedC2W, stretchedR2H)
  gfx.blit(img, 1, 0, srcx +tx +unstretchedC2W, ly, bx-1, unstretchedR2H, destx+tx-1+stretchedC2W, desty+ly-1, bx-1, stretchedR2H)
  
  gfx.blit(img, 1, 0, srcx+1, ly +unstretchedR2H, tx-1, ry-1, destx, desty+ly-1+stretchedR2H, tx-1, ry-1)
  gfx.blit(img, 1, 0, srcx +tx, ly +unstretchedR2H, unstretchedC2W, ry-1, destx+tx-1, desty+ly-1+stretchedR2H, stretchedC2W, ry-1)
  gfx.blit(img, 1, 0, srcx +tx +unstretchedC2W, ly +unstretchedR2H, bx-1, ry-1, destx+tx-1+stretchedC2W, desty+ly-1+stretchedR2H, bx-1, ry-1)
end

function reloadImgs()
  for b in ipairs(els) do -- iterate blocks 
    for z in ipairs(els[b]) do -- iterate z
      if els[b][z] ~= nil then
        for j,k in pairs(els[b][z]) do
          k:reloadImg()
        end
      end
    end
    doArrange = true
  end
end

function imageOnOffSuffix(img, suffix)
  local imageRoot = string.sub(img, 1, #img - string.find(string.reverse(img), "_"))
  --reaper.ShowConsoleMsg('suffix: '..suffix..' to image root : '..imageRoot..' \n')
  return imageRoot..suffix
end





  --------- OBJECTS ----------

els = {}
function AddEl(o)
  if o.x == nil and o.y == nil and o.updateOn == nil and o.action == nil then --just a proto
  else
    if o.parent then  adoptChild(o.parent, o) end
    if belongsToPage ~= nil then o.belongsToPage = belongsToPage end
    if o.block == nil then if o.parent and o.parent.block then o.block = o.parent.block  end end-- no block specified, inherit from parent
    if o.z == nil then if o.parent and o.parent.z then o.z = o.parent.z  end end -- no z specified, inherit from parent
    if els[o.block] == nil then els[o.block] = {} end
    if els[o.block][o.z] == nil then els[o.block][o.z] = {o}
    else els[o.block][o.z][#els[o.block][o.z]+1] = o
    end
  end
end

El = {}
function El:new(o)
  local o = o or {}
  if o.interactive == nil then o.interactive = true end
  if belongsToPage ~= nil then o.belongsToPage = belongsToPage end
  self.__index = self
  AddEl(o)
  setmetatable(o, self)
  return o
end

Block = {}
function Block:new(o)
  local o = o or {}
  if els == nil then els = {} end
  els[#els+1] = o
  self.__index = self
  setmetatable(o, self)
  return o
end

ScrollbarV = El:new{} 
function ScrollbarV:new(o)
  o.col = {0,0,200,255}
  o.w = ScrollbarThickness
  o.interactive=false
  
  self.__index = self
  AddEl(o)
  o.children = { El:new({parent=o, x=0, y=0, w=o.w, h=0, col={0,255,255,200}, mouseOverCol={255,255,0,255}, mouseOverCursor=true,
    onArrange = function()
      if els[o.scrollbarOfBlock].scrollableH then
        o.children[1].h =  math.floor(els[o.scrollbarOfBlock].h * (els[o.scrollbarOfBlock].h / els[o.scrollbarOfBlock].scrollableH))
      else o.children[1].h = 0
      end
    end,
    onDrag = function(dX, dY)
      local dX, dY = scaleMult*dX, scaleMult*dY
      if els[o.scrollbarOfBlock].scrollY and dY == 0 then 
        els[o.scrollbarOfBlock].initScrollY = els[o.scrollbarOfBlock].scrollY 
      end
      local scrollVal = dY + (els[o.scrollbarOfBlock].initScrollY or 0)
      if scrollVal > (els[o.scrollbarOfBlock].scrollableH - els[o.scrollbarOfBlock].h) then
        scrollVal = els[o.scrollbarOfBlock].scrollableH - els[o.scrollbarOfBlock].h
      end
      if scrollVal < 0 then scrollVal = 0 end 
      els[o.scrollbarOfBlock].scrollY = scrollVal
      els[o.block][1][2].y = math.floor(scrollVal * (els[o.scrollbarOfBlock].h / els[o.scrollbarOfBlock].scrollableH))
      doArrange = true
    end,
    
    onMouseWheel = function(wheel_amt)
      local scrollVal = els[o.scrollbarOfBlock].scrollY - (wheel_amt*5)
      els[o.scrollbarOfBlock].scrollY = scrollVal
      els[o.block][1][2].y = scrollVal
      doArrange = true
    end,
    
    onGfxResize = function()
      els[o.block][1][2].y, els[o.scrollbarOfBlock].scrollY = 0, 0 -- annoying, just reset them
    end
    }) }
    
  setmetatable(o, self)
  return o
end


Button = El:new{} 
function Button:new(o)
  self.__index = self
  
  if o.img == nil and col == nil then           -- then its a text button
    o.col, o. mouseOverCol = o.parent.buttonOffStyle.col, o.parent.buttonOffStyle.mouseOverCol 
    if o.text == nil then o.text = {str='text button'} end
    o.text.style, o.text.align, o.text.col = 2, 5, o.parent.buttonOffStyle.textCol or {150,255,150}
    
    if o.w == nil then
      gfx.setfont(o.text.style)
      o.w = gfx.measurestr(o.text.str) + textPadding + textPadding
    end
    
  end
  
  o.onClick = function()
    if o.parent.controlType == 'themeParam' then
      if o.action then
        local v = 0
        if o.action == 'increment' then v = o.parent.paramV + 1 end
        if o.action == 'decrement' then v = o.parent.paramV - 1 end
        o.parent.paramV = math.Clamp(v,o.parent.paramVMin,o.parent.paramVMax)
      else
        local v = o.parent.paramV or 0
        if v==0 then o.parent.paramV = 1    
        else o.parent.paramV = 0 
        end
      end
      --reaper.ShowConsoleMsg(o.parent.paramDesc..', image: :'..o.img..',   value is now:'..o.parent.paramV..'\n')
      o.parent.doUpdate = true
      o:addToDirtyZone()
    end
    
    if o.parent.scriptAction then o.parent.scriptAction(o) end
    
    if o.controlType == 'radio' then
      if o.parent.value==o.value and o.parent.allOffValue then
        o.parent.value = o.parent.allOffValue
      else
        if o.parent.doOnEnable then o.parent.doOnEnable() end
        o.parent.value = o.value
      end
      o.parent.doUpdate = true
    end
    
    if o.controlType == 'visFlag' then
      o.parent.values[o.valIdx] = ~o.parent.values[o.valIdx]
      o.parent.newClick = true
      o.parent.doUpdate = true
    end
    
    if o.controlType == 'reaperActionToggle' then
      reaper.Main_OnCommand(o.parent.param, 0)
      o.parent.doUpdate = true
    end
    
    if o.controlType == 'tcpOrderSwap' then
      --reaper.ShowConsoleMsg(o.params[1]..' swap with '..o.params[2]..' \n')
      local v1, v2 = o.parent.paramV[o.params[1]], o.parent.paramV[o.params[2]]
      o.parent.paramV[o.params[1]], o.parent.paramV[o.params[2]] = v2, v1 -- swap 'em
      o.parent.doUpdate = true
    end
    
    o.imgIdx = nil
    doArrange = true
  end
  AddEl(o)
  o.iType= 3
  setmetatable(o, self)
  return o
end

Knob = El:new{} 
function Knob:new(o)
  self.__index = self
  AddEl(o)
  o.iType='stack'
  o.paramV, o.paramVMin, o.paramVMax = o.paramV or 0, o.parent.remapToMin or o.paramVMin or 0, o.parent.remapToMax or o.paramVMax or 0
  o.onDrag = function(dX, dY)
    local scrollVal = dX - dY 
    if scrollVal == 0 then o.initDragParamV = o.parent.paramV end
    o.paramV = math.floor(math.Clamp((o.initDragParamV or 0) + scrollVal, o.paramVMin, o.paramVMax))
    o.parent.paramV = o.paramV
    o.parent.doUpdate = true
    o:addToDirtyZone()
  end
  o.onDoubleClick = function()
    o.parent.paramV =remapParam(o.parent.paramVDef, o.parent.paramVMin, o.parent.paramVMax, o.parent.remapToMin or o.parent.paramVMin, o.parent.remapToMax or o.parent.paramVMax)
    --o.parent.paramV = o.parent.paramVDef
    o.parent.doUpdate = true
    o:addToDirtyZone()
  end
  setmetatable(o, self)
  return o
end

Fader = El:new{} 
function Fader:new(o)
  self.__index = self
  AddEl(o)
  o.img = o.img or 'slider'
  o.iType=3
  o.onDrag = function(dX, dY)
    local scrollVal = dX
    if scrollVal == 0 then 
      o.initDragX = o.x 
    end
    --reaper.ShowConsoleMsg('scrollVal: '..scrollVal..'\n')
    o.parent.paramV = math.floor(math.Clamp((o.initDragX+dX)/(o.parent.w-o.drawW)*(o.parent.paramVMax-o.parent.paramVMin)+o.parent.paramVMin,o.parent.paramVMin,o.parent.paramVMax))
    o.parent.doUpdate = true
  end
  o.onDoubleClick = function()
    o.parent.paramV = o.parent.paramVDef
    o.parent.doUpdate = true
  end
  setmetatable(o, self)
  return o
end

Readout = El:new{} 
function Readout:new(o)
  self.__index = self
  AddEl(o)
  o.col = {200,100,100}
  local s = o.text.style or 2
  o.text={str='', style=s, align=4, col={255,255,255}}
  if o.units and not o.paramTitles then
    local unitStrLength = gfx.measurestr(o.units) + textPadding
    o.parent.units = El:new({parent=o.parent, x=0, y=0, w=unitStrLength, h=o.h or 16, flow=true, col = {1000,0,255}, text={str=o.units, style=2, align=4, padding=0, col={0,0,0}} })
  end
  o.onDoubleClick = function()
    local r, v = reaper.GetUserInputs(o.parent.paramDesc or '', 1, (o.parent.remapToMin or o.parent.paramVMin)..(o.units or '')..' - '..(o.parent.remapToMax or o.parent.paramVMax)..(o.units or ''), o.parent.paramV)
    if r == true and tonumber(v) then
      o.parent.paramV = math.Clamp(tonumber(v), o.parent.remapToMin or o.parent.paramVMin, o.parent.remapToMax or o.parent.paramVMax)
      o.parent.doUpdate = true
      o.parent:addToDirtyZone()
    end
  end
  o.onMouseWheel = function(wheel_amt)
    o.parent.paramV = math.Clamp(o.parent.paramV+wheel_amt , o.parent.remapToMin or o.parent.paramVMin, o.parent.remapToMax or o.parent.paramVMax)
    o.parent.doUpdate = true
    o.parent:addToDirtyZone()
  end
  
  setmetatable(o, self)
  return o
end

ColChooser = El:new{} 
function ColChooser:new(o)
  self.__index = self
  AddEl(o)
  o.col = {125,137,137}
  o.w, o.h = 54, 20
  o.onClick = function()
    local retval, col = reaper.GR_SelectColor()
    if retval==1 then
      local r, g, b = reaper.ColorFromNative(col)
      paramSet(paramIdxGet(o.parent.paramDesc), r)
      paramSet(paramIdxGet(o.parent.paramDesc..' G'), g)
      paramSet(paramIdxGet(o.parent.paramDesc..' B'), b)
      o.col = {r,g,b}
      o:addToDirtyZone()
    end
  end
  setmetatable(o, self)
  return o
end


ColPreset = El:new{} 
function ColPreset:new(o)
  self.__index = self
  AddEl(o)
  o.y, o.w, o.h = o.y or 0, o.w or 20, o.h or 20
  o.col = o.col or {125,137,137}
  o.onClick = function()
    paramSet(paramIdxGet(o.parent.paramDesc), o.col[1])
    paramSet(paramIdxGet(o.parent.paramDesc..' G'), o.col[2])
    paramSet(paramIdxGet(o.parent.paramDesc..' B'), o.col[3])
    o.parent.children[1].col = {r,g,b}
    o.parent.children[1]:addToDirtyZone()
    o.parent.doUpdate = true
  end
  setmetatable(o, self)
  return o
end

Control = El:new{} 
function Control:new(o)
  self.__index = self
  AddEl(o)
  o.col = o.col or {100,50,100}
  o.h = o.h or 36
  o.controlType = o.controlType or 'themeParam'
  local label = o.labelStr or o.paramDesc or o.desc or 'label'
  local readoutStyle, labelStyle = 2, 1
  gfx.setfont(labelStyle)
  local labelStrLength = gfx.measurestr(label) + textPadding + textPadding
  o.w = o.w or labelStrLength                                                               --<< TEMP whole control width is ...whatever, just for now
  
  if o.paramVMin == nil or o.paramVMax == nil then
    if o.controlType == 'themeParam' then
      local p = paramIdxGet(o.paramDesc)
      if type(o.param) == 'number' then p = o.param end
      local tmp, tmp, tmp, paramVDef, paramVMin, paramVMax = reaper.ThemeLayout_GetParameter(p)
      if o.remapToMin and o.remapToMax then
        paramVDef, paramVMin, paramVMax = remapParam(paramVDef, paramVMin, paramVMax, o.remapToMin, o.remapToMax), o.remapToMin, o.remapToMax
      end
      o.paramVDef, o.paramVMin, o.paramVMax = paramVDef, paramVMin, paramVMax
    end
  end
  
  o.onReaperChange = function(k) 
    if o.controlType == 'reaperActionToggle' then o.onUpdate(o) end
    if type(o.param) == 'number' then -- Reaper action params are a number not a string description, and may have changed in Reaper
      if k.fader and k.paramV then
        local retval, desc, value, defValue, minValue, maxValue = reaper.ThemeLayout_GetParameter(k.param)
        local vMin, vMax = k. remapToMin or k.paramVMin, k. remapToMax or k.paramVMax
        if k.remapToMin and k.remapToMax then 
          o.paramV = remapParam(value, minValue, maxValue, k.remapToMin, k.remapToMax)
        else o.paramV = value 
        end
        k.fader.x = math.floor(((k.paramV - vMin) / (vMax - vMin)) * (k.w - (k.fader.drawW or 0)))
      end
    end
  end
  
  
  o.onUpdate = function(k)
    
    local p = paramIdxGet(o.paramDesc)
    if type(o.param) == 'number' then p = o.param end
    local retval, desc, value, defValue, minValue, maxValue = reaper.ThemeLayout_GetParameter(p)
    --reaper.ShowConsoleMsg('onUpdate of param '..p..' : '..(desc or 'untitled')..', value = '..value..', minValue = '..minValue..', maxValue = '..maxValue..'\n')
    
    if o.controlType == 'themeParam' then
      if o.paramV == nil then -- set paramV for the first time
        --reaper.ShowConsoleMsg('paramV was nil\n')
        if k.remapToMin and k.remapToMax then 
          o.paramV = remapParam(value, minValue, maxValue, k.remapToMin, k.remapToMax)
          --reaper.ShowConsoleMsg(value..' becomes '..o.paramV..'\n')
        else o.paramV = value 
        end
      else 
        local v = o.paramV
        if k.remapToMin and k.remapToMax then 
          v = remapParam(o.paramV, k.remapToMin, k.remapToMax, minValue, maxValue) 
          --reaper.ShowConsoleMsg(o.paramV..' becomes '..v..'\n')
        end
        if v ~= value then -- then the user has changed o.paramV
          if o.style=='colour' then
            --local R = value
            --local tmp, tmp, G = reaper.ThemeLayout_GetParameter(paramIdxGet(o.paramDesc..' G'))
            --local tmp, tmp, B = reaper.ThemeLayout_GetParameter(paramIdxGet(o.paramDesc..' B'))
            --reaper.ShowConsoleMsg(R..' '..G..' '..B..'\n')
          else
            paramSet(p, v)
          end
        end
      end
    end
    
    if o.controlType == 'reaperActionToggle' then
      local p = reaper.GetToggleCommandState(o.param) -- o.param will be a Reaper command_id
      if p==1 then o.children[1].img = imageOnOffSuffix(o.children[1].img, '_on') 
      else o.children[1].img = imageOnOffSuffix(o.children[1].img, '_off') 
      end
      o.children[1].imgIdx = nil
    end
    
    if o.controlType == 'tcpSec' then
      o.parent.doUpdate = true
    end 
    
    if o.controlType == 'visFlagRow' then

      local flagMults = {1,2,4,8}
      if k.newClick==nil then -- then this is running for first time or because layout changed
        for t, flag in pairs(flagMults) do
          if value & flag ~= 0 then k.values[t] = -1 -- bit is on
          else k.values[t] = 0 -- bit is off
          end
        end
      else -- else it was a click
        local pVal = 0
        for l,m in pairs(k.children or {}) do
          if k.values[l]~=0 then
            pVal = pVal + flagMults[l]
          end 
        end
        paramSet(p,pVal)        
        k.newClick=nil
      end

      for l,m in pairs(k.children or {}) do
        if k.values[l]==0 then m.col, m.mouseOverCol, m.text.col = k.buttonOffStyle.col, k.buttonOffStyle.mouseOverCol, k.buttonOffStyle.textCol
        else m.col, m.mouseOverCol, m.text.col = k.buttonOnStyle.col, k.buttonOnStyle.mouseOverCol, k.buttonOnStyle.textCol
        end
      end
      
      if k.values[4]~=0 then
        for i=1,3 do 
          k.children[i].col, k.children[i].mouseOverCol, k.children[i].text.col = k.buttonOffStyle.col, k.buttonOffStyle.mouseOverCol, {50,50,50}
          k.children[i].doUpdate = true
        end
      end
      
    end

    if o.scriptAction then o.scriptAction(o) end 
    
    if k.style == 'radio' then
      for i, v in ipairs(k.children) do
        
        if v.img then
          if v.value == k.value then 
            v.img = imageOnOffSuffix(v.img, '_on')
          else v.img = imageOnOffSuffix(v.img, '_off')
          end
          v.imgIdx = nil
        end
        
        if v.parent.buttonOffStyle then -- page radio buttons, tcp sec radios
          --reaper.ShowConsoleMsg('onUpdate a Radio, v.value = '..v.value..',  k.value = '..k.value..'\n')
          if v.value == k.value then
            v.x, v.w, v.col, v.mouseOverCol, v.text.col = v.parent.buttonOnStyle.x or v.x, v.parent.buttonOnStyle.w or v.w, v.parent.buttonOnStyle.col, 
                                                          v.parent.buttonOnStyle.mouseOverCol, v.parent.buttonOnStyle.textCol
          else
            v.x, v.w, v.col, v.mouseOverCol, v.text.col = v.parent.buttonOffStyle.x or v.x, v.parent.buttonOffStyle.w or v.w, v.parent.buttonOffStyle.col, 
                                                          v.parent.buttonOffStyle.mouseOverCol, v.parent.buttonOffStyle.textCol
          end
        end
        
        v:mouseAway()
        v:addToDirtyZone()
        doArrange = true
      end
    end
    
    if k.style == 'button' then
      if o.action == nil and o.controlType ~= 'reaperActionToggle' then -- then its a toggle button
        local v = k.paramV or 0
        if v==0 then k.children[1].img = imageOnOffSuffix(k.children[1].img, '_off')
        else k.children[1].img = imageOnOffSuffix(k.children[1].img, '_on')
        end
        k.children[1].imgIdx = nil
      end
    end
    
    if k.style == 'colour' then
      local tmp, tmp, R = reaper.ThemeLayout_GetParameter(paramIdxGet(k.paramDesc))
      local tmp, tmp, G = reaper.ThemeLayout_GetParameter(paramIdxGet(k.paramDesc..' G'))
      local tmp, tmp, B = reaper.ThemeLayout_GetParameter(paramIdxGet(k.paramDesc..' B'))
      k.children[1].col = {R,G,B}
    end
    
    if k.knob and k.paramV and k.hidden ~= true then
      local vMin, vMax = k. remapToMin or k.paramVMin, k. remapToMax or k.paramVMax
      k.knob.iFrame = math.floor((k.paramV - vMin) / (vMax - vMin) * (k.knob.iFrameC-1))
    end
    
    if k.fader and k.paramV then
      local vMin, vMax = k. remapToMin or k.paramVMin, k. remapToMax or k.paramVMax
      k.fader.x = math.floor(((k.paramV - vMin) / (vMax - vMin)) * (k.w - (k.fader.drawW or 0)))
    end
    
    if k.incButton or k.decButton then
      if k.paramV == k.paramVMin then k.decButton.img = 'spinner_empty' else k.decButton.img, k.incButton.imgIdx = 'spinner_down', nil end
      if k.paramV == k.paramVMax then k.incButton.img = 'spinner_empty' else k.incButton.img, k.decButton.imgIdx = 'spinner_up', nil end
    end
    
    if k.readout and k.paramV then
      if k.paramTitles then k.readout.text.str = k.paramTitles[k.paramV+1] or ''
      else k.readout.text.str = k.paramV
      end
      
      gfx.setfont(readoutStyle)
      local readoutStrLength = gfx.measurestr(k.readout.text.str) + textPadding + textPadding
      k.readout.w = readoutStrLength
      doArrange = true
      k.readout:addToDirtyZone()
    end
    
    k.doUpdate = false
  end
  
  if o.style == 'knob' then
    El:new({parent=o, x=0, y=0, img='knob', iType=1}) -- knob bg image
    o.knob = Knob:new({parent=o, x=0, y=0, img=o.img, iFrameH=o.iFrameH, iFrame=o.iFrame, paramVMin=o.paramVMin, paramVMax=o.paramVMax})
    o.readout = Readout:new({parent=o, x=20, y=0, h=20, text={style=readoutStyle}, units=o.units})
    El:new({parent=o, x=0, y=20, w=labelStrLength, h=16, col = {255,255,0}, text={str= label or 'label', style=labelStyle, align=4, col={0,0,0}} })
  end
  
  if o.style == 'fader' then
    o.fader = Fader:new({parent=o, x=0, y=-4})
    local label=El:new({parent=o, x=0, y=20, w=labelStrLength, h=16, col = {255,255,0}, text={str= label, style=labelStyle, align=4, col={0,0,0}} })
    o.readout = Readout:new({parent=o, flow=label, x=0, y=20, h=16, text={style=readoutStyle}, units=o.units})
  end
  
  if o.style == 'button' then
    Button:new({parent=o, x=0, y=0, img=o.controlImg, controlType=o.controlType, toolTip=o.toolTip})
    if o.label ~= 'none' then
      El:new({parent=o, x=0, y=20, w=labelStrLength, h=16, col = {255,255,0}, toolTip=o.toolTip, text={str= label or 'label', style=labelStyle, align=4, col={0,0,0}} })
    end
  end
  
  if o.style == 'spinner' then
    o.incButton = Button:new({parent=o, x=0, y=0, img='spinner_up', action = 'increment'})
    o.decButton = Button:new({parent=o, x=0, y=10, img='spinner_down', action = 'decrement'})
    o.readout = Readout:new({parent=o, x=20, y=0, h=20, text={style=readoutStyle}, units=o.units, paramTitles=o.paramTitles})
    El:new({parent=o, x=0, y=20, w=labelStrLength, h=16, col = {255,255,0}, text={str= label or 'label', style=labelStyle, align=4, col={0,0,0}} })
  end
  
  if o.style == 'colour' then
    ColChooser:new({parent=o, x=0, y=0})
    ColPreset:new({parent=o, x=1, flow=true})
    ColPreset:new({parent=o, x=1, col={38,38,38}, flow=true})
    ColPreset:new({parent=o, x=1, col={100,100,100}, flow=true})
    ColPreset:new({parent=o, x=1, col={51,51,51}, flow=true})
    El:new({parent=o, x=0, y=20, w=labelStrLength, h=16, col = {255,255,0}, text={str= label or 'label', style=labelStyle, align=4, col={0,0,0}} })
  end
  
  if o.style == 'visFlagRow' then
    o.w, o.h = 322, 20
    o.controlType = 'visFlagRow'
    o.values = {0,0,0,0}
    o.col={30,30,30}
    o.buttonOffStyle = {col={50,50,50}, mouseOverCol={45,45,45}, textCol={80,80,80}}
    o.buttonOnStyle = {col={50,50,50}, mouseOverCol={140,140,140}, textCol={210,80,80}}
    Button:new({parent=o, x=80, y=2, w=58, h=15, style='button', controlType = 'visFlag', valIdx = 1, text={str='HIDE'}})
    Button:new({parent=o, x=2, y=2, w=58, h=15, flow=true, style='button', controlType = 'visFlag', valIdx = 2, text={str='HIDE'}})
    Button:new({parent=o, x=2, y=2, w=58, h=15, flow=true, style='button', controlType = 'visFlag', valIdx = 3, text={str='HIDE'}})
    Button:new({parent=o, x=8, y=2, w=54, h=15, flow=true, style='button', controlType = 'visFlag', valIdx = 4, text={str='HIDE'}})
  end
  
  setmetatable(o, self)
  return o
end


-------------- PARAMS --------------
 
function indexParams()
  themeCheck()
  paramsIdx ={['A']={},['B']={},['C']={},['global']={}}
  local i=0
  while reaper.ThemeLayout_GetParameter(i) ~= nil do
    local tmp,desc = reaper.ThemeLayout_GetParameter(i)
    if string.sub(desc, 1, 6) == 'Layout' then
      local layout, paramDesc = string.sub(desc, 8, 8), string.sub(desc, 12)
      if paramsIdx[layout] ~= nil then paramsIdx[layout][paramDesc] = i end
    else paramsIdx.global[desc] = i end
    i = i+1
  end
  return true
end

function paramIdxGet(param)
  if param == nil then return 10000 end -- if you're going to send nonsense, send it somewhere harmless
  --reaper.ShowConsoleMsg('paramIdxGet param '..param..'\n')
  if paramsIdx.global[param] ~= nil then
    return assert(paramsIdx.global[param], 'Incorrect Theme or Script version? Parameter "'..param..'" not found in theme "'..themeTitle..'"') 
  else
    if activeLayout==nil then activeLayout = 'A' end
    --reaper.ShowConsoleMsg('paramIdxGet activeLayout '..activeLayout..' param '..param..' = '..paramsIdx[activeLayout][param]..'\n')
    return assert(paramsIdx[activeLayout][param], 'Incorrect Theme or Script version? Parameter "'..param..'" not found in theme "'..themeTitle..'"') 
  end
end

function paramSet(p,v)
  --reaper.ShowConsoleMsg('set parameter '..p..' to '..v..'\n')
  reaper.ThemeLayout_SetParameter(p, v, true)
  ThemeLayout_RefreshAll = true
end

function remapParam(value, min, max, translatedMin, translatedMax)
  local newValue = math.floor((value - min)/(max - min) * (translatedMax - translatedMin) + translatedMin)
  return newValue
end


  --------- FUNCS ----------
  
  
function El:purge()
  --reaper.ShowConsoleMsg('purging\n')
  for b in ipairs(els) do -- iterate block
    for z in ipairs(els[b]) do
      if els[b][z] ~= nil and #els[b][z] ~= 0 then
        for j,k in pairs(els[b][z]) do
          if k == self then
            if self.children ~= nil then 
              for l,m in pairs(self.children) do
                m:purge() 
              end 
            end
            if self:addToDirtyZone(b,z) == true then
              if self.imgIdx then
                gfx.setimgdim(self.imgIdx,0,0)
              end
              table.remove(els[b][z],j)
              doDraw = true
            end
          end
        end
      end
    end
  end -- end iterating blocks
end

function colCycle(self) -- for debugging / inducing headaches
  if colDebug ~= true then self.col = {0,255,0,150}
  else self.col = {math.random(255),math.random(255),math.random(255),255}
    self:addToDirtyZone()
  end
end  

function math.Clamp(val, min, max)
  return math.min(math.max(val, min), max)
end

function adoptChild(parent, child)
  if parent.children then parent.children[#parent.children + 1] = child
  else parent.children = {child}
  end
end

function addTimer(self,index,time) 
  if Timers == nil then Timers = {} end
  if Timers[index] == nil then
    if self.Timers == nil then self.Timers = {} end
    self.Timers[index] = nowTime + time
    Timers[index] = self 
    return true
  end
end

function removeTimer(self,index)
  if self.Timers and self.Timers[index] and Timers[index] and self.onTimerComplete[index] then
    self.Timers[index], Timers[index], self.onTimerComplete[index] = nil, nil, nil
  end
end

function cycleBitmapStack(self)
  if self.iFrameC then
    self.iFrameDirection = self.iFrameDirection or 1
    if self.iFrame == self.iFrameC-1 and self.iFrameDirection == 1 then self.iFrameDirection = -1 end
    if self.iFrame == 0 then self.iFrameDirection = 1 end
    self.iFrame = self.iFrame + self.iFrameDirection
    self:addToDirtyZone()
  end
end

function El:reloadImg()
  if self.img then
    if self.imgIdx then
      local i = scaleToDrawImg(self) 
      loadImage(self.imgIdx, i, self.iLocation or nil, self.noIScales)
    end
    self:addToDirtyZone()
  end
end

function scaleToDrawImg(self)
  local i = self.img
  if scaleMult == 1.5 then i = self.img..'_150' end
  if scaleMult == 2 then i = self.img..'_200' end 
  return i
end

function setScale(scale)
  scaleMult = scale
  if scaleMult == 1 then textScaleOffs = 0 end
  if scaleMult == 1.5 then textScaleOffs = 4 end
  if scaleMult == 2 then textScaleOffs = 8 end
  reloadImgs()
  doArrange = true
  doOnGfxResize()
end

function fitText(self)
  gfx.setfont(self.text.style or 1)
 return gfx.measurestr(self.text.str)
end

function getPreviousEl(self) -- returns the previous child of this element's parent
  if self.parent then
    for i=1, #self.parent.children do
      if self.parent.children[i] == self and i>1 then
        return self.parent.children[i-1] 
      end
    end
  end
end

  --------- ARRANGE ----------

function El:dirtyXywhCheck(b,z)
  if self.drawX == nil then -- then you've never been arranged
    if self:arrange(self) == true then 
      self:addToDirtyZone(b, z, false) 
    end
  else
    self.ox,self.oy,self.ow,self.oh = self.drawX, self.drawY, self.drawW, self.drawH
    if self:arrange(self) == true then
      if self.drawX ~= self.ox or self.drawY ~= self.oy or self.drawW ~= self.ow or self.drawH ~= self.oh then 
        self:addToDirtyZone(b, z, true)
      end
    end
  end
end

function El:addToDirtyZone(b, z, newXywh)
  b = b or self.block or 1
  z = z or self.z or 1 
  local kx,ky,kw,kh = self.drawX or self.x, self.drawY or self.y, self.drawW or self.w or 0, self.drawH or self.h or 0 
  --reaper.ShowConsoleMsg((self.img or 'el')..' addToDirtyZone '..' kx:'..kx..' ky:'..ky..' kw:'..kw..' kh:'..kh..'\n')
  if dirtyZones[b] == nil then dirtyZones[b] = {} end
  if dirtyZones[b][z] == nil then dirtyZones[b][z] = {x1={},y1={},x2={},y2={}} end
  if kw ~= nil then
    dirtyZones[b][z].x1[#dirtyZones[b][z].x1+1] = kx
    dirtyZones[b][z].y1[#dirtyZones[b][z].y1+1] = ky
    dirtyZones[b][z].x2[#dirtyZones[b][z].x2+1] = kx + kw
    dirtyZones[b][z].y2[#dirtyZones[b][z].y2+1] = ky + kh
    --reaper.ShowConsoleMsg('b='..b..',z='..z..' x y w h = '..kx..' '..ky..' '..kw..' '..kh..'\n')
  end
  if newXywh == true then -- element has moved, so also dirtyZone its old location
    dirtyZones[b][z].x1[#dirtyZones[b][z].x1+1] = self.ox
    dirtyZones[b][z].y1[#dirtyZones[b][z].y1+1] = self.oy
    dirtyZones[b][z].x2[#dirtyZones[b][z].x2+1] = self.ox + self.ow
    dirtyZones[b][z].y2[#dirtyZones[b][z].y2+1] = self.oy + self.oh
  end
  doDraw = true
  return true
end

function hasOverlap(x1,y1,w1,h1,x2,y2,w2,h2)
  if x1+w1 > x2 and x1 < x2 + w2 and y1+h1 > y2 and y1 < y2 + h2 then return true end
end

function resizeParent(self)
  if self.resizeParent and self.resizeParent=='v' and (self.drawY + self.drawH) > (self.parent.drawY + self.parent.drawH) then
    self.parent.ox, self.parent.oy, self.parent.ow, self.parent.oh = self.parent.drawX, self.parent.drawY, self.parent.drawW, self.parent.drawH
    self.parent.drawH = self.drawY + self.drawH - self.parent.drawY + (self.border or 0)
    self.parent:addToDirtyZone(self.parent.block or 1, self.parent.z or 1, true)
    if self.parent.parent then resizeParent(self.parent) end
  end
end

function doOnGfxResize()
  for b in ipairs(els) do -- iterate blocks
    for z in ipairs(els[b]) do -- iterate z
      if els[b][z] ~= nil then
        for j,k in pairs(els[b][z]) do
          if k.onGfxResize then k.onGfxResize(k) end
          doArrange = true
        end
      end
    end
  end
end

function toEdge(self,edge) -- sets an edge to another element's edge. Called by el:arrange()
 if edge == 'left' then -- my left edge
    if self.l[3] == 'left' then reaper.ShowConsoleMsg('left toEdge left not done yet\n') end
    if self.l[3] == 'right' then return self.l[2].drawX + self.l[2].drawW + self.x end
  end
  if edge == 'top' then -- my top edge
    if self.t[3] == 'top' then return self.t[2].drawY + self.y end
    if self.t[3] == 'bottom' then return self.t[2].drawY + self.t[2].drawH + self.y end
  end
  if edge == 'right' then -- my right edge
    if self.r[3] == 'left' then reaper.ShowConsoleMsg('right toEdge left not done yet\n') end
    if self.r[3] == 'right' then return self.r[2].drawX + self.r[2].drawW - (self.drawX or self.x) + self.w end
  end
  if edge == 'bottom' then -- my bottom edge
    if self.b[3] == 'top' then reaper.ShowConsoleMsg('bottom toEdge top not done yet\n') end
    if self.b[3] == 'bottom' then return self.b[2].drawY + self.b[2].drawH - self.drawY + self.h end
  end
end

function El:arrange()
  local px, py, pw, ph = 0, 0, 0, 0 
  if self.parent ~= nil then 
    px, py, pw, ph = self.parent.drawX or 0, self.parent.drawY or 0, self.parent.drawW or 0, self.parent.drawH or 0 
  else -- else is root to the block
    px, py, pw, ph = els[self.block].x, els[self.block].y, els[self.block].w, els[self.block].h
    --reaper.ShowConsoleMsg('arranging root element of block '..self.block..' (x:'..px..'  y:'..py..'  w:'..pw..'  h:'..ph..')\n')
  end
 
  if self.onArrange then self.onArrange(self) end
  
  if self.belongsToPage and activePage then
    if self.belongsToPage ~= activePage then self.hidden = true
    else if self.hidden == true then -- it shouldn't, change hidden state and update
        self.hidden = nil
        self.doUpdate = true
      end
    end
  end
  
  self.drawX = px+((self.x or 0)+(self.border or 0))*scaleMult + (self.scrollX or 0)
  self.drawY = py+((self.y or 0)+(self.border or 0))*scaleMult + (self.scrollY or 0)
  self.drawW, self.drawH = (self.w or 0)*scaleMult, (self.h or 0)*scaleMult
  if self.hidden == true then self.drawW = 0 end
      
  if self.l ~= nil then self.drawX = self.l[1](self,'left') end
  if self.t ~= nil then self.drawY = self.t[1](self,'top') end
  if self.r ~= nil then self.drawW = self.r[1](self,'right') end
  if self.b ~= nil then self.drawH = self.b[1](self,'bottom') end
  if self.minW ~= nil and self.drawW < self.minW then self.drawW = self.minW end
  if self.minH ~= nil and self.drawH < self.minH then self.drawH = self.minH end

  if self.img and self.hidden ~= true then 
    self.drawImg = scaleToDrawImg(self) -- adds _150 or _200 to name
    if self.imgIdx == nil then self.imgIdx = getImage(self.drawImg) end
    self.measuredImgW, self.measuredImgH = gfx.getimgdim(self.imgIdx)
    local pinkAdjustedImgW, pinkAdjustedImgH = self.measuredImgW, self.measuredImgH
    if bufferPinkValues[self.imgIdx] then pinkAdjustedImgW, pinkAdjustedImgH = self.measuredImgW-2, self.measuredImgH-2 end

    if self.iType ~= nil then
      if self.iType == 3 then 
        if self.w==nil then self.drawW = pinkAdjustedImgW/3 end
        if self.h==nil then self.drawH = pinkAdjustedImgH end
      elseif self.iType == 'stack' then 
        self.drawW, self.drawH = self.measuredImgW, self.measuredImgW
      else -- any other iType
        if self.w==nil then self.drawW = pinkAdjustedImgW end
        if self.h==nil then self.drawH = pinkAdjustedImgH end 
      end
    end

  end 
  
  local b = self.border or 0
  if self.flow then
    if self.flow == true then self.flow = getPreviousEl(self) or nil end -- auto set previous child as flow element
    if type(self.flow) == 'table' then
      --reaper.ShowConsoleMsg('px:'..px..'   pw:'..pw..'   self.flow.drawX:'..self.flow.drawX..'  self.flow.drawW:'..self.flow.drawW..'\n')
      local fx, fy = self.flow.drawX + self.flow.drawW + (self.x*scaleMult or 0) + b, self.flow.drawY
      if fx + b + self.drawW > px+pw then -- then flow to next row
        fx = (self.x*scaleMult or 0) + px + b
        fy = self.flow.drawY + self.flow.drawH + (self.y*scaleMult or 0) + b
      end
      self.drawX, self.drawY = fx, fy
      
    end 
  end
 
  resizeParent(self) -- checks if el has a resizeParent set, and if so does that
  
  if self.elAlign then
  
    if self.elAlign.x then
      local target = self.elAlign.x[1]
      if self.elAlign.x[1]=='parent' then target = self.parent end
      tx,tw = target.drawX or target.x, target.drawW or target.w
      if self.elAlign.x[2]=='centre' then self.drawX = tx+(tw/2)-(self.drawW/2)+ (self.x*scaleMult) end 
      if self.elAlign.x[2]=='right' then self.drawX = tx + tw - self.drawW + (self.x*scaleMult) end
    end
    
    if self.elAlign.y then
      local target = self.elAlign.y[1]
      if self.elAlign.y[1]=='parent' then target = self.parent end
      ty,th = target.drawY or target.y, target.drawH or target.h
      if self.elAlign.y[2]=='centre' then self.drawY = ty+(th/2)-(self.drawH/2)+self.y end
      if self.elAlign.y[2]=='bottom' then reaper.ShowConsoleMsg('element align bottom not done yet\n') end
    end

  end
  
  --check final position, cull if outside parent
  if self.drawX > px+pw then -- fully to the right of parent
    self.drawW = 0 -- using zero width (instead of some kind of 'don't draw' state) so that dirtyCheck notices
  end
  
  --every element has a block, and if you go past the bottom of it then that block will need a scrollbar
  if (self.drawY + self.drawH) > (els[self.block].y + els[self.block].h) and self.drawH > 0 and self.hidden ~= true and self.scrollbarToFit ~= false then
    if els[self.block].scrollableH then
      if (self.drawY + self.drawH) > els[self.block].scrollableH then
        els[self.block].scrollableH = (self.drawY + self.drawH)
      end
    else
      els[self.block].scrollableH = (self.drawY + self.drawH)
    end
  end
  
  return true
end




  --------- DRAW ----------
function El:draw(z,offsX,offsY)
  gfx.a = 1 -- reset that
  gfx.dest = (z or 1) -- won't this always be the temp buffer (9)?
  local x,y,w,h = self.drawX or self.x or 0, self.drawY or self.y or 0, self.drawW or self.w or 0, self.drawH or self.h or 0
  x, y = x-offsX, y-offsY
  local col = self.drawCol or self.col or nil
  if col ~= nil and self.hidden ~= true then -- fill
    setCol(col)
    if self.shape ~= nil then
      if self.shape == 'circle' then gfx.circle(x+w/2,y+w/2,w/2,1,1) end
    else gfx.rect(x,y,w,h)
    end
  end
  if self.strokeCol ~= nil and self.hidden ~= true then -- stroke
    local c = fromRgbCol(self.strokeCol)
      gfx.set(c[1],c[2],c[3],c[4])
      if self.shape ~= nil then reaper.ShowConsoleMsg('non-rectangular strokes not done yet in El:draw\n') 
      else 
        gfx.line(x,y+h,x,y,0)
        gfx.line(x+1,y,x+w,y,0)
        gfx.line(x+w,y+1,x+w,y+h)
        gfx.line(x+1,y+h,x+w-1,y+h)
      end
  end
  if self.text ~= nil and self.hidden ~= true then
    if self.text.val ~=nil then self.text.str = self.text.val() end
    local p = self.text.padding or textPadding
    local tx,tw = x + p, w - 2*p
    local style = (self.text.style + textScaleOffs) or 1
    local thisBaselineShift = baselineShift[style] or 0
    text(self.text.str,tx,y+thisBaselineShift,tw,h,self.text.align,self.text.col,style,self.text.lineSpacing,self.text.vCenter,self.text.wrap)
  end
 
  if self.drawImg ~= nil and self.hidden ~= true then
 
    local pinkXY, pinkWH, imgW, imgH = 0,0,self.measuredImgW, self.measuredImgH
    if bufferPinkValues[self.imgIdx] then 
      pinkXY, pinkWH, imgW, imgH = 1, 2, self.measuredImgW-2, self.measuredImgH-2
    end

    gfx.a = (self.img.a or 255) / 255
    if self.iType == 'stack' then 
      local iFrameHScaled = self.iFrameH * scaleMult  
      if self.iFrameC == nil then self.iFrameC = self.measuredImgH / iFrameHScaled end
      local frame = (self.iFrame or 0) * self.measuredImgW 
      gfx.blit(self.imgIdx, 1, 0, 0, frame, self.measuredImgW, self.measuredImgW, x, y, w, self.measuredImgW)
      
    elseif self.iType == 3 then -- a 3 frame button
      local frameW = imgW/3
      if w==0 then w=frameW end
      if h==0 then h=imgH end
      
      if bufferPinkValues[self.imgIdx] then
        if frameW==w  and imgH==h  then --if this image is going to drawn at size, just draw it.
          gfx.blit(self.imgIdx, 1, 0, (self.iFrame or 0)*frameW +pinkXY, pinkXY, w, h, x, y, w, h)
        else
          local tx, ly, bx,ry = bufferPinkValues[self.imgIdx].tx, bufferPinkValues[self.imgIdx].ly, bufferPinkValues[self.imgIdx].bx, bufferPinkValues[self.imgIdx].ry
          local unstretchedC2W, unstretchedR2H = frameW+2 -tx -bx, imgH+2 -ly -ry    --frameW rather than imgH in this case, because it is a 3 state image
          local stretchedC2W, stretchedR2H = w -tx -bx +2, h -ly -ry +2
          pinkBlit(self.imgIdx, ((self.iFrame or 0)*frameW), 0, x, y, tx, ly, bx, ry, unstretchedC2W, unstretchedR2H, stretchedC2W, stretchedR2H)
        end
      else --3 frame button with no pink
        gfx.blit(self.imgIdx, 1, 0, (self.iFrame or 0)*frameW, 0, w, h, x, y, w, h)
      end
      
    elseif self.iType ~= nil then
      if bufferPinkValues[self.imgIdx] then
        if imgW==w  and imgH==h  then --if this image is going to drawn at size, just draw it.
          gfx.blit(self.imgIdx, 1, 0, (self.iFrame or 0)*w +pinkXY, pinkXY, w, h, x, y, w, h)
        else --draw the image using pink stretching.
          local tx, ly, bx,ry = bufferPinkValues[self.imgIdx].tx, bufferPinkValues[self.imgIdx].ly, bufferPinkValues[self.imgIdx].bx, bufferPinkValues[self.imgIdx].ry
          pinkBlit(self.imgIdx, 0, 0, x, y, tx, ly, bx, ry, self.measuredImgW-tx-bx, self.measuredImgH-ly-ry, w-tx-bx+pinkWH, h-ly-ry+pinkWH)
        end
      else --image with no pink
        gfx.blit(self.imgIdx, 1, 0, (self.iFrame or 0)*w, 0, w, h, x, y, w, h)
      end
    
    else 
      --gfx.blit(self.imgIdx, 1, 0, 0, 0, iDw, iDh, x, y, w, h) --not an image
      gfx.blit(self.imgIdx, 1, 0, 0, 0, self.measuredImgW, self.measuredImgH, x, y, w, h)
    end
    
  end
end



  --------- MOUSE ---------
  
function El:mouseOver()
  if self.mouseOverCol ~= nil then 
    self.drawCol = self.mouseOverCol
    self:addToDirtyZone()
  end
  if self.mouseOverCursor ~= nil then
    gfx.setcursor(429,1) -- hand
  end
  if self.img ~= nil then
    if self.iType ~= nil and self.iType == 3 then
      self.iFrame = 1
      self:addToDirtyZone()
    end
  end
end

function El:showTooltip()
  if self.toolTip ~= nil then
    if addTimer(self,'toolTip',0.5) == true then
      if self.onTimerComplete == nil then self.onTimerComplete = {} end
      self.onTimerComplete.toolTip = function()
          local blah, windX, windY = gfx.dock(-1,0,0)
          reaper.TrackCtl_SetToolTip(self.toolTip, windX + gfx.mouse_x +(24*scaleMult), windY + gfx.mouse_y +(48*scaleMult),false)
        end
    end
  end
end

function El:mouseAway()
  if self.mouseOverCol ~= nil then 
    self.drawCol = self.col
    self:addToDirtyZone()
  end
  if self.mouseOverCursor ~= nil then
    gfx.setcursor(1,1)
  end
  if self.img ~= nil then
    if self.iType ~= nil and self.iType == 3 then
      self.iFrame = 0
      self:addToDirtyZone()
    end
  end
  reaper.TrackCtl_SetToolTip('',0,0,true)
  removeTimer(self,'toolTip')
end

function El:mouseDown()
  if self.img ~= nil then
    if self.iType ~= nil and self.iType == 3 then
      self.iFrame = 2
      self:addToDirtyZone()
    end
  end
  if self.onClick ~= nil and singleClick ~= true then
    singleClick = true
    self.onClick(self)
  end
  if self.onDrag then
    dX, dY = mouseDrag(self)
    self.onDrag(dX, dY)
  end
end

function mouseDrag(self)
  if dragStart == nil then dragStart = {x=gfx.mouse_x, y=gfx.mouse_y} end
  local dX, dY = gfx.mouse_x - dragStart.x, gfx.mouse_y - dragStart.y
  
  local ctrl = gfx.mouse_cap&4
  if ctrl == 4 then -- ctrl
    if dragStart.fine ~= true then
      dragStart = {x=dragStart.x+dX, y=dragStart.y+dY}
      dragStart.fine = true
    end
    dX, dY = (gfx.mouse_x - dragStart.x)*0.25, (gfx.mouse_y - dragStart.y)*0.25
  end
  return dX/scaleMult, dY/scaleMult --divide by scaleMult because all calculatoing are at 100%
end

function passToEl(self,...)
  --argsCheck = {...}
  self.El.action(self.El,...)
end

function El:doubleClick() 
  if self.onDoubleClick ~= nil then
    if type(self.onDoubleClick) == 'string' then
      if self.onDoubleClick == 'reset' then reaper.ShowConsoleMsg('do reset value\n') end
    else self.onDoubleClick(self)
    end
  end
end

function El:mouseWheel(wheel_amt)
  if self.onMouseWheel ~= nil then
    self.onMouseWheel(wheel_amt)
  end
end

function Knob:mouseWheel(wheel_amt)
  self.parent.paramV = self.parent.paramV + wheel_amt
  if self.parent.paramVMax and self.parent.paramVMin then
    if self.parent.paramV > self.parent.paramVMax then self.parent.paramV = self.parent.paramVMax end
    if self.parent.paramV < self.parent.paramVMin then self.parent.paramV = self.parent.paramVMin end
  end
  self.parent.doUpdate = true
  self:addToDirtyZone()
end

  --------- POPULATE ----------

indexParams()
--colDebug = true
--debugBuffers = true
setScale(1)
scaleFactor = 100
ScrollbarThickness = 20 * scaleMult

Block:new({x=0, y=0, w=160, h=800,
  onArrange = function()
    els[1].h = gfx.h
  end
  })

sidebarBox = El:new({block=1, z=1, x=0, y=0, w=160, h=800, col={50,50,50}, interactive=false,
  onGfxResize = function()
    sidebarBox.h = els[sidebarBox.block].drawH or els[sidebarBox.block].h
    sidebarBox:addToDirtyZone(bodyBox.z)
  end
  })
  
pageRadio = Control:new({parent=sidebarBox, x=0, y=0, flow=true, w=90, h=40, style='radio', col={}, controlType = '', 
        buttonOffStyle = {x=6, w=148, col={30,30,30}, mouseOverCol={40,40,40}, textCol={120,120,120}},
        buttonOnStyle = {x=12, w=154, col={80,80,80}, mouseOverCol={90,90,90}, textCol={200,200,200}},
        scriptAction = function(k)
          if k.value then
            activePage = k.value
            els[2].scrollableH = nil -- reset scrolled position of block 2 on page change. 
            els[2][1][2].y, els[2].scrollY = 0, 0 -- reset the actual scrollbar on page change. 
            bodyBox:onGfxResize()
            bodyScrollbar:addToDirtyZone()
          else
            if activePage == "" then activePage = 'TCP' end
            k.value = activePage
          end
        end
        })
 
Button:new({parent=pageRadio, x=6, y=6, w=148, h=40, flow=true, style='button', col={30,30,30}, controlType = 'radio', value = 'Global', 
  label = 'none', text={str='Global', style=2, align=5, col={150,150,150}}})         
         
Button:new({parent=pageRadio, x=6, y=6, w=148, h=40, flow=true, style='button', col={30,30,30}, controlType = 'radio', value = 'TCP', 
  label = 'none', text={str='Track Control Panels', style=2, align=5, col={150,150,150}}})  
  
Button:new({parent=pageRadio, x=6, y=6, w=148, h=40, flow=true, style='button', col={30,30,30}, controlType = 'radio', value = 'EnvCP', 
  label = 'none', text={str='Envelope Control Panels', style=2, align=5, col={150,150,150}}})   

Button:new({parent=pageRadio, x=6, y=6, w=148, h=40, flow=true, style='button', col={30,30,30}, controlType = 'radio', value = 'MCP', 
  label = 'none', text={str='Mixer Control Panels', style=2, align=5, col={150,150,150}}})
  
Button:new({parent=pageRadio, x=6, y=6, w=148, h=40, flow=true, style='button', col={30,30,30}, controlType = 'radio', value = 'Transport', 
  label = 'none', text={str='Transport', style=2, align=5, col={150,150,150}}})

  
  
  

Block:new({x=0, y=0, w=750, h=800,
  onArrange = function()
    els[2].h = gfx.h / scaleMult
    els[2].w = gfx.w / scaleMult  - ScrollbarThickness - els[1].w 
    bodyBox:onGfxResize() 
  end})

  
bodyBox = El:new({block=2, z=1, x=0, y=0, h=100, col={35,35,35}, interactive=false, scrollbarToFit=false,
  text={str='bodyBox', style=2, align=10, col={150,150,150}},
  onGfxResize = function()
    bodyBox.w = els[bodyBox.block].w
    bodyBox.h =  els[bodyBox.block].h
    bodyBox:addToDirtyZone(bodyBox.block, bodyBox.z)
    bodyBox.text.str='bodyBox: w:'..bodyBox.w..'  h:'..bodyBox.h..'      gfx w:'..gfx.w..'  gfx h:'..gfx.h
  end
  })
  
Block:new({x=0, y=0, w=20, h=800,
  onArrange = function()
    els[3].h = gfx.h
  end})
  
bodyScrollbar = ScrollbarV:new({block=3, z=1, x=0, y=0, scrollbarOfBlock=2,
    onGfxResize = function()
      bodyScrollbar.h = gfx.h
      bodyScrollbar:addToDirtyZone(bodyScrollbar.z)
    end
  })

        
      
      
      
      
belongsToPage = 'Global' 

globalBox = El:new({parent=bodyBox, x=10, y=10, w=200, h=352, col={120,120,255,50} })
Control:new({parent=globalBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Custom Color Track Labels'})
Control:new({parent=globalBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Selection Invert Labels'})
Control:new({parent=globalBox, x=10, y=10, w=180, h=36, col={50,50,50}, flow=true, style='fader', paramDesc = 'Text Brightness', units = '%'})
Control:new({parent=globalBox, x=10, y=10, w=180, h=36, col={50,50,50}, flow=true, style='fader', paramDesc = 'Custom Color Strength', units = '%'})
Control:new({parent=globalBox, x=10, y=10, w=180, h=36, col={50,50,50}, flow=true, style='fader', paramDesc = 'Selection Overlay Strength', units = '%'})

resetBox = El:new({parent=globalBox, x=10, y=40, w=180, h=40, flow = true, col={100,0, 0,255} ,
        buttonOffStyle = {col={150,30,30}, mouseOverCol={255,0,0}, textCol={255,255,255}},
        scriptAction = function(k)
          if reaper.MB('Reset all theme adjuster settings to default?', 'RESET THEME ADJUSTER', 1) == 1 then
            local i=0
            while reaper.ThemeLayout_GetParameter(i) ~= nil do
              local tmp,tmp,tmp, def = reaper.ThemeLayout_GetParameter(i)
                reaper.ThemeLayout_SetParameter(i, def, true)
              i = i+1
            end
            ThemeLayout_RefreshAll = true
          end
          
          for b in ipairs(els) do -- iterate blocks
            for z in ipairs(els[b]) do -- iterate z
              if els[b][z] ~= nil then
                for j,k in pairs(els[b][z]) do
                  k.paramV = nil
                  k.doUpdate = true
                end
              end
            end
          end
          
        end
        })
Button:new({parent=resetBox, x=20, y=10, h=20, flow=true, style='button', controlType = '', label = 'none', text={str='RESET THEME ADJUSTER'} })

colControlsBox = El:new({parent=bodyBox, x=10, y=10, w=300, h=352, flow = true, col={100,140,100,50} })
El:new({parent=colControlsBox, x=0, y=0, w=300, h=20, col={120,180,120}, text={str='Color Controls', style=2, align=4, col={255,255,255}} }) 

Control:new({parent=colControlsBox, x=10, y=10, w=280, h=36, col={50,50,50}, flow=true, style='fader', remapToMin = 25, remapToMax = 200,
        param = -1000, desc = 'Gamma', units = 'γ'}) -- gamma should actually go from 0.25 to 2
        
Control:new({parent=colControlsBox, x=10, y=10, w=280, h=36, col={50,50,50}, flow=true, style='fader', remapToMin = -100, remapToMax = 100,
        param = -1003, desc = 'Highlights', units = ''}) 
        
Control:new({parent=colControlsBox, x=10, y=10, w=280, h=36, col={50,50,50}, flow=true, style='fader', remapToMin = -100, remapToMax = 100,
        param = -1002, desc = 'Midtones', units = ''})
        
Control:new({parent=colControlsBox, x=10, y=10, w=280, h=36, col={50,50,50}, flow=true, style='fader', remapToMin = -100, remapToMax = 100,
        param = -1001, desc = 'Shadows', units = ''})        
        
Control:new({parent=colControlsBox, x=10, y=10, w=280, h=36, col={50,50,50}, flow=true, style='fader', remapToMin = 0, remapToMax = 200,
        param = -1004, desc = 'Saturation', units = '%'})
        
Control:new({parent=colControlsBox, x=10, y=10, w=280, h=36, col={50,50,50}, flow=true, style='fader', remapToMin = -180, remapToMax = 180,
        param = -1005, desc = 'Tint', units = '°'})
        
Control:new({parent=colControlsBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', controlType = '', labelStr = 'Reset all color controls', 
      toolTip='attn: Dan Worrall', 
        scriptAction = function(k)
          for i=-1005,-1000,1 do
            local tmp,tmp,tmp,d = reaper.ThemeLayout_GetParameter(i)
            reaper.ThemeLayout_SetParameter(i, d, i == -1000)
          end
          doReaperGet = true
        end
        })       
      
      
debugBox = El:new({parent=bodyBox, x=10, y=10, w=150, h=352, flow = true, col={140,120,100,50} })
El:new({parent=debugBox, x=0, y=0, w=0, r={toEdge, debugBox, 'right'}, h=20, col={255,180,120}, text={str='Debugging', style=2, align=4, col={200,50,0}} }) 
Control:new({parent=debugBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Visualise sections'}) 
resetBox = El:new({parent=debugBox, x=10, y=10, w=130, h=40, flow = true, col={0, 100, 0,255} ,
        buttonOffStyle = {col={30,150,30}, mouseOverCol={0,255,0}, textCol={255,255,255}},
        scriptAction = function(k) reaper.ThemeLayout_RefreshAll() end
        })
Button:new({parent=resetBox, x=15, y=10, h=20, flow=true, style='button', controlType = '', label = 'none', text={str='REFRESH THEME'} })
El:new({parent=debugBox, flow = true, x=6, w=148, y=10, h=16, col={0,0,0,0}, text={str='OS : '..OS, style=2, align=0, col={200,200,200}} }) 
DPIdisplay = El:new({parent=debugBox, flow = true, x=6, w=148, y=10, h=16, toolTip='Display Scale', col={0,0,0,0},
  text={str='', style=2, align=0, col={200,200,200}},
  onDpiChange = function() 
    DPIdisplay.text.str = 'Display scale : '..math.floor(100*gfx.ext_retina)..'%'
    DPIdisplay:addToDirtyZone(DPIdisplay.z)
  end,
  onArrange = function(k)
    k:addToDirtyZone()
  end
  })
  
  --[[
size1 = El:new({parent=debugBox, flow = true, x=6, w=130, y=10, h=13, col={0,0,0}, text={str='SIZE 1', style=1, align=4, col={255,255,255}} }) 
El:new({parent=size1, x=6, w=26, y=3, h=7, col={255,0,0,130} })  
size2 = El:new({parent=debugBox, flow = true, x=6, w=130, y=10, h=15, col={0,0,0}, text={str='SIZE 2', style=2, align=4, col={255,255,255}} })
El:new({parent=size2, x=7, w=30, y=4, h=8, col={255,0,0,130} }) 
size3 = El:new({parent=debugBox, flow = true, x=6, w=130, y=10, h=22, col={0,0,0}, text={str='SIZE 3', style=3, align=4, col={255,255,255}} })
El:new({parent=size3, x=7, w=42, y=6, h=11, col={255,0,0,130} }) 
size4 = El:new({parent=debugBox, flow = true, x=6, w=130, y=10, h=50, col={0,0,0}, text={str='SIZE 4', style=4, align=4, col={255,255,255}} })
El:new({parent=size4, x=8, w=95, y=13, h=26, col={255,0,0,130} }) ]]
      
      
belongsToPage = 'TCP' 

tcpAllLayoutsBox = El:new({parent=bodyBox, x=10, y=10, w=500, h=250, col={80,80,130} })    
El:new({parent=tcpAllLayoutsBox, x=0, y=0, w=0, r={toEdge, tcpAllLayoutsBox, 'right'}, h=20, col={30,30,100}, text={str='All Layouts', style=2, align=4, col={255,255,255}} }) 

Control:new({parent=tcpAllLayoutsBox, x=10, y=10, w=140, flow=true, style='colour', paramDesc = 'TCP background colour'})
Control:new({parent=tcpAllLayoutsBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'Section Margins', units = 'px'})
Control:new({parent=tcpAllLayoutsBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'X-Axis spacing', units = 'px'})
Control:new({parent=tcpAllLayoutsBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'Y-Axis spacing', units = 'px'})      
Control:new({parent=tcpAllLayoutsBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'TCP Div Opacity', labelStr = 'Divider Opacity', units = '%',  remapToMin = 0, remapToMax = 100,})
Control:new({parent=tcpAllLayoutsBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'TCP Folder Indent', labelStr = 'Folder Indent', units = '',})
Control:new({parent=tcpAllLayoutsBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Empty TCP Section Opacity', labelStr = 'Empty Sec Opacity', units = '%',  remapToMin = 0, remapToMax = 100,})         
Control:new({parent=tcpAllLayoutsBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'TCP Folder Balance Type', units = '', 
        labelStr = 'Folder Balance Type', paramTitles = {'none', 'Stretch Name', 'All'}})

        
tcpOrderBox=El:new({parent=tcpAllLayoutsBox, flow=true, x=10, y=20, w=-10, r={toEdge, tcpAllLayoutsBox, 'right'}, h=60, col={125,137,137} })  

tcpOrderControl = El:new({parent=tcpOrderBox, x=10, y=10, w=460, h=40,
  onUpdate = function(k)

    local p1 = paramIdxGet('TCP flow location 1')
    
    if k.paramV == nil then -- first time populate paramV table with values from Reaper
      k.paramV = {}
      for i=1, 10 do -- iterate flow elements
        local tmp, tmp, value = reaper.ThemeLayout_GetParameter(p1 -1 +i)
        --reaper.ShowConsoleMsg('element '..i..' is at location '..value..' \n')
        k.paramV[i] = value
      end
    else
      -- else we're here because a button was pressed. Send all the values to Reaper.
      for i=1, 10 do -- iterate flow elements
        paramSet(p1 -1 +i, k.paramV[i])
      end
    end
    
    local widths = {72, 40, 39, 30, 36, 42, 42, 56, 40, 16}
    local names = {'labelBlock','volLabel','MSBlock','io','FxBlock','PanBlock','recmode','inputBlock','env','phase'} --only used in console
    local xMargin = 5
    for i=1, 10 do -- iterate my children 1-10, the position proxies, and fix their widths and x-positions
      k.children[i].w = widths[k.paramV[i]]
      if i>1 then k.children[i].x = k.children[i-1].x + k.children[i-1].w + xMargin end
    end
    
    for i=2, 10 do -- iterate my children 11-19, the swap buttons, x-positioning them
      k.children[i+9].x = k.children[i].x - 10 - math.floor(0.5*xMargin)
    end
    
    for i=1, 10 do -- iterate my children 20-29, the display elements, positioning each to the appropriate proxy
      k.children[k.paramV[i]+19].x = k.children[i].x
      --reaper.ShowConsoleMsg('element '..i..' '..names[k.paramV[i]]..' is at location '..i..' \n')
      k.children[i+19].doUpdate = true
    end
    
    tcpOrderControl.doUpdate = false

  end
})

-- 10 position proxies for 10 slots
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=20 }) 
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=20 }) 
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=20 }) 
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=20 }) 
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=20 }) 
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=20 }) 
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=20 }) 
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=20 }) 
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=20 }) 
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=20 }) 

Button:new({parent=tcpOrderControl, x=0, y=20, h=24, img='swap', controlType='tcpOrderSwap', params={1,2}}) 
Button:new({parent=tcpOrderControl, x=0, y=20, h=24, img='swap', controlType='tcpOrderSwap', params={2,3}}) 
Button:new({parent=tcpOrderControl, x=0, y=20, h=24, img='swap', controlType='tcpOrderSwap', params={3,4}}) 
Button:new({parent=tcpOrderControl, x=0, y=20, h=24, img='swap', controlType='tcpOrderSwap', params={4,5}}) 
Button:new({parent=tcpOrderControl, x=0, y=20, h=24, img='swap', controlType='tcpOrderSwap', params={5,6}}) 
Button:new({parent=tcpOrderControl, x=0, y=20, h=24, img='swap', controlType='tcpOrderSwap', params={6,7}}) 
Button:new({parent=tcpOrderControl, x=0, y=20, h=24, img='swap', controlType='tcpOrderSwap', params={7,8}}) 
Button:new({parent=tcpOrderControl, x=0, y=20, h=24, img='swap', controlType='tcpOrderSwap', params={8,9}}) 
Button:new({parent=tcpOrderControl, x=0, y=20, h=24, img='swap', controlType='tcpOrderSwap', params={9,10}}) 

tcpLabelBlock = El:new({parent=tcpOrderControl, x=0, y=0, w=72, h=22, interactive=false })
El:new({parent=tcpLabelBlock, x=0, y=-1, w=24, h=24, img='tcp_recarm', interactive=false })
El:new({parent=tcpLabelBlock, x=24, y=-1, w=24, h=24, col={38,38,38}, interactive=false })
El:new({parent=tcpLabelBlock, x=48, y=-1, w=24, h=24, img='tcp_vol', interactive=false }) 
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=22, text={str='0.0dB', align=4, style=1} })
El:new({parent=tcpOrderControl, x=0, y=0, w=39, h=22, img='tcp_mutesolo', interactive=false })
El:new({parent=tcpOrderControl, x=0, y=0, w=30, h=22, img='tcp_io', interactive=false })
El:new({parent=tcpOrderControl, x=0, y=0, w=36, h=22, img='tcp_fx', interactive=false })
El:new({parent=tcpOrderControl, x=0, y=0, w=42, h=22, img='tcp_panwidth', interactive=false })
El:new({parent=tcpOrderControl, x=0, y=0, w=42, h=22, img='tcp_recmode', interactive=false })
tcpInputBlock = El:new({parent=tcpOrderControl, x=0, y=0, w=56, h=22, interactive=false })
El:new({parent=tcpInputBlock, x=0, y=0, w=20, h=22, img='tcp_infx', interactive=false })
El:new({parent=tcpInputBlock, x=20, y=0, w=10, h=20, col={0,0,0,64}, interactive=false })
El:new({parent=tcpInputBlock, x=30, y=0, w=26, h=22, img='tcp_recinput', interactive=false })
El:new({parent=tcpOrderControl, x=0, y=0, w=40, h=22, img='tcp_env', interactive=false })
El:new({parent=tcpOrderControl, x=0, y=0, w=16, h=22, img='tcp_phase', interactive=false })







        
tcpLayoutChooseBox = El:new({parent=bodyBox, x=10, y=10, w=100, h=250, flow=true, col={50,50,50} })        
El:new({parent=tcpLayoutChooseBox, x=10, y=0, w=80, h=40,  text={str='LAYOUT', style=3, align=5, col={150,150,150}} })

tcpLayoutRadio = Control:new({parent=tcpLayoutChooseBox, x=10, y=0, flow=true, w=80, h=100, style='radio', col={50,50,50}, controlType = 'layoutRadio', 
        scriptAction = function(k)
          if k.value and activeLayout ~= k.value then
            activeLayout = k.value
            updateAnyNotHidden=true
          else
            k.value = activeLayout or 'A'
            k.doUpdate = true
          end
          tcpSecManager.layoutChanged = true
        end 
        })
         
Button:new({parent=tcpLayoutRadio, x=0, y=10, w=20, h=20, flow=true, style='button', img='button_layout_A_off', controlType = 'radio', value = 'A', label = 'none'})
Button:new({parent=tcpLayoutRadio, x=10, y=10, w=20, h=20, flow=true, style='button', img='button_layout_B_off', controlType = 'radio', value = 'B', label = 'none'})
Button:new({parent=tcpLayoutRadio, x=10, y=10, w=20, h=20, flow=true, style='button', img='button_layout_C_off', controlType = 'radio', value = 'C', label = 'none'}) 



tcpBox = El:new({parent=bodyBox, x=10, y=10, w=280, h=250, flow = true, col={120,255,120} })        
  
        
Control:new({parent=tcpBox, x=10, y=10, w=100, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Left Section Width', units = 'px'})
Control:new({parent=tcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Right Section Width', units = 'px'})
Control:new({parent=tcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'FX Parameters Width', units = 'px', labelStr='FX Params width'})
Control:new({parent=tcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'FX Parameters Pin', labelStr='Pin FX Params'})          
Control:new({parent=tcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'FX Minimum Width', units = 'px', labelStr='FX Min width'})
Control:new({parent=tcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'FX Maximum Width', units = 'px', labelStr='FX Max width'})
Control:new({parent=tcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'FX List Pin', labelStr='Pin FX Inserts'})          
Control:new({parent=tcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Send Maximum Width', units = 'px', labelStr='Send Max width'})
Control:new({parent=tcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Send List Pin', labelStr='Pin Sends'})  
Control:new({parent=tcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Embedded FX Pin', labelStr='Pin Embedded UI'}) 
Control:new({parent=tcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'TCP Meter Width', units = 'px', labelStr='Meter width'})
Control:new({parent=tcpBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'TCP Meter Border', units = 'px', labelStr='Meter Border'})        
Control:new({parent=tcpBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'TCP Label Font Size', units = 'px', labelStr='Label Font Size'})
Control:new({parent=tcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'TCP Label Length', units = 'px', labelStr='Label Length'})
Control:new({parent=tcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'TCP Volume Length', units = 'px', labelStr='Volume Length'})        
Control:new({parent=tcpBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'TCP Input Font Size', units = 'px', labelStr='Input Font Size'})
Control:new({parent=tcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'TCP Input Length', units = 'px', labelStr='Input Length'})
        
        
tcpSecManager = Control:new({parent=bodyBox, x=10, y=10, w=320, h=276, col={200,150,255}, flow=true, controlType = 'tcpSecManager', units = '', 
  
        scriptAction = function(k)
          --reaper.ClearConsole()
          
          if tcpParamsSecRadio.value == nil or k.layoutChanged == true then -- then fill for the first time, or for new layout
            
            local getParams = {'FX Parameters Section', 'Send List Section', 'FX List Section', 'Embedded FX Section', 'tcpFxparmVisflag1', 'tcpFxparmVisflag2'}
            local gotParam = {}
            for l,m in pairs(getParams) do
              local tmp, tmp, value = reaper.ThemeLayout_GetParameter(paramIdxGet(m))
              --reaper.ShowConsoleMsg('v = '..value..'\n')
              gotParam[l] = value
            end
            
            -- translate gotParams (exact sections plus fxparms) into script button settings (section 1 to 3, or 0 for none)
            --if k.lastVals == nil then k.lastVals = {} end
            tcpParamsSecRadio.value = math.ceil((gotParam[1])/3) -- FX Parameters always go where set
            tcpEmbeddedUISecRadio.value = math.ceil((gotParam[4])/3) -- Embedded FX always go where set
            if gotParam[2] == 0 and gotParam[6] == 1 then-- sends are sharing with params
              tcpSendsSecRadio.value = tcpParamsSecRadio.value
            else tcpSendsSecRadio.value = math.ceil((gotParam[2])/3)
            end
            if gotParam[3] == 0 and gotParam[5] == 1 then -- inserts are sharing with params
              tcpInsertsSecRadio.value = tcpParamsSecRadio.value
            else tcpInsertsSecRadio.value = math.ceil((gotParam[3])/3)
            end
            k.layoutChanged = nil
            
            --zero tcpSendsSecRadio.value and/or tcpInsertsSecRadio.value if disabled by preference
            if reaper.GetToggleCommandState(40302)==0 then tcpInsertsSecRadio.value = 0 end --Options: Show FX inserts in TCP (when size permits) 40302 
            if reaper.GetToggleCommandState(40677)==0 then tcpSendsSecRadio.value = 0 end --Options: Show sends in TCP (when size permits)  40677
            
          end
          
          
          local sectionCount = {}
          --local sectionName = {'LEFT', 'BOTTOM', 'RIGHT'} -- only used to help console message readability
          local visFlags = {-1, -1, -1}
          -- the children of the tcpSecManager are the tcp*SecRadio controls. Skip even children, they're title boxes
          
          if k.children[2].value and k.children[2].value>0 then    -- do params section first, its special  
            --reaper.ShowConsoleMsg('SET Params to '..sectionName[k.children[2].value]..' \n')
            sectionCount[k.children[2].value] = {'Params'}
            paramSet(paramIdxGet(k.children[2].paramDesc), k.children[2].value*3 -2)
          else 
            --reaper.ShowConsoleMsg('SET Params to --off-- \n')  
            paramSet(paramIdxGet(k.children[2].paramDesc), 0)
          end
            
          for i=4,8,2 do
            local p = paramIdxGet(k.children[i].paramDesc)
            --reaper.ShowConsoleMsg(k.children[i].paramDesc..' paramIdx is '..p..'\n') 
            if k.children[i].value and k.children[2].value and k.children[2].value>0 and k.children[i].value == k.children[2].value then 
              --reaper.ShowConsoleMsg(k.children[i].section..' on same as Params ('..(sectionName[k.children[2].value])..') \n')
              
              if i==8 then -- embedded UI in same location as params
                --reaper.ShowConsoleMsg('>>> EMBEDDED SHARING WITH PARAMS <<<\n')
                --reaper.ShowConsoleMsg('SET Embedded to '..(sectionName[k.children[i].value])..' \n')
                table.insert(sectionCount[k.children[8].value], k.children[8].section);
                paramSet(paramIdxGet(k.children[8].paramDesc), k.children[8].value*3 -3 + #sectionCount[k.children[8].value])
              else
                --reaper.ShowConsoleMsg('  --> so SET '..k.children[i].section..' to --off-- \n')
                paramSet(p, 0)
                --reaper.ShowConsoleMsg('  --> also SET visflags to SHOW '..k.children[i].section..' \n')
                if k.children[i].visFlag then 
                  --reaper.ShowConsoleMsg('  ----> okay SET visFlag'..k.children[i].visFlag..' to 1 \n') 
                  visFlags[k.children[i].visFlag] = 1
                end
              end
              
            else
              if k.children[i].value and k.children[i].value>0 then
                --reaper.ShowConsoleMsg('SET '..k.children[i].section..' to '..(sectionName[k.children[i].value])..' \n')
                if sectionCount[k.children[i].value] then table.insert(sectionCount[k.children[i].value], k.children[i].section);
                else sectionCount[k.children[i].value] = {k.children[i].section}
                end
                paramSet(p, k.children[i].value*3 -3 + #sectionCount[k.children[i].value])
                --reaper.ShowConsoleMsg('  --> also SET visflags to HIDE '..k.children[i].section..' \n')
              else
                --reaper.ShowConsoleMsg('SET '..k.children[i].section..' to --off-- \n')
                paramSet(p, 0)
                --reaper.ShowConsoleMsg('  ... and SET visflags to HIDE '..k.children[i].section..' \n')
              end
            end
          end
        
        local bottomSectionDiv = 1
        if sectionCount[2] and #sectionCount[2]>1 then bottomSectionDiv = #sectionCount[2] end
        --reaper.ShowConsoleMsg('finally, SET bottom section division to '..bottomSectionDiv..' \n') 
        paramSet(paramIdxGet('tcpSectionBottomDiv'), bottomSectionDiv)
        paramSet(paramIdxGet('tcpFxparmVisflag1'), visFlags[1])
        paramSet(paramIdxGet('tcpFxparmVisflag2'), visFlags[2])
        end ,
        })        
 
El:new({parent=tcpSecManager, x=10, y=10, w=150, h=16, flow=true, col = {255,255,0}, text={str='FX Parameters', style=2, align=4, col={0,0,0}} })
tcpParamsSecRadio = Control:new({parent=tcpSecManager, x=10, y=0, flow=true, w=300, h=40, style='radio', controlType = 'tcpSec', section='Params', col={70,70,70}, allOffValue=0, 
        paramDesc = 'FX Parameters Section', 
        buttonOffStyle = {col={30,30,30}, mouseOverCol={45,45,45}, textCol={120,120,120}},
        buttonOnStyle = {col={120,120,120}, mouseOverCol={140,140,140}, textCol={210,210,210}}
        })    
Button:new({parent=tcpParamsSecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 1, label = 'none', text={str='Left Section'} })
Button:new({parent=tcpParamsSecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 2, label = 'none', text={str='Bottom Section'} })
Button:new({parent=tcpParamsSecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 3, label = 'none', text={str='Right Section'} })

El:new({parent=tcpSecManager, x=10, y=10, w=150, h=16, flow=true, col = {255,255,0}, text={str='FX Inserts', style=2, align=4, col={0,0,0}} })
tcpInsertsSecRadio = Control:new({parent=tcpSecManager, x=10, y=0, flow=true, w=300, h=40, style='radio', controlType = 'tcpSec', section='Inserts', col={70,70,70}, allOffValue=0, 
        paramDesc = 'FX List Section', visFlag = 1,
        buttonOffStyle = {col={30,30,30}, mouseOverCol={45,45,45}, textCol={120,120,120}},
        buttonOnStyle = {col={120,120,120}, mouseOverCol={140,140,140}, textCol={210,210,210}}, 
        doOnEnable = function()
          if reaper.GetToggleCommandState(40302)==0 then reaper.Main_OnCommand(40302,0) end 
        end })
        
Button:new({parent=tcpInsertsSecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 1, label = 'none', text={str='Left Section'} })
Button:new({parent=tcpInsertsSecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 2, label = 'none', text={str='Bottom Section'} })
Button:new({parent=tcpInsertsSecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 3, label = 'none', text={str='Right Section'} })

El:new({parent=tcpSecManager, x=10, y=10, w=150, h=16, flow=true, col = {255,255,0}, text={str='Sends', style=2, align=4, col={0,0,0}} })
tcpSendsSecRadio = Control:new({parent=tcpSecManager, x=10, y=0, flow=true, w=300, h=40, style='radio', controlType = 'tcpSec', section='Sends', col={70,70,70}, allOffValue=0, 
        paramDesc = 'Send List Section', visFlag = 2,
        buttonOffStyle = {col={30,30,30}, mouseOverCol={45,45,45}, textCol={120,120,120}},
        buttonOnStyle = {col={120,120,120}, mouseOverCol={140,140,140}, textCol={210,210,210}}, 
        doOnEnable = function()
          if reaper.GetToggleCommandState(40677)==0 then reaper.Main_OnCommand(40677,0) end 
        end })    
Button:new({parent=tcpSendsSecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 1, label = 'none', text={str='Left Section'} })
Button:new({parent=tcpSendsSecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 2, label = 'none', text={str='Bottom Section'} })
Button:new({parent=tcpSendsSecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 3, label = 'none', text={str='Right Section'} })

El:new({parent=tcpSecManager, x=10, y=10, w=150, h=16, flow=true, col = {255,255,0}, text={str='Embedded UI', style=2, align=4, col={0,0,0}} })
tcpEmbeddedUISecRadio = Control:new({parent=tcpSecManager, x=10, y=0, flow=true, w=300, h=40, style='radio', controlType = 'tcpSec', section='EmbeddedUI', col={70,70,70}, allOffValue=0, 
        paramDesc = 'Embedded FX Section', visFlag = 3,
        buttonOffStyle = {col={30,30,30}, mouseOverCol={45,45,45}, textCol={120,120,120}},
        buttonOnStyle = {col={120,120,120}, mouseOverCol={140,140,140}, textCol={210,210,210}} })    
Button:new({parent=tcpEmbeddedUISecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 1, label = 'none', text={str='Left Section'} })
Button:new({parent=tcpEmbeddedUISecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 2, label = 'none', text={str='Bottom Section'} })
Button:new({parent=tcpEmbeddedUISecRadio, x=10, y=10, h=20, flow=true, style='button', controlType = 'radio', value = 3, label = 'none', text={str='Right Section'} })





tcpVisflagTableBox = El:new({parent=bodyBox, x=10, y=10, w=340, h=276, flow = true, col={100,50,100} })

El:new({parent=tcpVisflagTableBox, x=90, y=10, w=58, h=30, style='radio', col={30,30,30}, text={style=1, align=5, str='if Mixer Visible', wrap=true} })
El:new({parent=tcpVisflagTableBox, x=2, y=10, w=58, h=30, flow=true, style='radio', col={30,30,30}, text={style=1, align=5, str='if not selected', wrap=true} })
El:new({parent=tcpVisflagTableBox, x=2, y=10, w=58, h=30, flow=true, style='radio', col={30,30,30}, text={style=1, align=5, str='if not armed', wrap=true} })
El:new({parent=tcpVisflagTableBox, x=6, y=10, w=58, h=30, flow=true, style='radio', col={30,30,30}, text={style=1, align=5, str='ALWAYS', wrap=true} })

Control:new({parent=tcpVisflagTableBox, x=10, y=40, style='visFlagRow', paramDesc='Visflag Track Label Block', text={style=1, align=4, str='Label Block'} })
Control:new({parent=tcpVisflagTableBox, x=10, y=-2, flow=true, style='visFlagRow', paramDesc='Visflag Track Recmon', text={style=1, align=4, str='Rec Monitor'} })
Control:new({parent=tcpVisflagTableBox, x=10, y=-2, flow=true, style='visFlagRow', paramDesc='Visflag Track MS Block', text={style=1, align=4, str='Mute & Solo'} })
Control:new({parent=tcpVisflagTableBox, x=10, y=-2, flow=true, style='visFlagRow', paramDesc='Visflag Track Io', text={style=1, align=4, str='Routing'} })
Control:new({parent=tcpVisflagTableBox, x=10, y=-2, flow=true, style='visFlagRow', paramDesc='Visflag Track Fx Block', text={style=1, align=4, str='FX'} })
Control:new({parent=tcpVisflagTableBox, x=10, y=-2, flow=true, style='visFlagRow', paramDesc='Visflag Track Pan Block', text={style=1, align=4, str='Pan'} })
Control:new({parent=tcpVisflagTableBox, x=10, y=-2, flow=true, style='visFlagRow', paramDesc='Visflag Track Recmode', text={style=1, align=4, str='Rec Mode'} })
Control:new({parent=tcpVisflagTableBox, x=10, y=-2, flow=true, style='visFlagRow', paramDesc='Visflag Track Input Block', text={style=1, align=4, str='Input'} })
Control:new({parent=tcpVisflagTableBox, x=10, y=-2, flow=true, style='visFlagRow', paramDesc='Visflag Track Env', text={style=1, align=4, str='Envelope'} })
Control:new({parent=tcpVisflagTableBox, x=10, y=-2, flow=true, style='visFlagRow', paramDesc='Visflag Track Phase', text={style=1, align=4, str='Phase'} })
Control:new({parent=tcpVisflagTableBox, x=10, y=-2, flow=true, style='visFlagRow', paramDesc='Visflag Track Labels and Values', text={style=1, align=4, str='Labels & Vals'} })
Control:new({parent=tcpVisflagTableBox, x=10, y=-2, flow=true, style='visFlagRow', paramDesc='Visflag Track Meter Values', text={style=1, align=4, str='Meter Values'} })
       
        
tcpMasterBox = El:new({parent=bodyBox, x=10, y=10, w=160, h=270, flow = true, col={50,100,100} })    
El:new({parent=tcpMasterBox, x=0, y=0, w=0, r={toEdge, tcpMasterBox, 'right'}, h=20, col={0,80,80}, text={str='Master Track', style=2, align=4, col={255,255,255}} })         
Control:new({parent=tcpMasterBox, x=10, y=10, w=138, flow=true, style='colour', labelStr = 'Panel Color', paramDesc = 'Master TCP background colour'})
Control:new({parent=tcpMasterBox, x=10, y=10, w=100, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Master TCP Volume Length', units = 'px', labelStr = 'Volume Length'}) 
Control:new({parent=tcpMasterBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Master TCP Values', labelStr = 'Values'})
Control:new({parent=tcpMasterBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Master TCP Labels', labelStr = 'Labels'})
Control:new({parent=tcpMasterBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Master TCP Meter Values', labelStr = 'Meter Vals'}) 
Control:new({parent=tcpMasterBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Master TCP Meter Width', labelStr = 'Meter Width', units = 'px'})
Control:new({parent=tcpMasterBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'Master TCP Meter Border', labelStr = 'Meter Border', units = 'px'})         
     
        
        
belongsToPage = 'EnvCP'

envBox = El:new({parent=bodyBox, x=10, y=10, w=350, h=200, col={255,120,120} }) 
Control:new({parent=envBox, x=10, y=10, w=140, flow=true, style='colour', paramDesc = 'EnvCP background colour'})
Control:new({parent=envBox, x=10, y=10, w=180, h=36, col={50,50,50}, flow=true, style='fader', paramDesc = 'Env Custom Color Strength', units = '%'})
Control:new({parent=envBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Env Div Opacity', units = '%',  remapToMin = 0, remapToMax = 100,})
Control:new({parent=envBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Env inherit track indent'})        

Control:new({parent=envBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'Env Label Font Size', units = 'px'})
Control:new({parent=envBox, x=10, y=10, w=100, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Env Label Length', units = 'px'})
Control:new({parent=envBox, x=10, y=10, w=100, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Env Fader Length', units = 'px'}) 
Control:new({parent=envBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Show envelope value'})
        

belongsToPage = 'MCP'

mcpAllLayoutsBox = El:new({parent=bodyBox, x=10, y=10, w=180, h=160, col={80,80,130} })    
El:new({parent=mcpAllLayoutsBox, x=0, y=0, w=0, r={toEdge, mcpAllLayoutsBox, 'right'}, h=20, col={30,30,100}, text={str='All Layouts', style=2, align=4, col={255,255,255}} }) 
Control:new({parent=mcpAllLayoutsBox, x=10, y=10, w=138, flow=true, style='colour', paramDesc = 'MCP background colour'})
Control:new({parent=mcpAllLayoutsBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'MCP Div Opacity', units = '%', labelStr = 'Div Opacity',  remapToMin = 0, remapToMax = 100})
Control:new({parent=mcpAllLayoutsBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'MCP Folder Indent', units = 'px', labelStr = 'Folder Indent'})
Control:new({parent=mcpAllLayoutsBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'MCP Folder Balance Type', labelStr = 'Folder Balance'})        

mcpLayoutChooseBox = El:new({parent=bodyBox, x=10, y=10, w=100, h=160, flow=true, col={50,50,50} })        
El:new({parent=mcpLayoutChooseBox, x=10, y=0, w=80, h=40,  text={str='LAYOUT', style=3, align=5, col={150,150,150}} })

mcpLayoutRadio = Control:new({parent=mcpLayoutChooseBox, x=10, y=0, flow=true, w=80, h=100, style='radio', col={50,50,50}, controlType = '', 
        scriptAction = function(k)
          if k.value and activeLayout ~= k.value then
            activeLayout = k.value
            updateAnyNotHidden=true
          else
            k.value = activeLayout or 'A'
            k.doUpdate = true
          end
          doReaperGet = true
        end
        })
         
Button:new({parent=mcpLayoutRadio, x=0, y=10, w=20, h=20, flow=true, style='button', img='button_layout_A_off', controlType = 'radio', value = 'A', label = 'none'})
Button:new({parent=mcpLayoutRadio, x=10, y=10, w=20, h=20, flow=true, style='button', img='button_layout_B_off', controlType = 'radio', value = 'B', label = 'none'})
Button:new({parent=mcpLayoutRadio, x=10, y=10, w=20, h=20, flow=true, style='button', img='button_layout_C_off', controlType = 'radio', value = 'C', label = 'none'}) 

mcpBox = El:new({parent=bodyBox, x=10, y=10, w=240, h=160, flow=true, col={255,120,120} }) 
Control:new({parent=mcpBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'MCP Label Font Size', labelStr='Label Font', units = 'px'})
Control:new({parent=mcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Verbose MCP', labelStr='Verbose'})
Control:new({parent=mcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'mcpMeterReadout', labelStr='Meter Readout'})
Control:new({parent=mcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Sidebar Width', units = 'px'})         
Control:new({parent=mcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', controlType='reaperActionToggle', labelStr='Show FX Inserts',
        param=40549}) 
Control:new({parent=mcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', controlType='reaperActionToggle', labelStr='Show FX Params',
        param=40910})   
Control:new({parent=mcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', controlType='reaperActionToggle', labelStr='Show Sends',
        param=40557})
        
       
        
mcpUnselectedBox = El:new({parent=bodyBox, x=10, y=10, w=140, h=160, flow = true, col={100,100,100} })    
El:new({parent=mcpUnselectedBox, x=0, y=0, w=0, r={toEdge, mcpUnselectedBox, 'right'}, h=20, col={50,50,50}, text={str='when Unselected', style=2, align=4, col={255,255,255}} }) 
Control:new({parent=mcpUnselectedBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Mixer Panel Width', labelStr = 'MCP Width', units = 'px',}) 
Control:new({parent=mcpUnselectedBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Mixer Sidebar', labelStr = 'Sidebar'})
Control:new({parent=mcpUnselectedBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'Mixer nChan Grow', labelStr = 'Expansion by chan', units = 'px'})
Control:new({parent=mcpUnselectedBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Mixer Meter Values', labelStr = 'Meter Values'})

mcpSelectedBox = El:new({parent=bodyBox, x=10, y=10, w=140, h=160, flow = true, col={100,100,100} })    
El:new({parent=mcpSelectedBox, x=0, y=0, w=0, r={toEdge, mcpSelectedBox, 'right'}, h=20, col={200,200,200}, text={str='when Selected', style=2, align=4, col={38,38,38}} }) 
Control:new({parent=mcpSelectedBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Selected Mixer Panel Width', labelStr = 'MCP Width', units = 'px',})
Control:new({parent=mcpSelectedBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Selected Mixer Sidebar', labelStr = 'Sidebar'})
Control:new({parent=mcpSelectedBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'Selected Mixer nChan Grow', labelStr = 'Expansion by chan', units = 'px'})
Control:new({parent=mcpSelectedBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Selected Mixer Meter Values', labelStr = 'Meter Values'})

mcpArmedBox = El:new({parent=bodyBox, x=10, y=10, w=140, h=160, flow = true, col={100,0,0} })    
El:new({parent=mcpArmedBox, x=0, y=0, w=0, r={toEdge, mcpArmedBox, 'right'}, h=20, col={180,0,0}, text={str='when Armed', style=2, align=4, col={255,150,150}} })
Control:new({parent=mcpArmedBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Armed Mixer Panel Width', labelStr = 'MCP Width', units = 'px',})
Control:new({parent=mcpArmedBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Armed Mixer Sidebar', labelStr = 'Sidebar'})
Control:new({parent=mcpArmedBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'Armed Mixer nChan Grow', labelStr = 'Expansion by chan', units = 'px'})
Control:new({parent=mcpArmedBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Armed Mixer Meter Values', labelStr = 'Meter Values'})

normalMcpBox = El:new({parent=bodyBox, x=10, y=10, w=240, h=160, flow = true, col={100,140,140} })
El:new({parent=normalMcpBox, x=0, y=0, w=240, h=20, col={120,255,255}, text={str='... at normal width', style=2, align=4, col={0,100,100}} }) 
Control:new({parent=normalMcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Dark Under Buttons'})

Control:new({parent=normalMcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'mcpNormalShowSecIn', labelStr = 'Hide In Sec at', units = 'px'}) 
Control:new({parent=normalMcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'mcpNormalShowSecPan', labelStr = 'Hide Pan Sec at', units = 'px'}) 
Control:new({parent=normalMcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'mcpNormalShowRoute', labelStr = 'Show Route'})
Control:new({parent=normalMcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'mcpNormalShowSecFx', labelStr = 'Show Fx'})
Control:new({parent=normalMcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'mcpNormalShowEnv', labelStr = 'Show Env'})
Control:new({parent=normalMcpBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'mcpNormalShowPhase', labelStr = 'Show Phase'})



interMcpBox = El:new({parent=bodyBox, x=10, y=10, w=150, h=160, flow = true, col={140,100,140} })
El:new({parent=interMcpBox, x=0, y=0, w=150, h=20, col={255,120,255}, text={str='... at intermediate width', style=2, align=4, col={100,0,100}} }) 
Control:new({parent=interMcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'mcpInterShowSecIn', labelStr = 'Hide In Sec at', units = 'px'}) 
Control:new({parent=interMcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'mcpInterShowSecButtons', labelStr = 'Hide Buttons Sec at', units = 'px'})
Control:new({parent=interMcpBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'mcpInterShowSecPan', labelStr = 'Hide Pan Sec at', units = 'px'})        

        
stripBox = El:new({parent=bodyBox, x=10, y=10, w=500, h=160, flow = true, col={100,100,140} })
El:new({parent=stripBox, x=0, y=0, w=500, h=20, col={120,120,255}, text={str='...at strip width', style=2, align=4, col={255,255,255}} }) 
Control:new({parent=stripBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Hide non-sidebar ExtMixer'})
Control:new({parent=stripBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'mcpStripSecInAtH', labelStr = 'Hide In Sec at', units = 'px'}) 
Control:new({parent=stripBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Record Input Height', labelStr = 'Input Height', units = 'px',}) 
Control:new({parent=stripBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'mcpStripShowRecmode', labelStr = 'Show Rec Mode'})
Control:new({parent=stripBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'mcpStripShowFxIn', labelStr = 'Show Input FX'})
Control:new({parent=stripBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'mcpStripSecButAtH', labelStr = 'Reduce Buttons at', units = 'px'}) 
Control:new({parent=stripBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'mcpStripShowEnv', labelStr = 'Show Env'})
Control:new({parent=stripBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'mcpStripShowPhase', labelStr = 'Show Phase'})
Control:new({parent=stripBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'mcpStripShowSecPan', labelStr = 'Show Pan'})
Control:new({parent=stripBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'mcpStripSecPanAtH', labelStr = 'Hide Pan Sec at', units = 'px'}) 
Control:new({parent=stripBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Meter Height', units = 'px'}) 
Control:new({parent=stripBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Volume Height', units = 'px'}) 
Control:new({parent=stripBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'mcpStripVolKnobAtH', labelStr = 'reduce to knob at', units = 'px'})         
Control:new({parent=stripBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Label Height', units = 'px'}) 
Control:new({parent=stripBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'mcpStripShowRecmon', labelStr = 'Show Rec Monitor'})        
        
mcpMasterBox = El:new({parent=bodyBox, x=10, y=10, w=160, h=160, flow = true, col={100,140,100} })
El:new({parent=mcpMasterBox, x=0, y=0, w=160, h=20, col={120,180,120}, text={str='Master Mixer', style=2, align=4, col={255,255,255}} })  
Control:new({parent=mcpMasterBox, x=10, y=10, w=138, flow=true, style='colour', labelStr = 'Panel Color', paramDesc = 'Master MCP background colour'})
Control:new({parent=mcpMasterBox, x=10, y=10, h=30, col={100,0,255}, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, 
        paramDesc = 'Master Mixer Panel Width', labelStr = 'Panel Width', units = 'px',}) 
Control:new({parent=mcpMasterBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Master MCP Values', labelStr = 'Values'})
Control:new({parent=mcpMasterBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Master MCP Labels', labelStr = 'Labels'})
Control:new({parent=mcpMasterBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', paramDesc = 'Master MCP Meter Values', labelStr = 'Meter Values'}) 
        
 
belongsToPage = 'Transport'

transBox = El:new({parent=bodyBox, x=10, y=10, w=300, h=200, col={120,255,255} }) 

Control:new({parent=transBox, x=10, y=10, h=30, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, paramDesc = 'Status Width', units = 'px'})
Control:new({parent=transBox, x=10, y=10, h=30, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, paramDesc = 'Rate Width', units = 'px'})
Control:new({parent=transBox, x=10, y=10, h=30, flow=true, style='knob', img='tcp_vol_knob_stack', iFrameH=20, iFrame=20, paramDesc = 'Selection Width', units = 'px'})
Control:new({parent=transBox, x=10, y=10, h=30, col={0,100,100}, flow=true, style='spinner', paramDesc = 'Transport Margins', units = 'px'})
 
transPrefsBox = El:new({parent=bodyBox, x=10, y=10, w=300, h=200, flow = true, col={100,100,100} })    
El:new({parent=transPrefsBox, x=0, y=0, w=0, r={toEdge, transPrefsBox, 'right'}, h=20, col={200,200,200}, text={str='Preferences', style=2, align=4, col={38,38,38}} }) 
Control:new({parent=transPrefsBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', controlType='reaperActionToggle', labelStr='Show Play Rate',
        param=40531})  
Control:new({parent=transPrefsBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', controlType='reaperActionToggle', labelStr='Center Transport',
        param=40533})
Control:new({parent=transPrefsBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', controlType='reaperActionToggle', labelStr='Show Time Signature',
        param=40680})
Control:new({parent=transPrefsBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', controlType='reaperActionToggle', labelStr='Use Previous/Next',
        param=40868})
Control:new({parent=transPrefsBox, x=10, y=10, flow=true, style='button', controlImg='script_button_tick_off', controlType='reaperActionToggle', labelStr='Show Play State as Text',
        param=40532})        


belongsToPage = nil 

     

  

  
  

  --------- RUNLOOP ----------

activeLayout = 'A'
fps = 24 -- hohoho
lastchgidx = 0
mouseXold = 0
mouseYold = 0
mouseWheelAccum = 0
trackCountOld = 0
dirtyZones ={}
bufIdx = {}
gfxWold, gfxHold = gfx.w, gfx.h
bufferPinkValues ={}
ThemeLayout_RefreshAll = false
updateAnyNotHidden=true


function runloop()
  c=gfx.getchar()
  themeCheck()
 
  -- mouse stuff
  local isCap = (gfx.mouse_cap&1)
  
  if gfx.mouse_x ~= mouseXold or gfx.mouse_y ~= mouseYold or (firstClick ~= nil and last_click_time ~= nil and last_click_time+.25 < nowTime) then
    firstClick = nil
  end
  
  if gfx.mouse_x ~= mouseXold or gfx.mouse_y ~= mouseYold or isCap ~= mouseCapOld or gfx.mouse_wheel ~= 0 then
  
    local wheel_amt = 0
    if gfx.mouse_wheel ~= 0 then
      mouseWheelAccum = mouseWheelAccum + gfx.mouse_wheel
      gfx.mouse_wheel = 0
      wheel_amt = math.floor(mouseWheelAccum / 120 + 0.5)
      if wheel_amt ~= 0 then mouseWheelAccum = 0 end
    end
    
    local hit = nil
    
    for b in ipairs(els) do -- iterate blocks
      local thisBlockX = els[b].drawX or els[b].x
      local scrollXOffs = els[b].scrollX or 0
      local scrollYOffs = els[b].scrollY or 0
      for z = #els[b],1,-1 do -- iterate z backwards
        if els[b][z] ~= nil then
          for j,k in pairs(els[b][z]) do
            local x, y, w, h = (k.drawX or k.x or 0) + thisBlockX, k.drawY or k.y or 0, k.drawW or k.w or 0, k.drawH or k.h or 0
            if k.hitBox then x, y, w, h = x + k.hitBox[1], y + k.hitBox[2], k.hitBox[3], k.hitBox[4] end
            if k.interactive ~= false and k.hidden ~= true and (gfx.mouse_x-scrollXOffs) > x and (gfx.mouse_x-scrollXOffs) < x+w and (gfx.mouse_y+scrollYOffs) > y and (gfx.mouse_y+scrollYOffs) < y+h ~= false then
              hit = k
            end
          end
        end
      end
    end
    
    if isCap == 0 or mouseCapOld == 0 then
      if activeMouseElement ~= nil and activeMouseElement ~= hit then
        activeMouseElement:mouseAway()
        singleClick = nil
        toolTipTimer = nil
      end
      activeMouseElement = hit
    end
    
    if isCap == 0 and mouseCapOld == 1 then -- mouse-up, reset stuff
      dragStart, singleClick = nil, nil
    end
    
    if activeMouseElement ~= nil then
      if isCap == 0 or mouseCapOld == 0 then
        activeMouseElement:mouseOver()
        activeMouseElement:showTooltip()
      end
      if wheel_amt ~= 0 then       
        activeMouseElement:mouseWheel(wheel_amt)
      end
       
      if isCap == 1 then -- mouse down
        activeMouseElement:mouseDown()
         
         local x,y = gfx.mouse_x,gfx.mouse_y
         if firstClick == nil or last_click_time == nil then 
           firstClick = {gfx.mouse_x,gfx.mouse_y}
           last_click_time = nowTime
         else if nowTime < last_click_time+.25 and math.abs((x-firstClick[1])*(x-firstClick[1]) + (y- firstClick[2])*(y- firstClick[2])) < 4 then 
           activeMouseElement:doubleClick() 
           firstClick = nil
           else
             firstClick = nil
           end 
         end
         
      end
    end
    
    mouseXold, mouseYold, mouseCapOld = gfx.mouse_x, gfx.mouse_y, isCap
  end
  
 
  -- changes every FPS
  nowTime = reaper.time_precise()
  if (nextTime == nil or nowTime > nextTime) then -- do onFrame updates
    for b in ipairs(els) do -- iterate blocks
      for z in ipairs(els[b]) do -- iterate z
        if els[b][z] ~= nil then
          for j,k in pairs(els[b][z]) do
            if k.onFps and k.w ~= 0 and k.hidden ~= true then
              k.onFps(k)
            end
          end
        end
      end
    end
    nextTime = nowTime + (1/fps)
    lastTime = nowTime
  end
  
  -- changes because an Update flag is set
  for b in ipairs(els) do -- iterate blocks
    for z in ipairs(els[b]) do -- iterate z
      if els[b][z] ~= nil then
        for j,k in pairs(els[b][z]) do
          if k.onUpdate and k.doUpdate == true and k.hidden ~= true then
            k.onUpdate(k)
          end
        end
      end
    end
  end
  
  
  -- changes because a Timer is running
  if Timers then
    for j,k in pairs(Timers) do --iterate Timers
      if nowTime > k.Timers[j] then -- Timer has expired
        k.onTimerComplete[j]()
        removeTimer(k,j)
      end
    end
  end
  
  
  -- changes from Reaper
  chgidx = reaper.GetProjectStateChangeCount(0)
  if chgidx ~= lastchgidx or doReaperGet == true then
    for b in ipairs(els) do -- iterate blocks
      for z in ipairs(els[b]) do -- iterate z
        if els[z] ~= nil then
          for j,k in pairs(els[b][z]) do

            if k.onReaperChange and k.hidden ~= true then 
              k.onReaperChange(k,'get') 
            end
            
          end
        end
      end
      doArrange = true
    end
    
    lastchgidx = chgidx
    doReaperGet = false
     
  end
 
  if gfxWold ~= gfx.w or gfxHold ~= gfx.h then
    doOnGfxResize()
    gfxWold, gfxHold = gfx.w, gfx.h
  end
  
  
  -- change in screen DPI
  if gfx.ext_retina ~= ext_retinaOld or ext_retinaOld == nil then
    for b in ipairs(els) do -- iterate blocks
      for z in ipairs(els[b]) do -- iterate z
        if els[b][z] ~= nil then
          for j,k in pairs(els[b][z]) do -- iterate elements
            if k.onDpiChange and k.w ~= 0 and k.hidden ~= true then
              k.onDpiChange(k)
              doArrange = true
            end
          end
        end
      end
    end
    
    local nScale = 1
    if gfx.ext_retina > 1.33 then nScale = 1.5 end
    if gfx.ext_retina > 1.66 then nScale = 2 end
    setScale(nScale)
    ext_retinaOld = gfx.ext_retina
  end
  
  if ThemeLayout_RefreshAll == true then
    reaper.ThemeLayout_RefreshAll()
    ThemeLayout_RefreshAll = false
  end
  
 
  -- ARRANGE --
  
  if doArrange == true then -- do Arrange
    --reaper.ShowConsoleMsg('do Arrange\n')
    for b in ipairs(els) do -- iterate blocks
      --reaper.ShowConsoleMsg('do Arrange block '..b..'\n')
      els[b].onArrange()
      els[b].drawX, els[b].drawY, els[b].drawW, els[b].drawH = scaleMult*els[b].x, scaleMult*els[b].y, scaleMult*els[b].w, scaleMult*els[b].h
      if b>1 then
        --blocks arrange as vertical strips
        els[b].drawX = (els[b-1].drawX or els[b-1].x) + (els[b-1].drawW or els[b-1].w) 
      end
      
      for z in ipairs(els[b]) do -- iterate z
        if els[b][z] ~= nil then
          for j,k in pairs(els[b][z]) do 
            k:dirtyXywhCheck(b,z) -- dirtyXywhCheck stores the old xywh, arranges the element, then adds to dirtyZone if it is dirty
            if updateAnyNotHidden==true and k.hidden~= true then 
              k.doUpdate = true 
              k.paramV = nil
            end
          end
        end
      end
    end
    
    doArrange = false
    updateAnyNotHidden = nil
    
  end



  -- DRAW --  
  
  if doDraw == true then
    --reaper.ShowConsoleMsg('do Draw\n')
    for b in ipairs(els) do -- iterate blocks
      if bufIdx[b] == nil then bufIdx[b] = {} end
      local thisBx, thisBy = els[b][1][1].drawX - (els[b].scrollX or 0) or 0, els[b][1][1].drawY - (els[b].scrollY or 0) or 0 
      local prevZDirtyZone = {} -- used to copy dZ from a Z to the next Z, reseting for each block
      
      for z in ipairs(els[b]) do -- iterate z
        
        if prevZDirtyZone.x or (dirtyZones[b][z] ~= nil and dirtyZones[b][z].x2 ~= nil) then -- there is a dirtyZone
          
          if prevZDirtyZone.x then -- prevZDirtyZone is not empty
            if dirtyZones[b] == nil then dirtyZones[b] = {} end                  --this is a lot like the addToDirtyZone function, maybe that could do this
            if dirtyZones[b][z] == nil then dirtyZones[b][z] = {x1={},y1={},x2={},y2={}} end
            dirtyZones[b][z].x1[#dirtyZones[b][z].x1+1] = prevZDirtyZone.x
            dirtyZones[b][z].y1[#dirtyZones[b][z].y1+1] = prevZDirtyZone.y
            dirtyZones[b][z].x2[#dirtyZones[b][z].x2+1] = prevZDirtyZone.x + prevZDirtyZone.w
            dirtyZones[b][z].y2[#dirtyZones[b][z].y2+1] = prevZDirtyZone.y + prevZDirtyZone.h
            prevZDirtyZone = {}
          end
        
          -- FIND THE EXTENTS OF THE DIRTYZONE OF THIS Z --
          local dx1, dy1, dx2, dy2 = nil, nil, nil, nil
          for i=1, #dirtyZones[b][z].x1 do
            if dx1 == nil then dx1 = dirtyZones[b][z].x1[1] end
            if dirtyZones[b][z].x1[i] < dx1 then dx1 = dirtyZones[b][z].x1[i] end
          end
          for i=1, #dirtyZones[b][z].y1 do
            if dy1 == nil then dy1 = dirtyZones[b][z].y1[1] end
            if dirtyZones[b][z].y1[i] < dy1 then dy1 = dirtyZones[b][z].y1[i] end
          end
          for i=1, #dirtyZones[b][z].x2 do
            if dx2 == nil then dx2 = dirtyZones[b][z].x2[1] end
            if dirtyZones[b][z].x2[i] > dx2 then dx2 = dirtyZones[b][z].x2[i] end
          end
          for i=1, #dirtyZones[b][z].x2 do
            if dy2 == nil then dy2 = dirtyZones[b][z].y2[1] end
            if dirtyZones[b][z].y2[i] > dy2 then dy2 = dirtyZones[b][z].y2[i] end
          end
          local dx, dy, dw, dh = dx1, dy1, dx2 - dx1, dy2 - dy1 --dx dy dw dh are the coordinates of the dirtyZone, in screen coordinates
          prevZDirtyZone = {x=dx, y=dy, w=dw, h=dh}
          
          if bufIdx[b][z] == nil then -- this buffer doesn't exist
            if nextBufIdx == nil then nextBufIdx = 1 end
            bufIdx[b][z] = nextBufIdx
            gfx.setimgdim(nextBufIdx, dx-thisBx+dw, dy-thisBy+dh)
            nextBufIdx = nextBufIdx + 1
          else
            local iw, ih = gfx.getimgdim(bufIdx[b][z])
            if iw>0 and ((iw < dx-thisBx+dw) or (ih < dy-thisBy+dh)) then -- check whether this z buffer exists but is too small
              gfx.setimgdim(bufIdx[b][z], dx-thisBx+dw, dy-thisBy+dh) -- fix the buffer size
            end
          end
          
          gfx.dest = 9                                  -- the temp buffer.
          gfx.mode = 2
          gfx.setimgdim(9,dw,dh)                       -- prepare the new temp buffer 
          gfx.set(0)
          gfx.rect(0,0,dw,dh)                          -- erase it
        
          if bufIdx[b][z-1] then -- there is a buffer for the previous z
            gfx.blit(bufIdx[b][z-1],1,0,dx-thisBx,dy-thisBy,dw,dh,0,0,dw,dh) -- blit dZ from clean buffer of previous z BOTH IN BUFFER COORDS NOT SCREEN COORDS!!
          end
          
          for j,k in pairs(els[b][z]) do               -- iterate Els to draw to the buffer
            gfx.mode = 0
            local kx,ky,kw,kh = k.drawX or k.x, k.drawY or k.y, k.drawW or k.w or 0, k.drawH or k.h or 0
            if hasOverlap(kx,ky,kw,kh,dx,dy,dw,dh)==true then k:draw(9,dx,dy) end
          end
           
          -- VISIBLE BUFFERS --
          if debugBuffers == true then
            local border = 0
            --gfx.muladdrect(dx-thisBx+border,dy-thisBy+border,dw-border-border,dh-border-border,1,1,1,1,math.random()/3,math.random()/3,math.random()/3,0)
            gfx.muladdrect(dx,dy,dw,dh,1,1,1,1,math.random()/3,math.random()/3,math.random()/3,0)
            --reaper.ShowConsoleMsg('visible buffer '..b..' ::: dx:'..dx..' dy:'..dy..' dw:'..dw..' dh:'..dh..'\n')
          end
          
          --draw the temp buffer to the clean buffer
          gfx.mode = 2
          gfx.dest = bufIdx[b][z]
          --reaper.ShowConsoleMsg('blit from buf9 to b:'..b..'  z:'..z..'  dw:'..dw..' dh:'..dh..'  dx-thisBx:'..dx-thisBx..'  dy-thisBy:'..dy-thisBy..'\n')
          gfx.blit(9,1,0, 0, 0, dw, dh, dx - els[b][1][1].drawX, dy - els[b][1][1].drawY, dw, dh)
          
          
        else --reaper.ShowConsoleMsg('all of block'..b..' layer'..z..' was clean\n') 
        end -- end of this dirty z

        dirtyZones[b][z] = nil
      
      end -- end iterating z
      
    end -- end iterating blocks
    
  
    --COMP--
    for b in ipairs(els) do -- iterate blocks
      gfx.a, gfx.dest = 1, -1 
      gfx.blit(bufIdx[b][#bufIdx[b]],1,0, 0, els[b].scrollY, els[b].drawW, els[b].drawH, els[b].drawX, els[b].drawY, els[b].drawW, els[b].drawH)
    end
  
    doDraw = false 
  
  end
  

  
  if c>48 and c<59 then
    debugDrawZ = math.floor(c - 48)
  end
  
  if debugDrawZ ~= nil then 
    gfx.a, gfx.dest = 1, -1
    local iw, ih = gfx.getimgdim(debugDrawZ)
    gfx.muladdrect(0,0,iw, ih,0,0,0,0) 
    gfx.blit(debugDrawZ,1,0, 0, 0, iw, ih, 0, 0, gfx.w, gfx.h) 
    text('BUFFER '..debugDrawZ..' w:'..iw..' h:'..ih,0,0,200,20,0,{255,255,255},3)
  end
  
  if c >= 0 then reaper.runloop(runloop) end
  
end


activeMouseElement = nil
gfxWold, gfxHold = 0, 0
runloop()


function Quit()
  d,x,y,w,h=gfx.dock(-1,0,0,0,0)
  reaper.SetExtState(sTitle,"wndw",w,true)
  reaper.SetExtState(sTitle,"wndh",h,true)
  reaper.SetExtState(sTitle,"dock",d,true)
  reaper.SetExtState(sTitle,"wndx",x,true)
  reaper.SetExtState(sTitle,"wndy",y,true)
  reaper.SetExtState(sTitle,"activePage",activePage,true)
  gfx.quit()
end
reaper.atexit(Quit)
