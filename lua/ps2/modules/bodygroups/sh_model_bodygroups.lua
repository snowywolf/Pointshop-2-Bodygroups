Pointshop2.BodygroupsModel = class( "Pointshop2.BodygroupsModel" )

Pointshop2.BodygroupsModel.static.DB = "Pointshop2" --The identifier of the database as given to LibK.SetupDatabase
Pointshop2.BodygroupsModel.static.model = {
    tableName = "ps2_bodygroups",
    fields = {
    ownerId   = "int",
    modelId   = "int",
    skin      = "int",
    groups    = "string"
  }
}
Pointshop2.BodygroupsModel:include( DatabaseModel ) --Adds the model functionality and automagic functions
