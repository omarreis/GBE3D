unit omSailSurface; // TomSailSurface - Sail surface 3d object

// Om: added comments to help understanding Gregory's code

interface
uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls3D, FMX.Objects3D, System.Math.Vectors, FMX.Types3D, generics.Collections,
  System.Threading, FMX.MaterialSources;

type
  TSailShape= ( shapeMain, shapeSimetric );  // sail plans

 // Sail construction params
//
//       ^ h                                          ^ h
//       |      Main                                  |            Simetric
//   ht  +----+                                ht   +---+ Lt
//       | Lt  \                                   /  |  \
//       |      \                                 /   |   \
//       |       \                               /    |    \
//       |        \                             /     |     \
//       |         \                           /      |      \
//       |          \                         /       |       \
//       +-----------+                       +-----------------+
//       |    Lm      \                     /         | Lm      \
//       |            |                     |         |         |
//       |             \                    |         |         |
//       |             |                   /          |          \
//       |              \                  |          |          |
//     0 |      Lb      |                  |        0 | Lb       |
//   ----+--------------+--> L            -+----------+----------+--> L
//
// nh subdivisions in height
// nl subdivisions in chord

  TSailParams=record  // Sail w/ quadratic leech
    Lb:Single;       // sail chord at the bottom
    Lt:Single;       // chord at the top
    Lm:Single;       // chord at the middle   ( for a quadratic leech )
    ht:Single;       // sail height

    NsubH:integer;   // subdivisions in height       default = 16hx8w
    NsubL:integer;   // subdivisions in chord

    function getSailChord(const h:Single):Single;  // chord at a certain height ( h between 0 and ht )
  end;

  TomSailSurface = class( TPlane )
  private
    fSailShape: TSailShape;
    procedure calcSailSurfaceMesh;
    function getchordBottom: Single;
    function getchordMid: Single;
    function getchordTop: Single;
    function getSailHeight: Single;
    procedure setchordBottom(const Value: Single);
    procedure setchordMid(const Value: Single);
    procedure setchordTop(const Value: Single);
    procedure setSailHeight(const Value: Single);
    procedure setSailShape(const Value: TSailShape);
  protected
    fTime:Single;                          // Om: movd stuff to protected
    fNbMesh : integer;                     // number of tiles in the mesh

    fSailParams:TSailParams;

    fShowlines, fUseTasks : boolean;
    fMaterialLignes: TColorMaterialSource;
    fCenter : TPoint3D;
    fCamberRight:boolean;   // true = sail camber to the right
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   Render;  override;
    // Property    Data;  //om: publica
    function    Altura(P:TPoint3d):Single; //Om: calc wave amplitude on a point
    procedure   SetSailParams( aSailParams:TSailParams);

  published
    property ShowLines: boolean  read fShowlines write fShowLines;
    property UseTasks : boolean  read fUseTasks write fUseTasks;
    property MaterialLines : TColorMaterialSource read fMaterialLignes write fMaterialLignes;

    property SailShape:TSailShape read fSailShape   write setSailShape default shapeMain;   // main sail or simetric shapes
    property CamberRight:boolean read fCamberRight   write fCamberRight;

    Property SailHeight:Single   read getSailHeight  write setSailHeight;
    Property chordTop:Single     read getchordTop    write setchordTop;
    Property chordMid:Single     read getchordMid    write setchordMid;
    Property chordBottom:Single  read getchordBottom write setchordBottom;
  end;

