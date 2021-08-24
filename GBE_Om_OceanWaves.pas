unit GBE_Om_OceanWaves;   // Om:  TTwoWavesOceanSurface
// TGBEPlaneExtend has one wave. Added a second to TTwoWavesOceanSurface
interface
uses
  System.SysUtils, System.Classes, System.Math,

  FMX.Types, FMX.Controls3D, FMX.Objects3D, System.Math.Vectors, FMX.Types3D, generics.Collections,
  System.Threading, FMX.MaterialSources,
  GBEPlaneExtend;  // TGBEPlaneExtend and WaveRec

type

  TWaveSystem = class( TComponent )      // collection of sea surface sinoid waves (3 for now)
  private
    fTime:Single;                          //Om: movd stuff to protected
    // wave  params
    fAmplitude,fLongueur,fVitesse:single;  //wave 1
    fOrigine: TPoint3D;

    fAmplitude2, fLongueur2, fVitesse2 : single;
    fOrigine2:TPoint3d;

    fAmplitude3, fLongueur3, fVitesse3 : single;
    fOrigine3:TPoint3d;

  protected
    function getWaveParams1:TPoint3d;
    function getWaveParams2:TPoint3d;
    function getWaveParams3:TPoint3d;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   IncTime;

    Property    WaveTime:Single read fTime  write fTime;

  published
    property Origine : TPoint3D read fOrigine     write fOrigine;        // wave 1
    property Amplitude : single read fAmplitude   write fAmplitude;
    property Longueur : single  read fLongueur    write fLongueur;
    property Vitesse : single   read fVitesse     write fVitesse;

    property Origine2  : TPoint3D read fOrigine2 write fOrigine2;        // wave 2
    property Amplitude2: single read fAmplitude2 write fAmplitude2;
    property Longueur2 : single read fLongueur2  write fLongueur2;
    property Vitesse2  : single read fVitesse2   write fVitesse2;

    property Origine3  : TPoint3D read fOrigine3 write fOrigine3;        // wave 3
    property Amplitude3: single read fAmplitude3 write fAmplitude3;
    property Longueur3 : single read fLongueur3  write fLongueur3;
    property Vitesse3  : single read fVitesse3   write fVitesse3;
  end;

  TOceanSurface = class( TPlane )   // actually 3 waves
  private
    fWaveSystem:TWaveSystem;
    procedure CalcWaves;    // W1,W2 = Point3D(Amplitude, Longueur, Vitesse)
  protected
    fNbMesh : integer;                     // number of tiles in the mesh
    fActiveWaves, fShowlines, fUseTasks : boolean;
    fCenter : TPoint3D;
    fMaterialLignes: TColorMaterialSource;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    // Property    Data;  //om: publica
    function    calcWaveAmplitudeAndPitch(P:TPoint3d; const aCap:Single; var aAmplitude,aPitch:Single ):boolean; //Om:
    procedure   Render; override;
  published
    property ActiveWaves : boolean read fActiveWaves write fActiveWaves;
    property ShowLines: boolean read fShowlines write fShowLines;
    property WaveSystem:TWaveSystem read fWaveSystem write fWaveSystem;
    property MaterialLines : TColorMaterialSource read fMaterialLignes write fMaterialLignes;
  end;

  TTwoWavesOceanSurface = class(TOceanSurface);     // compatibility w/ old forms

procedure Register;

implementation         //---------------------------------------------------

procedure Register;
begin
  RegisterComponents('GBE3D', [TWaveSystem, TOceanSurface, TTwoWavesOceanSurface]);
end;

{ TWaveSystem }

constructor TWaveSystem.Create(AOwner: TComponent);
begin
  inherited;

  fTime := 0;

  fAmplitude := 2;    // wave params
  fLongueur  := 5;    // Om: only 1 ?
  fVitesse   := 5;    //
  fOrigine   := Point3D(1,1 , 2);

  fAmplitude2 := 1.1; //2.5;      //wave 2 params
  fLongueur2  := 2.1;
  fVitesse2   := 3;
  fOrigine2   := Point3D(3, 10, 2);  // (SubdivisionsWidth/Width, SubdivisionsHeight/Height, 2)

  fAmplitude3 := 1.5; //1;      //wave 3 params
  fLongueur3  := 4.2;
  fVitesse3   := 3.2;

  fOrigine3   := Point3D(7, -8, 1);
end;

destructor TWaveSystem.Destroy;
begin
  inherited;
end;

