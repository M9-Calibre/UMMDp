# -*- coding: mbcs -*-
#
# Abaqus/CAE Release 2019 replay file
# Internal Version: 2018_09_24-19.41.51 157541
# Run by Miguel on Mon Feb  8 21:21:55 2021
#

# from driverUtils import executeOnCaeGraphicsStartup
# executeOnCaeGraphicsStartup()
#: Executing "onCaeGraphicsStartup()" in the site directory ...
from abaqus import *
from abaqusConstants import *
session.Viewport(name='Viewport: 1', origin=(0.0, 0.0), width=214.898422241211, 
    height=140.948135375977)
session.viewports['Viewport: 1'].makeCurrent()
session.viewports['Viewport: 1'].maximize()
from caeModules import *
from driverUtils import executeOnCaeStartup
executeOnCaeStartup()
o1 = session.openOdb(
    name='C:/Users/Miguel/Documents/GitHub/UMMDp/example/Tensile_Test.odb')
session.viewports['Viewport: 1'].setValues(displayedObject=o1)
#: Model: C:/Users/Miguel/Documents/GitHub/UMMDp/example/Tensile_Test.odb
#: Number of Assemblies:         1
#: Number of Assembly instances: 0
#: Number of Part instances:     1
#: Number of Meshes:             1
#: Number of Element Sets:       5
#: Number of Node Sets:          5
#: Number of Steps:              1
session.viewports['Viewport: 1'].odbDisplay.display.setValues(plotState=(
    CONTOURS_ON_DEF, ))
session.viewports['Viewport: 1'].odbDisplay.setPrimaryVariable(
    variableLabel='SDV1', outputPosition=INTEGRATION_POINT, )
session.viewports['Viewport: 1'].odbDisplay.setPrimaryVariable(
    variableLabel='UVARM6', outputPosition=INTEGRATION_POINT, )
session.viewports['Viewport: 1'].odbDisplay.setPrimaryVariable(
    variableLabel='UVARM7', outputPosition=INTEGRATION_POINT, )
session.viewports['Viewport: 1'].odbDisplay.setPrimaryVariable(
    variableLabel='UVARM8', outputPosition=INTEGRATION_POINT, )
#: Warning: The selected Primary Variable is not available in the current frame for any elements in the current display group.
session.viewports['Viewport: 1'].odbDisplay.setPrimaryVariable(
    variableLabel='UVARM9', outputPosition=INTEGRATION_POINT, )
#: Warning: The selected Primary Variable is not available in the current frame for any elements in the current display group.
