unit omSailSurface; // TomSailSurface - Sail surface 3d object
 //----------------//
// by oMAR - 2021

interface
uses
  System.SysUtils, System.Classes, System.Math.Vectors,System.Threading, System.Types,
  FMX.Types3D, FMX.Types,
  generics.Collections,
  FMX.Controls3D, FMX.Objects3D,FMX.MaterialSources;

type
  TSailShape= ( shapeMain, shapeSimetric, shapeJib );  // sail plans

 // Sail construction params \\-------------------------------------------------------------\\
//
//       ^ h                                    ^ h                           ^ h
//       |      Main                            |        Simetric             |     Jib
//   ht  +----+                          ht   +---+ Lt                    ht  +---+
//       | Lt  \                             /  |  \                          |Lt  \
//       |      \                           /   |   \                         |     \
//       |       \                         /    |    \                        |      \
//       |        \                       /     |     \                       |       \
//       |         \                     /      |      \                      |        \
//       |          \                   /       |       \                     |         \
//       +-----------+                 +-----------------+                    +----------+
//       |    Lm      \               /         | Lm      \                   |    Lm     \
//       |            |               |         |         |                   |            \
//       |             \              |         |         |                   |    Lx       \
//       |             |              \         |         /               hx  +--------------+   <-- h of max chord
//       |              \              |        |        |                    |         ____/
//     0 |      Lb      |              |      0 | Lb     |                  0 |    ____/
//   ----+--------------+--> L        -+--------+--------+--> L           ----+___/-------------> L
//                                                                             Lb
// nh subdivisions in height
// nl subdivisions in chord
//
//--------------------------------------------------------------------------------------------


  TPointF_Array=Array of System.Types.TPointF;

  TSailParams=record  // Sail w/ quadratic leech
    Lb:Single;       // sail chord at the bottom
    Lt:Single;      // chord at the top
    Lm:Single;     // chord at the middle   ( for a quadratic leech )
    ht:Single;    // sail height
    // for Jib shape only
    hx:Single;       // height of Jib max chord
    Lx:Single;      // Jib max chord

    // NsubH:integer;   // subdivisions in height       default = 16hx8w
    // NsubL:integer;  // subdivisions in chord

    function getSailChord(aType:TSailShape; const h:Single):Single;  // chord at a certain height ( h between 0 and ht )
  end;

  // TomSailSurface morphs a TPlane grid into a triangular sail with camber
  // ( or any other polygonal shape  )
  TomSailSurface = class( TPlane )
  private
    fSailShape: TSailShape;
    fVersion: integer;
    function  getchordBottom: Single;
    function  getchordMid: Single;
    function  getchordTop: Single;
    function  getSailHeight: Single;
    procedure setchordBottom(const Value: Single);
    procedure setchordMid(const Value: Single);
    procedure setchordTop(const Value: Single);
    procedure setSailHeight(const Value: Single);
    procedure setSailShape(const Value: TSailShape);
    procedure calcSailSurfaceMesh;
    function  getchordX: Single;
    function  getHeightX: Single;
    procedure setchordX(const Value: Single);
    procedure setHeightX(const Value: Single);
    procedure setVersion(const Value: integer);
  protected
    fTime:Single;                          // Om: movd stuff to protected
    fNbMesh : integer;                     // number of tiles in the mesh

    fSailParams:TSailParams;

    fShowlines, fUseTasks : boolean;
    fMaterialLignes: TColorMaterialSource;
    fCenter : TPoint3D;
    fCamberRight:boolean;      // true = sail camber to the right
    procedure SetDepth(const Value: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   Render;  override;
    // Property    Data;  //om: publica
    function    Altura(P:TPoint3d):Single; //Om: calc wave amplitude on a point
    procedure   SetSailParams( aSailParams:TSailParams);
    procedure   SetMeshWith2Dline(aPtArray:TPointF_Array);

  published
    property ShowLines: boolean  read fShowlines write fShowLines;
    property UseTasks : boolean  read fUseTasks write fUseTasks;
    property MaterialLines : TColorMaterialSource read fMaterialLignes write fMaterialLignes;

    property SailShape:TSailShape read fSailShape   write setSailShape default shapeMain;   // main sail, jib or simetric shape
    property CamberRight:boolean  read fCamberRight write fCamberRight;

    Property SailHeight:Single   read getSailHeight  write setSailHeight;
    Property chordTop:Single     read getchordTop    write setchordTop;
    Property chordMid:Single     read getchordMid    write setchordMid;
    Property chordBottom:Single  read getchordBottom write setchordBottom;
    // Jib style only
    Property HeightX:Single      read getHeightX     write setHeightX;
    Property chordX:Single       read getchordX      write setchordX;

    Property version:integer     read fVersion      write setVersion;
  end;

// Quadratic interpolation with 3 points
function calcQuadraticInterpolation(const x0,y0,x1,y1,x2,y2:Single; const x:Single; {out:} var y:Single  ):boolean;

procedure Register;

implementation  //--------------------------------------

procedure Register;
begin
  RegisterComponents('GBE3D', [TomSailSurface]);
end;

// quadratic interpolation w/ 3 points
// from: https://slideplayer.com/slide/4897028/   search Quadratic interpolation slide
//
// y |     --*--
//   |    /  1  \
//   |   *0      *2
//   |  /         \   x
//   +------------------>
//
// y(x) = b0+b1(x-x0)+b2(x-x0)(x-x1)
// b0 =  y0
// b1 = (y1-y0)/(x1-x0)
// b2 = ((y2-y1)/(x2-x1)-(y1-y0)/(x1-x0)) / (x2-x0)

function calcQuadraticInterpolation(const x0,y0,x1,y1,x2,y2:Single; const x:Single; var y:Single  ):boolean;
var b0,b1,b2,dx10,dx21,dx20:Single;
begin
  dx10 := (x1-x0);
  dx21 := (x2-x1);
  dx20 := (x2-x0);
  Result := (dx10<>0) and (dx21<>0)   and (dx20<>0); // sanity test. Cannot calc if two of the points have same x
  if Result then
    begin
      b0 := y0;
      b1 := (y1-y0)/dx10;
      b2 := ( (y2-y1)/dx21-(y1-y0)/dx10 ) / dx20;
      y  := b0+b1*(x-x0)+b2*(x-x0)*(x-x1);                //return y
    end;
end;

{ TSailParams }

// calc chord at a certain height, using a quadratic leech
function TSailParams.getSailChord(aType:TSailShape; const h: Single): Single;  // in m
var y:Single;
begin
  Result := 0;
  if (ht<=0) or (h<0) or (h>ht) then exit;   //sanity test

  case aType of
    shapeMain: begin
        // was Result := Lb-(Lb-Lt)*h/ht           // was:  linear leech from bot to top
        // quadratic interpolation of L in h using points Lt,Lm,Lb    ( top, mid, bottom chords)
        if calcQuadraticInterpolation({0:}0,Lb, {1:}ht/2,Lm, {2:}ht,Lt,{h:} h,{out:} y) then  Result := y    // quadratic leech
          else Result := 0;
    end;
    shapeJib:  begin     // 'jibs' have max sail width at a certain height 'x'
        if (h<hx) then Result := Lb-(Lb-Lx)*h/hx    //below hx  linear from Lb to Lx
        else begin
          if calcQuadraticInterpolation({0:}hx,Lx, {1:}ht/2,Lm, {2:}ht,Lt,{h:}h,{out:} y) then Result := y   // quadratic leech
            else Result := 0;
        end;
    end;
    shapeSimetric: begin
      // quadratic interpolation of L in h using points Lt,Lm,Lb    ( top, mid, bottom chords)
      if calcQuadraticInterpolation({0:}0,Lb, {1:}ht/2,Lm, {{2:}ht,Lt,{h:} h,{out:} y) then Result := y      // quadratic leech
        else Result := 0;
    end;
  else Result :=0 ;         // wtf ??
  end;
end;

{ TomSailSurface }


constructor TomSailSurface.Create(AOwner: TComponent);
begin
  inherited;

  fSailShape   := shapeMain;    // default sail type = main sail
  // set default sail params ( see diagrams on the top )
  // chords
  fSailParams.Lt    := 0.8;          // Lt:sail chord at the top
  fSailParams.Lm    := 2.65;         // Lm chord at mid (0.8+3.5)/2+0.5=2.65
  fSailParams.Lb    := 3.5;          // Lb:sail chord at the bottom
  //sail height
  fSailParams.ht    := 10.0;         // ht:sail height
  // params for Jibs only
  fSailParams.hx    := 1.0;
  fSailParams.Lx    := 3.5;

  // number of subds more or less to have square sail "tiles"
  // fSailParams.NsubH := 10;           // 1x1 aspect sail
  // fSailParams.NsubL := 10;

  //set plane subdivisions
  // self.Width  := fSailParams.Lb;     // dont mess with original size
  // self.Height := fSailParams.ht;
  // self.Depth  := 5; //??

  // h=10 w=16 comes from OPYC simulation
  // actually OPYC sails have varied number of segments, according to sail size ( from 8 jib to 16 spinaker )
  self.SubdivisionsHeight := 10;    // set plane subdivisions
  self.SubdivisionsWidth  := 16;

  fNbMesh   := (SubdivisionsWidth + 1) * (SubdivisionsHeight + 1);  //mesh number of vertices
  // what fCenter center means is a question
  // = NSubDiv/Width  --> unit = subdiv/m
  fCenter   := Point3D( SubdivisionsWidth / self.Width, SubdivisionsHeight / self.Height, 0);

  fCamberRight := true;         // side of the fake sail canvas

  fUseTasks := true;            // default= using tasks
  fVersion  := 1;
end;

destructor TomSailSurface.Destroy;
begin
  inherited;
end;

function TomSailSurface.getchordBottom: Single;
begin
  Result := fSailParams.Lb;
end;

function TomSailSurface.getchordMid: Single;
begin
  Result := fSailParams.Lm;
end;

function TomSailSurface.getchordTop: Single;
begin
  Result := fSailParams.Lt;
end;

function TomSailSurface.getchordX: Single;
begin
  Result := fSailParams.Lx;
end;

function TomSailSurface.getHeightX: Single;
begin
  Result := fSailParams.hx;
end;

function TomSailSurface.getSailHeight: Single;
begin
  Result := fSailParams.ht;
end;

procedure TomSailSurface.SetDepth(const Value: Single);   // override TPlane tendency to set Depth to 0.01
begin
  if (Self.fDepth<>Value) then   // this copies what TPlane removed
    begin
      Self.fDepth := Value;
      Resize3D;
      if (FDepth < 0) and (csDesigning in ComponentState) then
        begin
          FDepth   := abs(FDepth);
          FScale.Z := -FScale.Z;
        end;
      if not (csLoading in ComponentState) then
        Repaint;
    end;
end;

// Calc sail surface mesh based on a line of points in 2D (planta)

Procedure TomSailSurface.SetMeshWith2Dline(aPtArray:TPointF_Array);
var
  M:TMeshData;
  x,y,np: integer;
  somme: single;
  front,back:PPoint3D;
  h,hinM,Dh,chord,chordFrac,L,z,maxChord,sh2,sw2,ax,ay,aSailWidth:Single;
  aPt:PPointF;

begin
  // sail params sanity test
  if (SubdivisionsHeight<=0) or (SubdivisionsWidth<=0) then exit;  // invalid subdiv values
  if Width=0 then exit;

  M  := self.Data;    // use default TPlane mesh
  fNbMesh   := (SubdivisionsWidth + 1) * (SubdivisionsHeight + 1);  //recalc mesh number of vertices

  // mesh is calculated to fit into  [-0.5,-0.5..0.5,0.5] interval.    Actual sail dimensions are set with objects Width,Height,Depth

  if (fSailParams.Lm>fSailParams.Lb) then aSailWidth := fSailParams.Lm   // get max width
    else aSailWidth  := fSailParams.Lb;

  sh2 := fSailParams.ht/2;
  sw2 := aSailWidth/2;

  h  := -0.5;                     // start at the foot
  Dh := 1.0/SubdivisionsHeight;                           // was Dh := fSailParams.ht/fSailParams.NsubH;
  np := Length(aPtArray);        // number of pts received
  // set maxChord ( max sail width )
  case fSailShape of
    shapeMain:     maxChord := fSailParams.Lb;
    shapeJib:      maxChord := fSailParams.Lx;
    shapeSimetric: maxChord := fSailParams.Lm;  // or Lb?
  else maxChord := 1;
  end;

  for y := 0 to SubdivisionsHeight do
    begin
      // calc DL
      hinM  := (h+0.5)*fSailParams.ht;  // h in m
      chord := fSailParams.getSailChord(fSailShape, hinM );  // sail chord for h in m
      // if (chord<=0) then continue;             //??

      chordFrac := chord/maxChord;     // frac of maxChord in m

      // sail simetry is controlled by where the mesh line starts
      case fSailShape of     // x of sail mesh start
        shapeMain, shapeJib: L := 0;
        shapeSimetric:       L := -chord/2;     // 0 is the sail middle. Start line at x=0-chord/2
      else L := -0.5;         // wtf ??
      end;

      for x := 0 to SubdivisionsWidth do
        begin
          front := M.VertexBuffer.VerticesPtr[X + (Y * (SubdivisionsWidth+1))];
          back  := M.VertexBuffer.VerticesPtr[fNbMesh + X + (Y * (SubdivisionsWidth+1))];

          if (x<np) then  aPt := @aPtArray[x]   // np-1 must be = to SubdivisionsWidth ( remesh if necessary )
            else aPt := @aPtArray[np-1];

          ax  := L - aPt^.y*chordFrac;  // x <--> y scale conversion
          ay  := L - aPt^.x*chordFrac;  // y negative means sail pointing backw

          Front^.X := ax;     // x,y of the mesh always in -0.5,-0.5 .. 0.5,0.5
          Front^.Y := h ;
          Front^.Z := ay;     // x,y of the mesh always in -0.5,-0.5 .. 0.5,0.5

          Back^.X  := ax;
          Back^.Y  := h;
          Back^.Z  := ay;
        end;
      h := h+Dh;  //inc h
    end;

  M.CalcTangentBinormals;
end;

procedure TomSailSurface.calcSailSurfaceMesh;     // create default sail mesh
var
  M:TMeshData;
  x,y : integer;
  somme: single;
  front,back:PPoint3D;
  h,hinM,L,Dh,DL,chord,chordFrac,maxChord,z,ah,al:Single;
  aSailHeight, aSailWidth,sh2,sw2:Single;
begin
  // sail params sanity test
  if (SubdivisionsHeight<=0) or (SubdivisionsWidth<=0) then exit;  // invalid subdiv values

  M        := self.Data;    // use default TPlane mesh
  fNbMesh  := (SubdivisionsWidth + 1) * (SubdivisionsHeight + 1);  //recalc mesh number of vertices

  // mesh is calculated to fit into  [-0.5,-0.5..0.5,0.5] interval.    Actual sail dimensions are set with objects Width,Height,Depth

  aSailHeight := fSailParams.ht;  // height = h top

  // set maxChord ( max sail width ) and SailWidth
  case fSailShape of
    shapeMain:     begin maxChord := fSailParams.Lb; aSailWidth := fSailParams.Lb;  end;
    shapeJib:      begin maxChord := fSailParams.Lx; aSailWidth := fSailParams.Lx;  end;
    shapeSimetric: begin maxChord := fSailParams.Lb; aSailWidth := fSailParams.Lb;  end;    // or Lb?
  else maxChord := 1; aSailWidth := 1;
  end;

  if (fSailParams.Lm>maxChord) then
    begin
      maxChord   := fSailParams.Lm;
      aSailWidth := maxChord;
    end;

  sh2 := aSailHeight/2;
  sw2 := aSailWidth/2;

  h  := -0.5;                        // start at the foot
  Dh := 1.0/SubdivisionsHeight;     // was Dh := fSailParams.ht/fSailParams.NsubH;  // subd h increment
  // this will create a mesh in h range -0.5 .. 0.5

  for y := 0 to SubdivisionsHeight do
    begin
       // calc DL
       hinM  := (h+0.5)*aSailHeight;    // hinM = h in meters
       chord := fSailParams.getSailChord(fSailShape, hinM );      // sail chord for h (  in 0..1 range )
       chordFrac := chord/maxChord;
       if (chord<=0) then continue;             //??
       DL := 0.5*chordFrac/SubdivisionsWidth;   // subd horizontal chord increment

       // sail simetry is controlled by where the mesh line starts
       case fSailShape of     // x of sail mesh start
         shapeMain, shapeJib:  L := 0;
         shapeSimetric:        L := -chord/2;     // 0 is the sail middle. Start line at x=0-chord/2
       else L := 0;         // wtf ??
       end;

       for x := 0 to SubdivisionsWidth do
         begin
           front := M.VertexBuffer.VerticesPtr[X + (Y * (SubdivisionsWidth+1))];
           back  := M.VertexBuffer.VerticesPtr[fNbMesh + X + (Y * (SubdivisionsWidth+1))];

           aL := L;
           ah := h;

           Front^.X := aL;
           Front^.Y := ah;

           Back^.X  := aL;
           Back^.Y  := ah;

           // add some sail side movement ( camber )
           z := x*(SubdivisionsWidth-x)*DL*0.10;      //(Random(10)-5)*0.003;  // test...

           if fCamberRight then z:=-z;
           Front^.Z := z;
           Back^.Z  := z;

           L := L+DL;  //inc L
         end;
      h := h+Dh;       //inc h
    end;

  M.CalcTangentBinormals;
  // fTime := fTime + 0.01;  //??
end;

function TomSailSurface.Altura(P:TPoint3d):Single; //Om:
var
  M:TMeshData;
  x,y : integer;
  front, back : PPoint3D;
begin
  M := self.Data;
  x := Round( P.x );
  y := Round( P.y );
  if (x>=0) and (x<SubdivisionsWidth) and (y>0) and (y<SubdivisionsHeight) then
    begin
      fNbMesh   := (SubdivisionsWidth + 1) * (SubdivisionsHeight + 1);  //recalc mesh number of vertices

      front := M.VertexBuffer.VerticesPtr[X + (Y * (SubdivisionsWidth+1))];
      back  := M.VertexBuffer.VerticesPtr[fNbMesh + X + (Y * (SubdivisionsWidth+1))];

      Result := (front^.Z+back^.Z)/2; //??
    end
    else Result := 0;
end;

procedure   TomSailSurface.SetSailParams( aSailParams:TSailParams );
begin
  fSailParams.Lb    := aSailParams.Lb;
  fSailParams.Lt    := aSailParams.Lt;
  fSailParams.ht    := aSailParams.ht;
  //fSailParams.NsubH := aSailParams.NsubH;
  //fSailParams.NsubL := aSailParams.NsubL;

  //set plane subdivisions
  // self.SubdivisionsHeight := fSailParams.NsubH;  // plane subdivisions
  // self.SubdivisionsWidth  := fSailParams.NsubL;

  fNbMesh   := (SubdivisionsWidth + 1) * (SubdivisionsHeight + 1);
  fCenter   := Point3D( SubdivisionsWidth / self.Width, SubdivisionsHeight / self.Height, 0);

  // calcSailSurfaceMesh;
end;

procedure TomSailSurface.setSailShape(const Value: TSailShape);
begin
  if fSailShape<>Value then
    begin
      fSailShape := Value;
      // should remesh here..
    end;
end;

procedure TomSailSurface.setVersion(const Value: integer);
begin
  if (fVersion<>Value) then
    begin
      fVersion:=Value;
      calcSailSurfaceMesh;   // recalc default mesh, based on fSailParams
    end;
end;

procedure TomSailSurface.Render;
begin
  inherited;
  //each render recalcs the mesh !
  if fUseTasks then
     begin
       TTask.Create( procedure
                     begin
                       // calcSailSurfaceMesh;   // recalc mesh
                     end).start;
     end
     else begin
       // calcSailSurfaceMesh;
     end;

  if ShowLines then
    Context.DrawLines(self.Data.VertexBuffer, self.Data.IndexBuffer, TMaterialSource.ValidMaterial(fMaterialLignes),1);
end;


procedure TomSailSurface.setchordBottom(const Value: Single);
begin
  if fSailParams.Lb<>Value then
    begin
      fSailParams.Lb := Value;
      // calcSailSurfaceMesh; // remesh
    end;
end;

procedure TomSailSurface.setchordMid(const Value: Single);
begin
  if fSailParams.Lm<>Value then
    begin
      fSailParams.Lm := Value;
      // calcSailSurfaceMesh; // remesh
    end;
end;

procedure TomSailSurface.setchordTop(const Value: Single);
begin
  if fSailParams.Lt<>Value then
    begin
      fSailParams.Lt := Value;
      // calcSailSurfaceMesh; // remesh
    end;
end;

procedure TomSailSurface.setchordX(const Value: Single);
begin
  if fSailParams.Lx<>Value then
    begin
      fSailParams.Lx := Value;
      // calcSailSurfaceMesh; // remesh
    end;
end;

procedure TomSailSurface.setHeightX(const Value: Single);
begin
  if fSailParams.hx<>Value then
    begin
      fSailParams.hx := Value;
      // calcSailSurfaceMesh; // remesh
    end;
end;

procedure TomSailSurface.setSailHeight(const Value: Single);
begin
  if fSailParams.ht<>Value then
    begin
      fSailParams.ht := Value;
      // calcSailSurfaceMesh; // remesh
    end;
end;

end.
