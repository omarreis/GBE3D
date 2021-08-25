# SailboatDemo

![app screenshot1](Screenshot1.png)

A 3D sailboat on a moving sea surface with waves and all. 
This demo application was added to this fork of GBE3D 3d components, by Gregory Bersegeay. 
It is a Delphi Firemonkey 3D application. 

Features:
* SailboatDemo is based on original GBE3D *waterdemo* sample.
* Multi platform ( Windows, iOS and Android ).
* racer boat hull model made with Blender ( embedded )
* Main and jib sails with camber and quadratic leech. Configurable and dynamic sail mesh.
* Ocean surface moves and the boats stays in the center. 
* Boat floats on sea waves and changes pitch to match the surface (directional derivative).
* Objects parented to the OceanSurface float on it (like the boat wake bubbles).
* A system of TDummys allow setting boat's *course*, *heel* and *sail rotation*
* Rock with a lighthouse (but no collision detection yet). Few floating objects. 
* As the boat moves, it leaves a wake f floating bubbles. Bubbles are recycled over time.  
* Only one small rectangle of sea surface. Boat automaticaly makes U turn when leaving the 30x30 mesh sandbox.
* Large textured TDisk represents the sea horizon.
* Scrollable listbox contains the app controls: camera, boat, waves and object positioning groups. 
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
