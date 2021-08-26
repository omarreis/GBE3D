# SailboatDemo

![app screenshot1](Screenshot1.png)

A 3D sailboat on a moving sea surface with waves and all. 
This demo application was added to this fork of GBE3D 3d components, by Gregory Bersegeay. 
It is a Delphi Firemonkey 3D application. 

Features:
* SailboatDemo is based on original GBE3D *waterdemo* sample.
* Multi platform ( Windows, iOS and Android ).
* racer boat hull model. Made with Blender ( a collada model embedded ) 
* Main and jib sails with camber and quadratic leech. Configurable and dynamic sail mesh.
* Ocean surface w/ waves. 
* Boat stays in the center at 0,0 while the sea surface and land are moved (boatcentric universe)   
* Boat floats on sea waves and pitches to match sea surface directional derivative ( in Cap direction )
* Objects parented to the OceanSurface float on it (like the boat wake bubbles).
* A system of TDummys allows setting boat's *course*, *heel* and *pitch* independently, avoiding gymbal locks by manipulating RotationAngles.
* A rock with a lighthouse (but no collision detection yet). A few floating objects. 
* As the boat moves, it leaves a wake of floating bubbles. Bubbles are recycled over time.  
* One rectangle of sea surface (30x30). Boat automaticaly makes U turn when leaves the sandbox. Todo: a system of tiles.
* Large textured TDisk represents the sea horizon.
* Scrollable listbox contains the app controls: camera, boat, waves and object groups. 
* Camera controls: AngleOfView or switch to design camera.
* Boat controls: movement, Course, Speed, Heel, jib and main sheet.
* 3 waves w/ configurable params: Amplitude, Longueur, Vitesse and Origine.
* All assets (3d model and textures) are embedded in the form file (fSailboatDemo.fmx). That is why it is so big.

In order to compile this demo, you have to compile and install the GBE3D design package in this fork,
as I have added a few components.

## Windows executable
https://github.com/omarreis/GBE3D/releases/tag/V10

## Video
http://www.youtube.com/watch?v=bBpZxB8GLpg   SailboatDemo on Youtube

![Youtube video](https://img.youtube.com/vi/bBpZxB8GLpg/0.jpg) 

![app screenshot2](Screenshot2.png)
