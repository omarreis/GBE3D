# SailboatDemo

[![SailboatDemo V2](https://img.youtube.com/vi/M9_Z5RxW3Pc/0.jpg)](https://www.youtube.com/watch?v=M9_Z5RxW3Pc)
App video on Youtube

Delphi Firemonkey 3D app for Windows, iOS and Android.

A 3D sailboat on a moving sea surface with waves. 
This demo application was added to this fork of GBE3D 3d components, by Gregory Bersegeay. 

Features:
* SailboatDemo is based on original GBE3D *waterdemo* sample.
* Multi platform ( Windows, iOS and Android ).
* racer boat hull model. Made with Blender ( a collada model embedded ) 
* Main and jib sails with camber and quadratic leech. Configurable and dynamic sail mesh.
* Ocean surface w/ waves. 
* Boat stays in the center at 0,0 while the sea surface and land are moved (boatcentric universe)   
* Boat floats on waves and pitches to match wave inclination in Course direction.
* Objects parented to the OceanSurface float on and move with it (like the boat wake bubbles).
* A system of TDummys allows setting boat's *course*, *heel* and *pitch* independently, avoiding gymbal locks by manipulating RotationAngles (Euler angles).
* A rock with a lighthouse (but no collision detection yet). A few floating objects. 
* As the boat moves, it leaves a wake of floating bubbles. Bubbles are recycled over time.  
* One rectangle of sea surface (30x30). Boat stays in the center. 
* Large textured TDisk represents the sea horizon.
* Scrollable listbox contains the app controls: camera, boat, waves and object groups. 
* Camera controls: AngleOfView, Azimuth and elevation or switch to design camera.
* Mouse drag: up=change elevation, rigth/left - rotate camera.
* Boat controls: movement, Course, Speed, Heel, jib and main sheet.
* 5 waves w/ configurable params: Amplitude, Longueur, Vitesse and Origine ( same as TGBEPlaneExtend ) 
* All assets (3d model and textures) are embedded in the form file (fSailboatDemo.fmx). That is why the .FMX is so big (25M). 
 
Note: Github does not accept large 25M files on the browser interface. Had to use git command line.

In order to compile this demo, you have to compile and install the GBE3D design package *in this fork*,
as I have added a few components: the sea surface and sail surfaces.

## Rigged boat

Form in fSailboatDemo.pas is rigged to be controlled externally.  These functions allow manipulating the state of the boat:

    procedure SetBoatState(const aCap,aHeel,aSpeed,aBoomAngle,aRudderAngle,aWindDir,aWindSpeed:Single);  // sets state of boat 
    procedure SetSailShape( ixSail:integer; aPtArray:TPointF_Array );                                    // sets sail surf to a profile
    procedure set3DcharacterState(ix:integer; const x,y,alfa:Single);   // ix = which char               // sets position and rotation of an animated character
    procedure set3dMarks(ix:integer; const ax,ay:Single);                                                // sets mark postion

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

