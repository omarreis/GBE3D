
# GBE3D
Suite de composants 3D pour Delphi Firemonkey

## In this fork by oMAR
In this fork of Firemonkey 3D component suite *GBE3D* by Gregory Bersegeay, I tried to extend some of the components to enable my SailboatDemo ( a sailboat model with adjustable sails, a wave system and a sea surface with floating stuff.

Original repository is at https://github.com/gbegreg/GBE3D

I added components *TWaveSystem*, *TOceanSurface* and *TomSailSurface*. 

I moved the wave definitions to TWaveSystem, a non-visual component. It supports 3 simultaneous sin waves. TOceanSurface has a WaveSystem field, so that multiple TOceanSurfaces can share the same TWaveSystem. 

TomSailSurface is a basic sail mesh object, for main and jib sails. It supports sails with a straight leech and simetric sails, like spinaker.

I also added the sample https://github.com/omarreis/GBE3D/tree/master/demos/SailboatDemo which includes a racing sailboat model and some textures.

Thanks Gregory for the excelent set of 3d components !

# GBE3D
Cette suite de composants 3D pour Delphi est en cours de développement. De nombreux composants seront ajoutés au fil du temps.
Cette suite de composants est disponible pour toutes les éditions de Delphi dont la community (qui est gratuite) et fonctionne
pour toutes les plateformes cibles de Delphi (Windows, Mac OS, Linux, Android et IOS).
Développé et testé à partir de la version Rio de Delphi (10.3.3).

L'aide en ligne est disponible sur le wiki : https://github.com/gbegreg/GBE3D/wiki

Deux jeux réalisés avec GBE3D : https://gregory-bersegeay.itch.io/

Si cette suite de composants vous plait, merci de laisser une petite étoile ;)

Grégory Bersegeay http://www.gbesoft.fr <br>
Youtube : https://www.youtube.com/channel/UCmmgsWSi92t51LbWaiyBRkQ/videos

Quelques captures d'écran :<br>
<img src="https://github.com/gbegreg/GBE3D/blob/master/img/cubemap.png"><br>
<img src="https://github.com/gbegreg/GBE3D/blob/master/img/grass.png"><br>
<img src="https://github.com/gbegreg/GBE3D/blob/master/img/heightmap.png"><br>
<img src="https://github.com/gbegreg/GBE3D/blob/master/img/viewport3D.png"><br>
<img src="https://github.com/gbegreg/GBE3D/blob/master/img/sphereExtend.png"><br>