function TWaveSystem.getWaveParams1: TPoint3d;
begin
  Result := Point3D(Amplitude, Longueur, Vitesse);           // pack wave params
end;

function TWaveSystem.getWaveParams2: TPoint3d;
begin
  Result := Point3D(fAmplitude2, fLongueur2, fVitesse2);
end;

function TWaveSystem.getWaveParams3: TPoint3d;
begin
  Result := Point3D(fAmplitude3, fLongueur3, fVitesse3);
end;

procedure TWaveSystem.IncTime;
begin
  fTime := fTime + 0.01;    // advance wave time   // Om: changed from 0.01 to 0.02
end;

{ TOceanSurface }

constructor TOceanSurface.Create(AOwner: TComponent);
begin
  inherited;
  fWaveSystem := nil;
  self.SubdivisionsHeight := 30;     // plane subdivisions
  self.SubdivisionsWidth  := 30;

  fNbMesh   := (SubdivisionsWidth + 1) * (SubdivisionsHeight + 1);
  // fCenter = SubD / width  ( unit div/m  )
  fCenter   := Point3D( SubdivisionsWidth / self.Width, SubdivisionsHeight / self.Height, 0);
  fUseTasks := true;         // default= using tasks instead of inline mesh builds
end;

destructor TOceanSurface.Destroy;
begin
  inherited;
end;

procedure TOceanSurface.CalcWaves;    // Wx = Point3D(Amplitude, Longueur, Vitesse)
var
  M:TMeshData;
  x,y : integer;
  somme: single;
  PCenter:TPoint3D;
  front, back : PPoint3D;
  waveRec1,waveRec2,waveRec3 : TWaveRec;
begin
  if not Assigned(fWaveSystem) then exit;

  M := self.Data;    //get mesh
  // init waveRecs
  PCenter := Point3d( SubdivisionsWidth, SubdivisionsHeight, 0)*0.5;

  waveRec1.P := PCenter + fWaveSystem.Origine  * fCenter;    // calc sin wave origin position
  waveRec1.D := fWaveSystem.getWaveParams1;      // D = Point3D( Amplitude, Longueur, Vitesse)

  waveRec2.P := PCenter + fWaveSystem.fOrigine2 * fCenter;
  waveRec2.D := fWaveSystem.getWaveParams2;

  waveRec3.P := PCenter + fWaveSystem.fOrigine3 * fCenter;
  waveRec3.D := fWaveSystem.getWaveParams3;

  fNbMesh   := (SubdivisionsWidth + 1) * (SubdivisionsHeight + 1);

  for y := 0 to SubdivisionsHeight do
     for x := 0 to SubdivisionsWidth do
       begin
         // preserve original vertice's x,y.  Apply wave to z
         front := M.VertexBuffer.VerticesPtr[X + (Y * (SubdivisionsWidth+1))];
         back  := M.VertexBuffer.VerticesPtr[fNbMesh + X + (Y * (SubdivisionsWidth+1))];
         // calc sum of wave amplitudes.  Here x,y is in division units ! ( not m )
         somme := 0;
         somme := waveRec1.Wave(somme, x, y, fWaveSystem.fTime);  // 1 st
         somme := waveRec2.Wave(somme, x, y, fWaveSystem.fTime);  // 2 nd
         somme := waveRec3.Wave(somme, x, y, fWaveSystem.fTime);  // 3 rd

         somme := somme * 100;                        // scale amplitude to div x 100 ?!

         Front^.Z := somme;
         Back^.Z  := somme;
       end;

  M.CalcTangentBinormals;

  fWaveSystem.IncTime;  //adv time by 0.01

end;

// local wave coordinates in P.x,P.z
function TOceanSurface.calcWaveAmplitudeAndPitch( P:TPoint3d; const aCap:Single; var aAmplitude,aPitch:Single ):boolean; //Om:
var  waveRec1,waveRec2,waveRec3:TWaveRec;
     aSumAmpl,aSumDeriv,D,AbsD,x,y:Single;
     PCenter:TPoint3d;

