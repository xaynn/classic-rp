cameraCalc = {}

function cameraCalc.getPlayerFace()
    local x, y, z, lx, ly, lz = getCameraMatrix()
    local x_value,y_value,z_value = utility.findRotation3D(x, y, z, lx, ly, lz)
    local face_lr, face_fb, face_ud
    if z_value < 180 and z_value >= 0 then
        face_lr = "left"
    else
        face_lr = "right"
    end
    
    if z_value < 90 and z_value >= 0 or z_value <= 360 and z_value > 270 then
        face_fb = "front"
    else
        face_fb = "back"
    end

    if x_value < 0 then
        face_ud = "down"
    else
        face_ud = "up"
    end

    local face_lrP, face_fbP = getFacePercentage(face_fb, face_lr)
    return face_lr, face_fb, face_ud, face_lrP, face_fbP
end

function getFacePercentage(face_fb, face_lr)
    local face_lrP, face_fbP
    local x, y, z, lx, ly, lz = getCameraMatrix()
    local x_value,y_value,z_value = utility.findRotation3D(x, y, z, lx, ly, lz)
    if face_fb == "front" then
        if z_value < 90 and z_value >= 0 then
            local difference = math.abs(z_value - 90)
            face_fbP = difference / 90
        else
            local difference = z_value - 270
            face_fbP = difference / 90
        end
    else
        if z_value > 180 and z_value <= 270 then
            local difference = math.abs(z_value - 270)
            face_fbP = difference / 90
        else
            local difference = z_value - 90
            face_fbP = difference / 90
        end
    end

    if face_lr == "left" then
        if z_value > 90 and z_value < 180 then
            local difference = math.abs(z_value - 180)
            face_lrP = difference / 90
        else
            local difference = z_value
            face_lrP = difference / 90
        end
    else
        if z_value <= 360 and z_value >= 270 then
            local difference = math.abs(z_value - 360)
            face_lrP = difference / 90
        else
            local difference = z_value - 180
            face_lrP = difference / 90
        end
    end
    return face_lrP, face_fbP
end

return cameraCalc

---- SCRIPT NOTES ----

-- NOTES: 1. rx = 0, ry = 0, rz = 0 - camera rotation default (front) SCALE OFF HOW MUCH LEFT AND RIGHT, faces y AXIS (X MODE - reverse (psx1 - psx2), Y MODE - dont reverse(psy1 - psy2), Z MODE (psy1 - psy2)) 
-- 2. rx = 0, ry = 0, rz = 180 - camera rotation 180 (back) SCALE OFF HOW MUCH LEFT AND RIGHT, faces y AXIS (X MODE - dont reverse (psx1 - psx2), Y MODE - reverse (psy1 - psy2), Z MODE (psy1 - psy2))
-- 3. rx = 0, ry = 0, rz = 270 - camera rotation 270 (right) SCALE OFF HOW MUCH FRONT AND BACK, faces x AXIS (X MODE - dont reverse (psy1 - psy2), Y MODE - dont reverse (psx1 - psx2), Z MODE (psy1 - psy2))
-- 4. rx = 0, ry = 0, rz = 90 - camera rotation 90 (left) SCALE OFF HOW MUCH FRONT AND BACK, faces x AXIS (X MODE - reverse (psy1 - psy2), Y MODE - reverse (psx1 - psx2), Z MODE (psy1 - psy2))

-- 0 - 180 is left |||| if z_value < 180 and z_value >= 0 then left
-- 180 - 360 is right |||| if z_value <= 360 and z_value >= 180 then right
-- 90 - 0 A 360 - 270 front zakres 90 - 0 i 360 - 270 |||| if z_value < 90 and z_value >= 0 or z_value <= 360 and z_value > 270 then front ||||
-- front 100% z = 0 or z = 360, front 0% z = 90 or z = 270
-- 270 - 90 back mniej niz 270, wiecej niz 90 |||| if z_value <= 270 and z_value >= 90 then back ||||
-- back 100% z_value = 180, back 0% z_value = 270 or z_value = 90