local offersGui = {}
local offersData = {}
local offerRendered = false
local offSetX, offsetY = exports.rp_scale:returnOffsetXY()
local scaleValue = exports.rp_scale:returnScaleValue()
offersGui.font = dxCreateFont("files/Helvetica.ttf", 15 * scaleValue, false, "proof")
offersGui.drawX, offersGui.drawY = 100 * scaleValue, 100 * scaleValue
offersGui.startX, offersGui.startY = exports.rp_scale:getScreenStartPositionFromBox(offersGui.drawX, offersGui.drawY, 0, offsetY, "center", "bottom")
function renderOffer()
--kto wysyla oferte, jaki item(nazwa), ilosc, akceptuj czy nie
if offersData.typeService == 1 then -- itemy
      dxDrawText("Otrzymałeś ofertę od gracza: "..offersData.offerFrom..", Nazwa przedmiotu: "..offersData.name, offersGui.startX, offersGui.startY,offersGui.startX, offersGui.startY,tocolor(255, 255, 255, 255),1,offersGui.font,"center","top")
	   elseif offersData.typeService ~= 1 then
	   dxDrawText("Otrzymałeś ofertę od gracza: "..offersData.offerFrom..", Usługa: "..offersData.name, offersGui.startX, offersGui.startY,offersGui.startX, offersGui.startY,tocolor(255, 255, 255, 255),1,offersGui.font,"center","top")
	   dxDrawText("Cena: "..offersData.payment.."$", offersGui.startX, offersGui.startY+40*scaleValue,offersGui.startX, offersGui.startY+40*scaleValue,tocolor(255, 255, 255, 255),1,offersGui.font,"center","top")
   end
   	   dxDrawText("Zaakceptuj ofertę klikająć ']' lub odrzuć klawiszem '['", offersGui.startX, offersGui.startY+100*scaleValue,offersGui.startX, offersGui.startY+100*scaleValue,tocolor(255, 255, 255, 255),1,offersGui.font,"center","top")

end


function onGotOffer(offerFrom, name, payment, typeService, endOffer)
    if endOffer then
        if offerRendered then
            removeEventHandler("onClientRender", root, renderOffer)
        end
        offersData = {}
    else
        offersData.offerFrom = offerFrom
        offersData.name = name
        offersData.payment = payment
		offersData.typeService = typeService
        if offerRendered then
            removeEventHandler("onClientRender", root, renderOffer)
        end
        addEventHandler("onClientRender", root, renderOffer)
        offerRendered = true
    end
end

addEvent("onPlayerGotOffer", true)
addEventHandler("onPlayerGotOffer", root, onGotOffer)