begin
   Result := false;
   if not Assigned(fWaveSystem) then exit;

   // init waveRecs
   PCenter := Point3d( SubdivisionsWidth, SubdivisionsHeight, 0)*0.5;

   waveRec1.P := PCenter + fWaveSystem.Origine  * fCenter;  // calc sin wave origin position
   waveRec1.D := fWaveSystem.getWaveParams1;      // D = Point3D( Amplitude, Longueur, Vitesse)

   waveRec2.P := PCenter + fWaveSystem.fOrigine2 * fCenter;
   waveRec2.D := fWaveSystem.getWaveParams2;

   waveRec3.P := PCenter + fWaveSystem.fOrigine3 * fCenter;
   waveRec3.D := fWaveSystem.getWaveParams3;

   // Sum amplitudes. Note that the derivative of a sum is the sum of the derivatives
   //   f(x)=g(x)+h(x)    ---> f'(x)=g'(x)+h'(x)

   x := (P.x*SubdivisionsWidth -Position.x ) + PCenter.x;
   y := (P.z*SubdivisionsHeight+Position.z ) + PCenter.y;

   aSumAmpl  := 0;
   aSumDeriv := 0;

   if waveRec1.calcWaveAmplitudeAndPitch(aCap, x, y, fWaveSystem.fTime,{out:} aSumAmpl, aSumDeriv) and     // x,y in divs
      waveRec2.calcWaveAmplitudeAndPitch(aCap, x, y, fWaveSystem.fTime,{out:} aSumAmpl, aSumDeriv) and
      waveRec3.calcWaveAmplitudeAndPitch(aCap, x, y, fWaveSystem.fTime,{out:} aSumAmpl, aSumDeriv) then
        begin
          Result := true;
          aAmplitude := aSumAmpl*100;   // scale amplitude x 100, as was done creating the mesh
          //calc pitch in degrees
          D    := aSumDeriv*100;            // scale deriv by 1000 ( cause amplitudes
          AbsD := Abs(D);
          if (AbsD>1) then D:=D/AbsD;
          if (D>=-1.0) and (D<=1.0) then aPitch := ArcSin( D )*180/Pi;     // ad hoc formula
          if aPitch<-25 then       aPitch:=-25         // limit pitch to 25 deg
           else if aPitch>25 then  aPitch:=25;
        end;
end;


// function TOceanSurface.calcWaveAmplitudeAndPitch(P:TPoint3d; const aCap:Single; var aAmplitude,aPitch:Single ):boolean; //Om:
// var
//   M:TMeshData;
//   x,y,z,x1,y1,z1 : integer;
//   front, back, next : PPoint3D;
//   P1:TPoint3d;
//   aAng,D,AbsD:Single;
//
// begin
//   M := Data;
//
//   x := Round( P.x - Position.x + SubdivisionsHeight/2 );
//   y := Round( P.z - Position.z + SubdivisionsWidth/2  );
//
//   aAng := -aCap*Pi/180;  // cap to radians
//
//   P1 := Point3D(x,y,0) + 1.0 * Point3d( sin(aAng), cos(aAng), 0);  // P1 = pto futuro, for pitch calculation
//   x1 := Round( P1.x );
//   y1 := Round( P1.y );
//
//   if (x>=0) and (x<SubdivisionsWidth) and (y>0) and (y<SubdivisionsHeight) then
//     begin
//       front      := M.VertexBuffer.VerticesPtr[x + (y * (SubdivisionsWidth+1))];
//       // back  := M.VertexBuffer.VerticesPtr[fNbMesh + X + (Y * (SubdivisionsWidth+1))];
//       aAmplitude := front^.Z;   // +back^.Z)/2; //??
//       Result     := true;
//
//       if (x1>=0) and (x1<SubdivisionsWidth) and (y1>0) and (y1<SubdivisionsHeight) then
//         begin
//           next := M.VertexBuffer.VerticesPtr[x1 + (y1 * (SubdivisionsWidth+1))];
//           D    := (next^.Z-aAmplitude)/1.5;
//           // AbsD := Abs(D);
//           // if (AbsD>1) then D:=D/AbsD;
//                                                                     //   0.8 is dynamic dampening
//           if (D>=-1.0) and (D<=1.0) then aPitch := ArcSin( D )*180/Pi * 1.0;     // ad hoc formula
//           if aPitch<-25 then  aPitch:=-25         // limit pitch to 25 deg
//           else if aPitch>25 then  aPitch:=25;
//         end
//         else aPitch:=0;  //no pitch
//     end
//     else Result := false;
// end;


procedure TOceanSurface.Render;
begin
  inherited;

  if Assigned(fWaveSystem) and fActiveWaves then
    begin
      if fUseTasks then
        begin
          TTask.Create( procedure
                        begin
                          CalcWaves;   // recalc mesh
                        end).start;
        end
        else begin
          CalcWaves;
        end;
    end;

  if ShowLines then
    Context.DrawLines(self.Data.VertexBuffer, self.Data.IndexBuffer, TMaterialSource.ValidMaterial(fMaterialLignes),1);
end;


end.


