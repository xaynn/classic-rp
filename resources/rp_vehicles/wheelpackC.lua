function replaceModel()

  dff = engineLoadDFF("wheel/wheel1.dff", 1025 )
  engineReplaceModel(dff, 1025)

  dff = engineLoadDFF("wheel/wheel2.dff", 1073 )
  engineReplaceModel(dff, 1073)

  dff = engineLoadDFF("wheel/wheel3.dff", 1074 )
  engineReplaceModel(dff, 1074)

  dff = engineLoadDFF("wheel/wheel4.dff", 1075 )
  engineReplaceModel(dff, 1075) 

  dff = engineLoadDFF("wheel/wheel5.dff", 1076 )
  engineReplaceModel(dff, 1076)

  dff = engineLoadDFF("wheel/wheel6.dff", 1077 )
  engineReplaceModel(dff, 1077)

  dff = engineLoadDFF("wheel/wheel7.dff", 1078 )
  engineReplaceModel(dff, 1078)

  dff = engineLoadDFF("wheel/wheel8.dff", 1079 )
  engineReplaceModel(dff, 1079)

  dff = engineLoadDFF("wheel/wheel9.dff", 1080 )
  engineReplaceModel(dff, 1080)

  dff = engineLoadDFF("wheel/wheel10.dff", 1081 )
  engineReplaceModel(dff, 1081)

  dff = engineLoadDFF("wheel/wheel11.dff", 1082 )
  engineReplaceModel(dff, 1082)

  dff = engineLoadDFF("wheel/wheel12.dff", 1083 )
  engineReplaceModel(dff, 1083)

  dff = engineLoadDFF("wheel/wheel13.dff", 1084 )
  engineReplaceModel(dff, 1084)
  
  dff = engineLoadDFF("wheel/wheel14.dff", 1085 )
  engineReplaceModel(dff, 1085)

  dff = engineLoadDFF("wheel/wheel15.dff", 1096 )
  engineReplaceModel(dff, 1096)

  dff = engineLoadDFF("wheel/wheel16.dff", 1097 )
  engineReplaceModel(dff, 1097)

  dff = engineLoadDFF("wheel/wheel17.dff", 1098 )
  engineReplaceModel(dff, 1098)
end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()), replaceModel)