function calcQuadraticInterpolation(const x0,y0,x1,y1,x2,y2:Single; const x:Single; var y:Single  ):boolean;

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
function TSailParams.getSailChord(const h: Single): Single;
var y:Single;
begin
  // was Result := Lb-(Lb-Lt)*h/ht           // was:  linear leech from bot to top
  if (ht>0) and (h>=0) and (h<=ht) and
    // quadratic interpolation of L in h using points Lt,Lm,Lb    ( top, mid, bottom chords)
    calcQuadraticInterpolation({0:}0,Lb, {1:}ht/2,Lm, {{2:}ht,Lt,{h:} h,{out:} y) then
    Result := y
    else Result := 0;
end;

{ TomSailSurface }

constructor TomSailSurface.Create(AOwner: TComponent);
begin
  inherited;

  // set default sail params
  // chords
  fSailParams.Lt    := 0.8;          // Lt:sail chord at the top
  fSailParams.Lm    := 2.65;         // Lm chord at mid (0.8+3.5)/2+0.5=2.65
  fSailParams.Lb    := 3.5;          // Lb:sail chord at the bottom
  //sail height
  fSailParams.ht    := 10.0;         // ht:sail height

  // number of subds more or less to have square sail "tiles"
  fSailParams.NsubH := 16;      // a 2x1 aspect sail
  fSailParams.NsubL := 8;

  //set plane subdivisions
  // self.Width  := fSailParams.Lb;     // dont mess with original size
  // self.Height := fSailParams.ht;
  // self.Depth  := 5; //??

  self.SubdivisionsHeight := fSailParams.NsubH;  // set plane subdivisions
  self.SubdivisionsWidth  := fSailParams.NsubL;

  fNbMesh   := (SubdivisionsWidth + 1) * (SubdivisionsHeight + 1);  //mesh number of vertices
  // what fCenter center means is a question
  // = NSubDiv/Width  --> unit = subdiv/m
  fCenter   := Point3D( SubdivisionsWidth / self.Width, SubdivisionsHeight / self.Height, 0);

  fCamberRight := true;         // side of the fake sail canvas
  fSailShape   := shapeMain;    // default sail type = main sail

  fUseTasks := true;            // default= using tasks
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

function TomSailSurface.getSailHeight: Single;
begin
  Result := fSailParams.ht;
end;

// Calc sail surface mesh

procedure TomSailSurface.calcSailSurfaceMesh;     // create sail mesh
var
  M:TMeshData;
  x,y : integer;
  somme: single;
  front,back:PPoint3D;
  h,hinM,L,Dh,DL,chord,z:Single;

  aSailHeight, aSailWidth,sh2,sw2:Single;

begin
  // sail params sanity test
  if (fSailParams.NsubH<=0) or (fSailParams.NsubL<=0) then exit;  // invalid subdiv values

  M  := self.Data;    // use default TPlane mesh

  // mesh is calculated to fit into  [-0.5,-0.5..0.5,0.5] interval.    Actual sail dimensions are set with objects Width,Height,Depth
  Dh := 1.0/fSailParams.NsubH;     // was Dh := fSailParams.ht/fSailParams.NsubH;  // subd h increment

  aSailHeight := fSailParams.ht;
  if (fSailParams.Lm>fSailParams.Lb) then aSailWidth := fSailParams.Lm   // get max width
    else aSailWidth  := fSailParams.Lb;

  sh2 := aSailHeight/2;
  sw2 := aSailWidth/2;

  h  := -0.5;                           // start at the foot

  for y := 0 to SubdivisionsHeight do
    begin
       // calc DL
       hinM := (h+0.5)*aSailHeight;     // calc h in meters
       chord := fSailParams.getSailChord( hinM )/aSailWidth;  // sail chord for h (  in 0..1 range )

       if (chord<=0) then continue;             //??
       DL := chord/fSailParams.NsubL;          // subd horizontal chord increment

       // sail simetry is controlled by where the mesh line starts
       case fSailShape of     // x of sail mesh start
         shapeMain:      L := -0.5;
         shapeSimetric:  L := -chord/2;     // 0 is the sail middle. Start line at x=0-chord/2
       else L := -05;         // wtf ??
       end;

       for x := 0 to SubdivisionsWidth do
         begin
           front := M.VertexBuffer.VerticesPtr[X + (Y * (SubdivisionsWidth+1))];
           back  := M.VertexBuffer.VerticesPtr[fNbMesh + X + (Y * (SubdivisionsWidth+1))];

           Front^.X := L; Back^.X  := L;    // x,y of the mesh always in -0.5,-0.5 .. 0.5,0.5
           Front^.Y := h; Back^.Y  := h;

           // add some sail side movement ( camber )
           z        := x*(SubdivisionsWidth-x)*chord*0.010;      //(Random(10)-5)*0.003;  // test...
           if fCamberRight then z:=-z;
           Front^.Z := z; Back^.Z  := z;

           L := L+DL;  //inc x
         end;
      h := h+Dh;  //inc h
    end;

  M.CalcTangentBinormals;
  fTime := fTime + 0.01;  //??
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
  fSailParams.NsubH := aSailParams.NsubH;
  fSailParams.NsubL := aSailParams.NsubL;

  //set plane subdivisions
  self.SubdivisionsHeight := fSailParams.NsubH;  // plane subdivisions
  self.SubdivisionsWidth  := fSailParams.NsubL;

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

procedure TomSailSurface.Render;
begin
  inherited;
  //each render recalcs the mesh !
  if fUseTasks then
     begin
       TTask.Create( procedure
                     begin
                       calcSailSurfaceMesh;   // recalc mesh
                     end).start;
     end
     else begin
       calcSailSurfaceMesh;
     end;

  if ShowLines then
    Context.DrawLines(self.Data.VertexBuffer, self.Data.IndexBuffer, TMaterialSource.ValidMaterial(fMaterialLignes),1);
end;


procedure TomSailSurface.setchordBottom(const Value: Single);
begin
  if fSailParams.Lb<>Value then
    begin
      fSailParams.Lb := Value;
      // remesh
    end;
end;

procedure TomSailSurface.setchordMid(const Value: Single);
begin
  if fSailParams.Lm<>Value then
    begin
      fSailParams.Lm := Value;
      // remesh
    end;
end;

procedure TomSailSurface.setchordTop(const Value: Single);
begin
  if fSailParams.Lt<>Value then
    begin
      fSailParams.Lt := Value;
      // remesh
    end;
end;

procedure TomSailSurface.setSailHeight(const Value: Single);
begin
  if fSailParams.ht<>Value then
    begin
      fSailParams.ht := Value;
      // remesh
    end;
end;

end.
