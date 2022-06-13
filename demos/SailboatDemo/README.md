# SailboatDemo

[![SailboatDemo V2](https://img.youtube.com/vi/M9_Z5RxW3Pc/0.jpg)](https://www.youtube.com/watch?v=M9_Z5RxW3Pc)
App video on Youtube

Delphi Firemonkey 3D app for Windows, iOS and Android.

A 3D sailboat on a moving sea surface with waves. 
This demo application was added to this fork of GBE3D 3d components, by Gregory Bersegeay. 

Features:
* SailboatDemo was expanded fron original GBE3D *waterdemo* sample.
* Multi platform ( Windows, iOS and Android ).
* Original sailboat hull model. Made with Blender ( a collada model embedded ). 
* Main and jib sails with camber and quadratic leech. Configurable and dynamic sail mesh.
* Ocean surface w/ waves. 
* Boat stays in the center at 0,0 while the sea surface and land are moved (boatcentric universe)   
* Boat floats on waves and pitches to match waves directional derivative.
* Objects parented to OceanSurface float on it and are moved with boatspeed (like the wake bubbles). This is achieved by using a movable 3d texture.
* A system of TDummys allows setting boat's *course*, *heel* and *pitch* independently, avoiding gymbal locks that might have occured by manipulating RotationAngles. Advice for 3d programmers: Never change all 3 dimensions (x,y,z) of 3Dobject.RotationAngles.
* A rock with a lighthouse (but no collision detection yet). A few other floating objects. 
* As the boat moves, it leaves a wake of floating bubbles. Bubbles are recycled over time.  
* Central rectangle of sea surface (30x30) is surrounded by 4 other, less detailled sea surface rectangle.  
* Large textured TDisk represents the sea horizon.
* Scrollable listbox contains the app controls: camera, boat, waves and object groups ( click button at top-right to open controls) 
* Camera controls: AngleOfView, Azimuth and elevation 
* Option to design camera. Note that this camera cannot be zoomed or moved.
* Mouse actions: drag up/down=change elevation, drag rigth/left rotates camera.
* Boat controls: toggle movement, Course, Speed, Heel, jib and main sheet (sail rotation).
* Wave system is a sum of 5 senoid waves w/ configurable params: Amplitude, Longueur, Vitesse and Origine ( same as TGBEPlaneExtend, Om: kept the french names ) 
* All assets (3d model and textures) embedded in the form file (fSailboatDemo.fmx). That is why the .FMX is so big (25M). 
 
Note: At this time Github web does not accept files larger than 25MB to be moved. I had to use git command line to update fSailboatDemo.fmx.

In order to compile this demo, you have to compile and install the GBE3D design package *in this fork*,
as I have added a few components: the sea surface and sail surfaces.

## Rigged boat

Form in fSailboatDemo.pas is rigged to be controlled externally.  These functions allow manipulating the state of the boat for the frame:

    procedure SetBoatState(const aCap,aHeel,aSpeed,aBoomAngle,aRudderAngle,aWindDir,aWindSpeed:Single);  // sets state of boat 
    procedure SetSailShape( ixSail:integer; aPtArray:TPointF_Array );                                    // sets sail surf to a profile
    procedure set3DcharacterState(ix:integer; const x,y,alfa:Single);   // ix = which char               // sets position and rotation of an animated char
    procedure set3dMarks(ix:integer; const ax,ay:Single);                                                // sets mark postion
    
    Procedure setTerrainBitmap(bVisible:boolean; aBMP:TBitmap);  // use a gray shade bitmap to set large scale terrain map                     


## Windows executable
https://github.com/omarreis/GBE3D/releases/tag/V20

## iOS/Android

App is not available in the stores, but runs ok on iOS and Android.
To run on these devices, you must compile from source.

But you can experiment with this app by using *OPYC* sailing game. OPYC combines the 3D scene with 2D animation using physics (Box2D engine) integrating realtime NOAA GFS winds and high resolution world maps (GSHHG). Available on stores (iOS and Android) search for "OPYC". 

## Video

https://youtu.be/M9_Z5RxW3Pc   SailboatDemo V2 on Youtube (jun22)

http://www.youtube.com/watch?v=bBpZxB8GLpg   SailboatDemo V1 on Youtube

![Youtube video](https://img.youtube.com/vi/bBpZxB8GLpg/0.jpg) 

![app screenshot2](Screenshot2.png)

![app screenshot1](Screenshot1.png)

