unit fSailboatDemo;

interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors, FMX.Ani, FMX.MaterialSources, FMX.Controls3D,
  FMX.Objects3D, FMX.Viewport3D,
  FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, FMX.Layouts, FMX.Edit,
  FMX.EditBox, FMX.SpinBox, FMX.Types3D, FMX.ListBox,

  GBEPlaneExtend,
  GBE_Om_OceanWaves,
  omSailSurface;

type
  TFormSailboatDemo = class(TForm)
    Viewport3D1: TViewport3D;
    FloatAnimation1: TFloatAnimation;
    tbAmplitude: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    tbWaveLenght: TTrackBar;
    Label3: TLabel;
    tbVitesse: TTrackBar;
    Label4: TLabel;
    SpinBox1: TSpinBox;
    Label5: TLabel;
    SpinBox2: TSpinBox;
    Label6: TLabel;
    SpinBox3: TSpinBox;
    ColorMaterialSource1: TColorMaterialSource;
    Switch1: TSwitch;
    Label7: TLabel;
    Label8: TLabel;
    tbOpacite: TTrackBar;
    textureOceanSurface: TLightMaterialSource;
    Light1: TLight;
    OceanSurface: TOceanSurface;
    modelBoat: TModel3D;
    Camera1: TCamera;
    Label9: TLabel;
    tbCap: TTrackBar;
    tbHeel: TTrackBar;
    Label10: TLabel;
    dummyBoatCap: TDummy;
    cubeBoat: TCube;
    tbSelObjY: TTrackBar;
    tbSelObjZ: TTrackBar;
    labSelObjY: TLabel;
    labSelObjZ: TLabel;
    labBoatPitch: TLabel;
    modelBoatMat01: TLightMaterialSource;
    modelBoatMat11: TLightMaterialSource;
    modelBoatMat12: TLightMaterialSource;
    MainSail: TomSailSurface;
    JibSail: TomSailSurface;
    materialMainSail: TLightMaterialSource;
    materialJibSail: TLightMaterialSource;
    Label11: TLabel;
    cbMoveSea: TSwitch;
    Label12: TLabel;
    cbDesignCamera: TSwitch;
    tbSelObjX: TTrackBar;
    labSelObjX: TLabel;
    comboSelObj: TComboBox;
    dummyBoatPitch: TDummy;
    labxxx: TLabel;
    tbAngleOfView: TTrackBar;
    dummyJib: TDummy;
    dummyMain: TDummy;
    Label13: TLabel;
    tbMainRot: TTrackBar;
    Label14: TLabel;
    tbJibRot: TTrackBar;
    Label15: TLabel;
    tbBoatSpeed: TTrackBar;
    sphereRock: TSphere;
    materialBoia: TLightMaterialSource;
    dummyBoatHeel: TDummy;
    cubeJibStay: TCube;
    materialSilver: TColorMaterialSource;
    cylinderBoom: TCylinder;
    planeBoiaMan: TPlane;
    materialBoiaMan: TLightMaterialSource;
    dummyBoiaMan: TDummy;
    materialPelican: TLightMaterialSource;
    dummyPelican: TDummy;
    planePelican: TPlane;
    diskBubble: TDisk;
    listboxControls: TListBox;
    lbiBoatControls: TListBoxItem;
    lbiWaveSettings: TListBoxItem;
    lbiSelectedObject: TListBoxItem;
    lbiCameraControls: TListBoxItem;
    lbiStuff: TListBoxItem;
    labMainRot: TLabel;
    labJibRot: TLabel;
    labBoatSpeed: TLabel;
    LabHeel: TLabel;
    labCap: TLabel;
    labAmplitude: TLabel;
    labLongueur: TLabel;
    labVitesse: TLabel;
    labOpacite: TLabel;
    labCameraViewAngle: TLabel;
    comboWave: TComboBox;
    WaveSystem1: TWaveSystem;
    OceanSurface2: TOceanSurface;
    OceanSurface1: TOceanSurface;
    OceanSurface4: TOceanSurface;
    diskSeaHorizon: TDisk;
    OceanSurface5: TOceanSurface;
    OceanSurface6: TOceanSurface;
    OceanSurface7: TOceanSurface;
    OceanSurface3: TOceanSurface;
    cylinderLighthouse: TCylinder;
    materialFarol: TLightMaterialSource;
    cylinderLighthouseTop: TCylinder;
    textureRock: TLightMaterialSource;
    procedure FloatAnimation1Process(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tbAmplitudeTracking(Sender: TObject);
    procedure tbWaveLenghtTracking(Sender: TObject);
    procedure tbVitesseTracking(Sender: TObject);
    procedure SpinBox1Change(Sender: TObject);
    procedure Switch1Switch(Sender: TObject);
    procedure tbOpaciteTracking(Sender: TObject);
    procedure tbCapTracking(Sender: TObject);
    procedure tbHeelTracking(Sender: TObject);
    procedure tbSelObjYTracking(Sender: TObject);
    procedure tbSelObjZTracking(Sender: TObject);
    procedure cbDesignCameraSwitch(Sender: TObject);
    procedure tbSelObjXTracking(Sender: TObject);
    procedure comboSelObjChange(Sender: TObject);
    procedure tbAngleOfViewTracking(Sender: TObject);
    procedure tbMainRotTracking(Sender: TObject);
    procedure tbJibRotTracking(Sender: TObject);
    procedure tbBoatSpeedTracking(Sender: TObject);
    procedure comboWaveChange(Sender: TObject);
  private
    function getSelected3DObject:TControl3d;
    function getSelectedWave:integer;
  public
    fWasInsideSeasurface:boolean;
    center : TPoint3D;
    fBoatAttitude:TPoint3D;  // (pitch, yaw, roll)
  end;

var
  FormSailboatDemo: TFormSailboatDemo;

implementation

{$R *.fmx}

{ TForm1 }

procedure TFormSailboatDemo.FormCreate(Sender: TObject);
begin
  // init trackbars
  tbAmplitude.Value    := WaveSystem1.Amplitude;
  tbWaveLenght.Value   := WaveSystem1.Longueur;
  tbVitesse.Value      := WaveSystem1.Vitesse;
  tbOpacite.Value      := OceanSurface.Opacity;

  fBoatAttitude        := Point3D(0,0,0);    // (pitch, yaw, roll)
  fWasInsideSeasurface  := true;             // start inside

  FloatAnimation1.Start;
end;

procedure TFormSailboatDemo.cbDesignCameraSwitch(Sender: TObject);
begin
  self.Viewport3D1.UsingDesignCamera := cbDesignCamera.IsChecked;
end;

procedure TFormSailboatDemo.comboSelObjChange(Sender: TObject);
var v:Single; aObj:TControl3d; P:TPoint3D;
begin
  aObj := getSelected3DObject;

  tbSelObjX.Value := aObj.Position.X;
  tbSelObjY.Value := aObj.Position.Y;
  tbSelObjZ.Value := aObj.Position.Z;
end;

procedure TFormSailboatDemo.comboWaveChange(Sender: TObject);
begin
  case getSelectedWave of
    0: begin
         tbVitesse.Value    := WaveSystem1.Vitesse;
         tbWaveLenght.Value := WaveSystem1.Longueur;
         tbAmplitude.Value  := WaveSystem1.Amplitude;

         SpinBox1.Value := WaveSystem1.Origine.x;
         SpinBox2.Value := WaveSystem1.Origine.y;
         SpinBox3.Value := WaveSystem1.Origine.z;
       end;
    1: begin
         tbVitesse.Value    := WaveSystem1.Vitesse2;
         tbWaveLenght.Value := WaveSystem1.Longueur2;
         tbAmplitude.Value  := WaveSystem1.Amplitude2;
         SpinBox1.Value := WaveSystem1.Origine2.x;
         SpinBox2.Value := WaveSystem1.Origine2.y;
         SpinBox3.Value := WaveSystem1.Origine2.z;
       end;
    2: begin
         tbVitesse.Value    := WaveSystem1.Vitesse3;
         tbWaveLenght.Value := WaveSystem1.Longueur3;
         tbAmplitude.Value  := WaveSystem1.Amplitude3;
         SpinBox1.Value := WaveSystem1.Origine3.x;
         SpinBox2.Value := WaveSystem1.Origine3.y;
         SpinBox3.Value := WaveSystem1.Origine3.z;
       end;
  end;
end;

var
  TickCounter:integer=0;

procedure TFormSailboatDemo.FloatAnimation1Process(Sender: TObject);  // 0.2 sec tick
var aAmpl,aPitch,aCap,aAng,aSpd,DHeel,aHeelAng,xb,zb:Single;  D,P,Po:TPoint3D;
    newBubble:TProxyObject; aControl:TControl3D;
    isOutside:boolean;
    i,n:integer;
begin
  inc(TickCounter);

  P    := dummyBoatCap.Position.Point ;  //+ Point3D(15,15,0)   // boat position on ocean surface
  aCap := dummyBoatCap.RotationAngle.Y;  // get boat cap

  // Position boat on the sea surface
  if OceanSurface.calcWaveAmplitudeAndPitch(P,aCap,aAmpl,aPitch) then
  // calcWaveAmplitudeAndPitch( P, aCap, {out:} aAmpl,aPitch ) then
    begin
      // when the boat heels, lift it some. In fact the center of buoyancy lifts as the boat side goes under water..

      aHeelAng := dummyBoatHeel.RotationAngle.z;
      if (aHeelAng>180) then aHeelAng := 360-aHeelAng;  // put in the -90..90 range
      aHeelAng := Abs(aHeelAng*Pi/180);       //to rad abs
      DHeel := -0.20*Sin(aHeelAng);          //numbers found ad hoc

      dummyBoatCap.Position.Y := aAmpl*0.95+DHeel;       // mk boat float
      fBoatAttitude.x         := aPitch;          // pitch boat
      dummyBoatPitch.RotationAngle.x := aPitch*0.7;   // 0.7 avoids too much pitching

      labBoatPitch.Text := Format('%5.1f',[aPitch])+'d';  // show pitch
    end;

  for i:=0 to OceanSurface.ChildrenCount-1 do        // move buoys to wave amplitude, so they stay afloat
    begin
      aControl := TControl3D(OceanSurface.Children[i]);

      Po := OceanSurface.Position.Point;
      P  := aControl.Position.Point;       // - Point3d(0.50, 0, 0.50);         // set P in div units

      xb := (P.x + Po.x);
      zb := (P.y - Po.z);

      P    := Point3D(xb,0,zb)/30;    // to subd
      if OceanSurface.calcWaveAmplitudeAndPitch(P, aCap, aAmpl, aPitch) then
         begin
            aControl.Position.z := aAmpl - 0.02;       // mk boat float
            //aControl.RotationAngle.z := aPitch;       //ignore bubble pitch
         end;
    end;

  // move water
  if cbMoveSea.IsChecked then
    begin

      aAng := aCap*Pi/180;          // cap to radians
      aSpd := tbBoatSpeed.Value;    // get boat speed from trackbar
      D := Point3D(-sin(aAng) , 0 , -cos(aAng) ) * aSpd/10;     // displacement in one sec

      P := OceanSurface.Position.Point  + D*0.01;      // move waters
      OceanSurface.Position.Point  := P;
      sphereRock.Position.Point := sphereRock.Position.Point + D*0.01;

      // OceanSurface1.Position.Point := OceanSurface1.Position.Point + D*0.01;
      // OceanSurface2.Position.Point := OceanSurface2.Position.Point + D*0.01;
      // OceanSurface3.Position.Point := OceanSurface3.Position.Point + D*0.01;
      // OceanSurface4.Position.Point := OceanSurface4.Position.Point + D*0.01;
      // OceanSurface5.Position.Point := OceanSurface5.Position.Point + D*0.01;
      // OceanSurface6.Position.Point := OceanSurface6.Position.Point + D*0.01;
      // OceanSurface7.Position.Point := OceanSurface7.Position.Point + D*0.01;

      // keep boat from exiting the sea surface square

      isOutside := (P.x>15) or (P.x<-15) or (P.z>15) or (P.z<-15);
      if fWasInsideSeasurface  and isOutside then    // was inside and went out of the sea, make U turn
        begin
          aCap := aCap+180 + Random(30)-15;      // turn 180 and some randoness
          if (aCap>=360) then aCap:=aCap-360;
          tbCap.Value := aCap;
        end;
      fWasInsideSeasurface := not isOutside;

      // emit bubbles !
      if (TickCounter mod 10)=0 then  // each few seconds, drop a buoy..
        begin
          newBubble := TProxyObject.Create(self);
          OceanSurface.AddObject(newBubble);      // parent buoy to sea surface, so it moves w/ it
          newBubble.SourceObject := diskBubble; // sphereBuoy;
          newBubble.SetSize( (Random(10)+5)/100  , 0.01, (Random(10)+5)/100   );      // small flat
          P := OceanSurface.Position.Point;                                                                 // z makes the bubble float
          newBubble.Position.Point := Point3D(-P.x,+P.z,0) + Point3d( (Random(10)-5 )/20, (Random(10)-5)/20, 0.4 );   // position at -P on the sea surface. some randoness too
          newBubble.Opacity := 0.5;
          newBubble.RotationAngle.x := 90;


          if OceanSurface.ChildrenCount>100 then  // keep a maximum of 50 buoys. If more , clear some old bubbles
            begin
              n:= 50;
              if not (aControl is TDummy) then  // dont remove dummys. These are design time plates
                begin
                   aControl := TControl3D(OceanSurface.Children[n]);
                   aControl.Opacity := 0.5;
                 end;

              n:= 30;
              if not (aControl is TDummy) then
                begin
                  aControl := TControl3D(OceanSurface.Children[n]);
                  aControl.Opacity := 0.5;
                end;

              //change opacity of some

              n:= 20;
              aControl := TControl3D(OceanSurface.Children[n]);
              if not (aControl is TDummy) then
                begin
                  OceanSurface.RemoveObject(aControl);
                  aControl.DisposeOf;
                end;

              n:= 10;
              aControl := TControl3D(OceanSurface.Children[n]);
              if not (aControl is TDummy) then
                begin
                  OceanSurface.RemoveObject(aControl);
                   aControl.DisposeOf;
                end;

              n:= 5;
              aControl := TControl3D(OceanSurface.Children[n]);
              if not (aControl is TDummy) then
                begin
                   OceanSurface.RemoveObject(aControl);
                   aControl.DisposeOf;
                end;

              n:= 2;
              aControl := TControl3D(OceanSurface.Children[n]);
              if not (aControl is TDummy) then
                begin
                  OceanSurface.RemoveObject(aControl);
                  aControl.DisposeOf;
                end;

              n:= 0;
              aControl := TControl3D(OceanSurface.Children[n]);
              if not (aControl is TDummy) then
                begin
                  OceanSurface.RemoveObject(aControl);
                  aControl.DisposeOf;
                end;
            end;
        end;
    end;
  Viewport3D1.Repaint;
end;

procedure TFormSailboatDemo.SpinBox1Change(Sender: TObject);
var P:TPoint3d;
begin
  P := Point3D( SpinBox1.Value, SpinBox2.Value, SpinBox3.Value);
  case getSelectedWave of
    0: WaveSystem1.Origine  := P;
    1: WaveSystem1.Origine2 := P;
    2: WaveSystem1.Origine3 := P;
  end;
end;

procedure TFormSailboatDemo.Switch1Switch(Sender: TObject);
begin
  OceanSurface.ShowLines := Switch1.IsChecked;
end;

procedure TFormSailboatDemo.tbAmplitudeTracking(Sender: TObject);
begin
  case getSelectedWave of
    0: WaveSystem1.Amplitude := tbAmplitude.Value;
    1: WaveSystem1.Amplitude2 := tbAmplitude.Value;
    2: WaveSystem1.Amplitude3 := tbAmplitude.Value;
  end;

  labAmplitude.Text := Format('%6.2f',[tbAmplitude.Value]);
end;

procedure TFormSailboatDemo.tbAngleOfViewTracking(Sender: TObject);
begin
  Camera1.AngleOfView := tbAngleOfView.Value;
  labCameraViewAngle.Text := Format('%5.0f',[Camera1.AngleOfView])+'o';
end;

procedure TFormSailboatDemo.tbBoatSpeedTracking(Sender: TObject);
begin
  labBoatSpeed.Text := Format('%5.0f',[tbBoatSpeed.Value]);
end;

procedure TFormSailboatDemo.tbWaveLenghtTracking(Sender: TObject);
begin
  case getSelectedWave of
    0: WaveSystem1.Longueur  := tbWaveLenght.Value;
    1: WaveSystem1.Longueur2 := tbWaveLenght.Value;
    2: WaveSystem1.Longueur3 := tbWaveLenght.Value;
  end;

  labLongueur.Text := Format('%5.1f',[tbWaveLenght.Value]);
end;

procedure TFormSailboatDemo.tbVitesseTracking(Sender: TObject);
begin
  case getSelectedWave of
    0: WaveSystem1.Vitesse := tbVitesse.Value;
    1: WaveSystem1.Vitesse2 := tbVitesse.Value;
    2: WaveSystem1.Vitesse3 := tbVitesse.Value;
  end;
  labVitesse.Text :=  Format('%5.1f',[tbVitesse.Value]);
end;

procedure TFormSailboatDemo.tbOpaciteTracking(Sender: TObject);
begin
  OceanSurface.Opacity := tbOpacite.Value;
  labOpacite.Text :=  Format('%5.2f',[tbOpacite.Value]);
end;

procedure TFormSailboatDemo.tbCapTracking(Sender: TObject);
begin
  dummyBoatCap.RotationAngle.y := tbCap.Value;    // cap = boat course
  labCap.Text :=  Format('%5.0f',[tbCap.Value]);
end;

procedure TFormSailboatDemo.tbHeelTracking(Sender: TObject);
begin
  dummyBoatHeel.RotationAngle.z := tbHeel.Value;   // boat heel
  labHeel.Text := Format('%5.1f',[tbHeel.Value]);
end;

procedure TFormSailboatDemo.tbJibRotTracking(Sender: TObject);
begin
  dummyJib.RotationAngle.y :=  tbJibRot.Value;
  JibSail.CamberRight := (tbJibRot.Value>0);
  labJibRot.Text := Format('%5.1f',[tbJibRot.Value]);
end;

procedure TFormSailboatDemo.tbMainRotTracking(Sender: TObject);
begin
  dummyMain.RotationAngle.y :=  tbMainRot.Value;
  MainSail.CamberRight := (tbMainRot.Value<0);
  labMainRot.Text := Format('%5.1f',[tbMainRot.Value]);
end;

function TFormSailboatDemo.getSelectedWave:integer;   // 0, 1 or 2
begin
  if ComboWave.ItemIndex=-1 then Result := 0
    else Result := ComboWave.ItemIndex;
end;

function TFormSailboatDemo.getSelected3DObject:TControl3d;
begin
  case comboSelObj.ItemIndex of
    0: Result := modelBoat;
    1: Result := MainSail;
    2: Result := JibSail;
    3: Result := dummyMain;
    4: Result := dummyJib;
    5: Result := cylinderBoom;
    6: Result := dummyBoatCap;
  else Result := modelBoat;  //??
  end;
end;

procedure TFormSailboatDemo.tbSelObjXTracking(Sender: TObject);
var v:Single; aObj:TControl3d;
begin
  aObj := getSelected3DObject;

  v := tbSelObjX.Value;
  labSelObjX.Text := Format('%5.2f',[v]);

  aObj.Position.X := v;
end;

procedure TFormSailboatDemo.tbSelObjYTracking(Sender: TObject);
var v:Single; aObj:TControl3d;
begin
  aObj := getSelected3DObject;

  v := tbSelObjY.Value;
  labSelObjY.Text := Format('%5.2f',[v]);

  aObj.Position.Y := v;
end;

procedure TFormSailboatDemo.tbSelObjZTracking(Sender: TObject);
var v:Single; aObj:TControl3d;
begin
  aObj := getSelected3DObject;

  v := tbSelObjZ.Value;
  labSelObjZ.Text := Format('%5.2f',[v]);
  aObj.Position.Z := v;
end;

end.

