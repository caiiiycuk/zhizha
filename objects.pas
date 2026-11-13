unit objects;

{+
 0:Земля
 1:Будильник
 2:Таблетка
 3:Бутылка
 4:Unknow Device
 5:Жижа
 6:Препядствие
 -}

interface

 Uses Textures, objConsole, sglTxt, Sounds;

 Const MapSize=20;
       FSquareSize=5/MapSize;
       Left=-(FSquareSize*MapSize / 2);
       Bottom=-(FSquareSize*MapSize / 2);
       QPI=Round(2/FSquareSize); //Столько квадратов приходится на одну сторону
       _128=0.5; _64=0.5;
       _256=1;
 Var
       mX,mY:Real;


 Type
      TPointInt = Record
                   X,Y:Integer;
                  End;
      TPoint    = Record
                   X,Y:Real;
                  End;
      TRect     = Record
                   LeftTop,RigthBottom:TPointInt;
                  End;

      TKeys   = Array[0..255] of Boolean;

      TCMethod = set of (cmKeyboard,cmMouse);

      TCh = Record
             X,Y,Z,Orient:Real;
            End;

      TSetOfKeys = Record
                    kLeft,kRight,kForward,kBackward,kStreifL,kStreifR,kSpace:Byte;
                   End;

      TMouse = Record
                X,Y:Real;
                Lbutton,RButton:Boolean;
               End;

      PGame = ^TGame;
      TGameObject = class(TObject)
                     Private
                      FVisible: Boolean;
                     Public
                      procedure   Draw;    virtual;
                     End;

      TGameLand = class(TGameObject)
                   Private
                    FParent   : TObject;
                    FID       : Cardinal;
                    FGround   : Texture;
                    FBorderTex: Texture;
                    FSquares  : Array[0..MapSize-1,0..MapSize-1] of Byte;
                    FBorder   : TRect;
                    Procedure   BuildGLList;
                    Function    GetSquare(X,Y:Integer):Byte;
                   Public
                    Property    Squares[X,Y:Integer]:Byte Read GetSquare;
                    Procedure   LoadMap(vMap:String); virtual;
                    Procedure   Draw; override;
                    Function    XYinBorder(X,Y:Integer):Boolean;
                    Function    GetXY(X,Y:Real):TPointInt;
                    Function    GetSqureCenter(X,Y: Integer):TPoint;
                    Destructor  Destroy; override;
                  End;

      TMinimap   = Class(TGameObject)
                    Private
                     Parent: TObject;
                     X,Y,W,H:Integer;
                     TexID:Integer;
                     TexIdr:Real;
                     dX,dY:Real;
                     FGameland: ^TGameLand;
                    Public
                     Constructor Create;
                     Procedure   Draw; override;
                     Procedure   Step;
                   End;
                   
      TGameBonus = Class(TGameObject)
                    Private
                     FBonusID:    Byte;
                     Fx,Fy:       Real;
                     sX,sY:       Integer;
                     FGameLand:   ^TGameLand;
                     Angle:       Integer;
                     FBSize:      Real;
                     FLife:       Integer;
                    Public
                     Constructor Create(vBonusId:Byte; vX,vY: Integer; vGameLand:Pointer);
                     Procedure   Draw; override;
                     Procedure   Step;
                   End;

      TZhiZha = class(TGameObject)
                 private
                  Parent:TObject;
                  FSize,FSizeMin,FSizeMax: Real;
                  FPulse: Real;
                  TexId:  Byte;
                  FGameLand: ^TGameLand;
                  FActivPoints: array of TPointInt;
                  //FPoinCount: Cardinal;
                  FActiveCount: Cardinal;
                  Water: TSongType;
                  //FSpeed: ShortInt;
                 public
                  Constructor Create;
                  Procedure   Draw; override;
                  Procedure   Respawn;
                  Procedure   Step;
                  Procedure   DestroyPoint(X,Y:Integer);
                  Destructor  Destroy; override;
                End;

      TControl = class(TGameObject)
                  private
                   Parent: TGameOBject;
                   ControlMethod:TCMethod;
                   FKeys: ^TKeys;
                   FMouse: ^TMouse;
                   FSetKeys: TSetOfKeys;
                   MSpeed: Real;
                   MRSpeed: Real;
                  public
                   Property SetKeys:TSetOfKeys write FSetKeys;
                   Constructor Create(vCM:TCMethod; vKeys, vMouse: Pointer);
                   Function GetAction(vCH: TCh):TCh; virtual;
                 end;

      THuman   = class(TControl)
                 end;

      TExplosive = Class(TGameObject)
                    Private
                     Parent:TObject;
                     X,Y:Real;
                     Size:Real;
                     TexId:Byte;
                     TexIDr:Real;
                     RocketExpl: TSongType;
                    Public
                     Constructor Create(vX,vY:Real);
                     destructor  Destroy; override;
                     Procedure Draw; override;
                     Procedure Step;
                   End;

      TBullet  = Class(TGameObject)
                  Private
                   ID:Integer;
                   Parent:TObject;
                   Direction:Real;
                   Speed:Real;
                   X,Y:Real;
                   nowExpl:Boolean;
                   Explose:TExplosive;
                   RocketFly: TSongType;
                   TexIdr: Real;
                   TexID: Integer;
                  Public
                   Constructor Create(vX,vY,vSpeed,vDirection:Real; vParent:TObject);
                   Procedure   Draw; Override;
                   Procedure   DrawFlame; 
                   Procedure   Step;
                   Procedure   Explosive;
                   Destructor  Destroy; override;
                 End;

      TWeapon  = Class(TGameObject)
                  Private
                   Visible:Boolean;
                   Parent:TGameObject;
                   FastReload:Boolean;
                   Fasts:Integer;
                   Power: Real;
                   Direction: Real;
                   StartX,StartY:Real;
                   Rocket: TSongType;
                  Public
                   Constructor Create;
                   Procedure   Shoot; virtual;
                   Procedure   Draw;  Override;
                   Procedure   bFastReload;
                   Procedure   Step;  virtual;
                   Destructor  Destroy; override;
                 End;

      TMaior = class(TGameObject)
                private
                 Die: Boolean;
                 DieID:Integer;
                 DieIDr:Real;
                 Weapon: TWeapon;
                 FGameLand: ^TGameLand;
                 FParent:   TObject;
                 FControl: TControl;
                 FSize: Real;
                 FLightSize: Real;
                 FColor:Array[0..2] of Single;
                 MName: String;
                 MPlaceMent: TPoint;
                 MOrientation: Real;
                 MHealfs: Integer;
                 StepsSound:TSongType;
                 Hill:TSongType;
                 NeedPlay:Boolean;                 
              // MPower: ShortInt;
                public
                 constructor Create(vKeys,vMouse: Pointer; vCM: TCMethod);
                 procedure   Draw; override;
                 procedure   DrawDie;
                 procedure   DrawLights;
                 procedure   SetKeys(vTSet: TSetOfKeys);
                 procedure   Step;
                 destructor  Destroy; override;
               End;

      TCamera = Class(TGameObject)
                 private
                  vX,vZ:Real;   //Скорость
                  EyePos,LookPos:Array[0..2] of Real;
                  FSensifity: Integer;
                 public
                  Constructor Create;
                  Procedure   SetCamera;
                  Procedure   GoToPoint(vPoint:TPoint);
                  Procedure   Step;
                  Function    GetOutRect: TRect;
                  Procedure   Draw; Override;
                End;

      {Объект организующий игровой цикл}
      TGame = Class(TObject)
               private
                FOutRect:      TRect;
                FKeys:         ^TKeys;
                FMouse:        ^TMouse;
                FCamera:       TCamera;
                FLights:       Texture;
                FMaior:        Texture;
                FBonusTex:     Texture;
                FShoot:        Texture;
                FRocket:       Texture;
                FDie:          Texture;
                FDieTiles:     TTiles;
                FFlame:        Texture;
                FFlameTiles:   TTiles;
                FRocketFlame:  Texture;
                FRocketTiles:  TTiles;
                Radar:         Texture;
                RTiles:        TTiles;
                teMiniMap:     Texture;
                FMisionComplete: Texture;
                FGameLand:     TGameLand;
                FMiniMap:      TMinimap;
                FZhizhas:      array of TZhiZha;
                FZhizhasCount: Byte;
                FMaiors:       array of TMaior;
                FMaiorsCount:  Byte;
                FBonuses:      array of TGameBonus;
                FBonusCount:   Byte;
                FTextCTRL:     TTextCtrl;
                BGMusic:       TSongType;
                Timer:         ShortInt;
                FBullets:      Array of TBullet;
                FBCount:       Integer;
                Destroying:    Boolean;
                Procedure      DestroyBonus(I:Integer);
                Procedure      DestroyBullet(I:Integer);
                Procedure      DestroyZhizha(I:Integer);
                Procedure      FreeZhizha(P:TPointInt);
                Procedure      DestroyMaior(I:Integer);
                Procedure      DrawComplete;
               public
                Drawing:    Boolean;
                FConsole:   TConsloe;
                FPS:        String;
                FPSInteger: Integer;
                ShowFPS:    Boolean;
                Complete:   Boolean;
                NotRespaw:  Integer;
                Property    GameLand:TGameLand read FGameLand;
                Constructor Create(vKeys, vMouse: Pointer; vOutRect: TRect);
                Procedure   AddMaior(vCM:TCMethod; vName:String; vPlacment:TPoint);
                Procedure   AddZhizha(ID:Byte; vStart:TPointInt);
                Procedure   AddBullet(vX,vY,vSpeed,vDirection:Real);
                Procedure   AddBonus;
                Function    TakeBonus(X,Y:Integer):Byte;
                Procedure   SetMaiorKeys(Id:Byte; vKeys:TSetOfKeys);
                Procedure   Draw;
                Procedure   Step;
                Procedure      Impulse_101;
                Procedure   ZhRespawn;
                Destructor  Destroy; override;
              End;

implementation

Uses OpenGL15, Math, SysUtils, objsZhiza;

{ TGameObject }

procedure TGameObject.Draw;
begin
end;

{ TGameLand }

procedure TGameLand.BuildGLList;
Var I,J:Byte;
begin
 FID:=glGenLists(1);
 glNewList(FID,GL_COMPILE);
  glColor3f(0.4,0.4,0.4);

  {Как бы земля}
  glBindTexture(GL_TEXTURE_2D, FGround.ID);
  GlBegin(GL_Quads);
   glTexCoord2f(0,0);                 glVertex3f(Left,                    0,Bottom);
   glTexCoord2f(MapSize/3,0);         glVertex3f(Left+MapSize*FSquareSize,0,Bottom);
   glTexCoord2f(MapSize/3,MapSize/3); glVertex3f(Left+MapSize*FSquareSize,0,Bottom+MapSize*FSquareSize);
   glTexCoord2f(0,MapSize/3);         glVertex3f(Left,                    0,Bottom+MapSize*FSquareSize);
  GlEnd;

 glBindTexture(GL_TEXTURE_2D, FBorderTex.ID);

 {Препядствия}
 glColor3f(0.8,0.8,0.8);
 glBegin(GL_Quads);
  For J:=0 To MapSize-1 Do
   For I:=0 To MapSize-1 Do
    IF FSquares[I,J]=6 Then
     Begin
      glTexCoord2f(0,0); glVertex3f(Left+(I-1)*FSquareSize,0,Bottom+(J-1)*FSquareSize);
      glTexCoord2f(0,1); glVertex3f(Left+I*FSquareSize,0,Bottom+(J-1)*FSquareSize);
      glTexCoord2f(1,1); glVertex3f(Left+I*FSquareSize,0,Bottom+J*FSquareSize);
      glTexCoord2f(1,0); glVertex3f(Left+(I-1)*FSquareSize,0,Bottom+J*FSquareSize);
     End;
 glEnd;

 {Збор}
  glBegin(GL_QUADS);
    {Нижний}
    glTexCoord2f(0, 0); glVertex3f(Left-4*FSquareSize,          0,Bottom-4*FSquareSize);
    glTexCoord2f(15,0); glVertex3f(Left+(MapSize+4)*FSquareSize,0,Bottom-4*FSquareSize);
    glTexCoord2f(15,1); glVertex3f(Left+(MapSize+4)*FSquareSize,0,Bottom);
    glTexCoord2f(0, 1); glVertex3f(Left-4*FSquareSize,          0,Bottom);
    {Верхний}
    glTexCoord2f(0, 0); glVertex3f(Left-4*FSquareSize,          0,Bottom+MapSize*FSquareSize);
    glTexCoord2f(15,0); glVertex3f(Left+(MapSize+4)*FSquareSize,0,Bottom+MapSize*FSquareSize);
    glTexCoord2f(15,1); glVertex3f(Left+(MapSize+4)*FSquareSize,0,Bottom+(MapSize+4)*FSquareSize);
    glTexCoord2f(0 ,1); glVertex3f(Left-4*FSquareSize,          0,Bottom+(MapSize+4)*FSquareSize);
    {Правый}
    glTexCoord2f(10,0); glVertex3f(Left-4*FSquareSize,0,Bottom);
    glTexCoord2f(10,1); glVertex3f(Left,              0,Bottom);
    glTexCoord2f(0,1);  glVertex3f(Left,              0,Bottom+MapSize*FSquareSize);
    glTexCoord2f(0,0);  glVertex3f(Left-4*FSquareSize,0,Bottom+MapSize*FSquareSize);
    {Левый}
    glTexCoord2f(10,0); glVertex3f(Left+MapSize*FSquareSize,    0,Bottom);
    glTexCoord2f(10,1); glVertex3f(Left+(MapSize+4)*FSquareSize,0,Bottom);
    glTexCoord2f(0, 1); glVertex3f(Left+(MapSize+4)*FSquareSize,0,Bottom+MapSize*FSquareSize);
    glTexCoord2f(0, 0); glVertex3f(Left+MapSize*FSquareSize,    0,Bottom+MapSize*FSquareSize);
  GLEnd;

 glEndList;
end;

destructor TGameLand.Destroy;
begin
 glDeleteTextures(1,@FGround.ID);
 glDeleteTextures(1,@FBorderTex.ID);
 glDeleteLists(FID,1);
 inherited;
end;

procedure TGameLand.Draw;
begin
 inherited;
 glCallList(FID);
end;


function TGameLand.GetSquare(X, Y: Integer): Byte;
begin
 IF (X>MapSize-1)or(Y>MapSize-1)or(X<0)or(Y<0) Then Result:=255
 Else Result:=FSquares[X,Y];
end;

function TGameLand.GetSqureCenter(X, Y: Integer): TPoint;
begin
 Result.X:=X*FSquareSize+Left;
 Result.Y:=Y*FSquareSize+Bottom;
end;

function TGameLand.GetXY;
begin
 Result.X:=Round((X-Left)/FSquareSize);
 Result.Y:=Round((Y-Bottom)/FSquareSize);
end;

procedure TGameLand.LoadMap(vMap: String);
Var F:TextFile; Line:String; Parent:TGame; I,J:Byte;
begin
 glDeleteTextures(1,@FGround.ID);
 glDeleteLists(1,FID);
 AssignFile(F,vMap);
 Reset(F);
 Readln(F,Line);
{Земля}
 Delete(Line,1,Pos('=',Line));
 glDeleteTextures(1,@FGround.ID);
 glGenTextures(1,@FGround.ID);
 BindNewTexture(FGround,GL_REPEAT,Line,l_JPG);
{Забор}
 Readln(F,Line);
 Delete(Line,1,Pos('=',Line));
 glDeleteTextures(1,@FBorderTex.ID);
 glGenTextures(1,@FBorderTex.ID);
 BindNewTexture(FBorderTex,GL_REPEAT,Line,l_JPG);
{Остальные текстуры}
 Readln(F,Line);
 Delete(Line,1,Pos('=',Line));
 Parent:=(FParent as TGame);
 glDeleteTextures(1,@Parent.FMaior.ID);
 glGenTextures(1,@Parent.FMaior.ID);
 BindNewTexture(Parent.FMaior,GL_REPEAT,Line,l_TGA);

 Readln(F,Line);
 Delete(Line,1,Pos('=',Line));
 glDeleteTextures(1,@Parent.FLights.ID);
 glGenTextures(1,@Parent.FLights.ID);
 BindNewTexture(Parent.FLights,GL_REPEAT,Line,l_JPG);
{Карта}
 //Readln(F,Line);
 For J:=MapSize-1 downTo 0 Do
  For I:=MapSize-1 downTo 0 Do FSquares[I,J]:=0;


 BuildGLList;

 CloseFile(F);
end;

function TGameLand.XYinBorder(X, Y: Integer): Boolean;
begin
 Result:=(X>FBorder.LeftTop.X)and(Y>FBorder.LeftTop.Y)AND
         (X<FBorder.RigthBottom.X)and(Y<FBorder.RigthBottom.Y);
end;

{ TGame }

procedure TGame.AddBonus;
Var X,Y:Byte;
begin
 inc(FBonusCount);
 SetLength(FBonuses,FBonusCount);
 X:=Random(MapSize); Y:=Random(MapSize);
 FBonuses[FBonusCount-1]:=TGameBonus.Create(Random(4),X,Y,@FGameLand);
 FConsole.AddStirng('Новый бонус: ('+IntToStr(X)+','+IntToStr(Y)+')');
end;

procedure TGame.AddBullet(vX, vY, vSpeed, vDirection: Real);
begin
 inc(FBCount);
 SetLength(FBullets,FBCount);
 FBullets[FBCount-1]:=TBullet.Create(vX,vY,vSpeed,vDirection,Self);
 FBullets[FBCount-1].ID:=FBCount-1;
end;

procedure TGame.AddMaior;
begin
 inc(FMaiorsCount);
 SetLength(FMaiors,FMaiorsCount);
 FMaiors[FMaiorsCount-1] := TMaior.Create(FKeys,FMouse,vCM);
 FMaiors[FMaiorsCount-1].FGameLand := @FGameLand;
 FMaiors[FMaiorsCount-1].FParent := Self;
 with FMaiors[FMaiorsCount-1] do
  Begin
   MName:=vName;
   MPlaceMent:=vPlacment;
  End;
end;

procedure TGame.AddZhizha;
begin
 inc(FZhizhasCount);
 SetLength(FZhizhas,FZhizhasCount);
 FZhizhas[FZhizhasCount-1]:=TZhiZha.Create;
 FZhizhas[FZhizhasCount-1].FGameLand:=@FGameLand;
 FZhizhas[FZhizhasCount-1].Parent:=Self;
 FZhizhas[FZhizhasCount-1].TexId:=ID;


 With FZhizhas[FZhizhasCount-1] Do
  Begin
   inc(FActiveCount);
   SetLength(FActivPoints,FActiveCount);
   FActivPoints[0]:=vStart;
   GameLand.FSquares[vStart.X,vStart.Y]:=5;
  End;
end;

constructor TGame.Create;
begin
 ShowFPS:=False;
 Complete:=False;

 OpenFile('Data\Sounds\BGM.wav', BGMusic);

 PlayFile(BGMusic);

 Destroying:=False;
 FOutRect:=vOutRect;
 //
 FTextCTRL:=TTextCtrl.Create;
 FTextCTRL.HorzJustify:=jLeft;
 FTextCTRL.VertJustify:=jBottom;
 FTextCTRL.LoadFont('Data\Fonts\CyrillicGaramond.FoF','Main');
 FTextCTRL.Font:='Main';
 //
 glGenTextures(1,@FBonusTex.ID);
 BindNewTexture(FBonusTex,GL_REPEAT,'Data\Bonuses\BTex.TGA',l_TGA);

 glGenTextures(1,@teMiniMap.ID);
 BindNewTexture(teMiniMap,GL_REPEAT,'Data\Textures\MiniMap.jpg',l_JPG);

 glGenTextures(1,@FMisionComplete.ID);
 BindNewTexture(FMisionComplete,GL_REPEAT,'Data\Textures\Wins.TGA',l_TGA);

 glGenTextures(1,@FShoot.ID);
 BindNewTexture(FShoot,GL_REPEAT,'Data\Textures\Shoot.TGA',l_TGA);

 glGenTextures(1,@FRocket.ID);
 BindNewTexture(FRocket,GL_REPEAT,'Data\Textures\Rocket.TGA',l_TGA);

 glGenTextures(1,@FDie.ID);
 BindNewTexture(FDie,GL_REPEAT,'Data\Textures\Die.jpg',l_JPG);
 FDieTiles:=GetTiles(FDie,64);

 glGenTextures(1,@FFlame.ID);
 BindNewTexture(FFlame,GL_REPEAT,'Data\Textures\explosion4.jpg',l_JPG);
 FFlameTiles:=GetTiles(FFlame,64);

 glGenTextures(1,@FRocketFlame.ID);
 BindNewTexture(FRocketFlame,GL_REPEAT,'Data\Textures\RocketFlame.jpg',l_JPG);
 FRocketTiles:=GetTiles(FRocketFlame,64);

 glGenTextures(1,@Radar.ID);
 BindNewTexture(Radar,GL_REPEAT,'Data\Textures\Radar.jpg',l_JPG);
 RTiles:=GetTiles(Radar,64);
 //
 FKeys:=vKeys;
 FMouse:=vMouse;
 FCamera:=TCamera.Create;
 FGameLand:=TGameLand.Create;
 FGameLand.FParent:=Self;
 FMiniMap:=TMinimap.Create;
 FMiniMap.FGameland:=@FGameLand;
 FMiniMap.Parent:=Self;
 SetLength(FZhizhas,0);
 FZhizhasCount:=0;
 SetLength(FMaiors,0);
 FMaiorsCount:=0;
 SetLength(FBonuses,0);
 FBonusCount:=0;
 SetLength(FBullets,0);
 FBCount:=0;
 FConsole:=TConsloe.Create(Self);
 //
 Timer:=15;
end;

destructor TGame.Destroy;
Var I:ShortInt;
begin
 CloseMusic(BGMusic);

 glDeleteTextures(1, @teMiniMap.ID);
 glDeleteTextures(1, @FMisionComplete.ID);
 glDeleteTextures(1, @FMaior.ID);
 glDeleteTextures(1, @FLights.ID);
 glDeleteTextures(1, @FBonusTex.ID);
 glDeleteTextures(1, @FShoot.ID);
 glDeleteTextures(1, @FRocket.ID);
 glDeleteTextures(1, @FDie.ID);
 glDeleteTextures(1, @FFlame.ID);
 glDeleteTextures(1, @FRocketFlame.ID);
 glDeleteTextures(1, @Radar.ID);

 FMiniMap.Destroy;
 
 For I:=0 To FMaiorsCount-1 Do
  FMaiors[I].Destroy;
 SetLength(FMaiors,0);
 For I:=0 To FZhizhasCount-1 Do
  FZhizhas[I].Destroy;
 For I:=0 To FBonusCount-1 Do
  FBonuses[I].Destroy;
 SetLength(FBonuses,0);
 For I:=0 To FBCount-1 Do
  FBullets[I].Destroy;
 SetLength(FBullets,0);
 FGameLand.Destroy;
 FCamera.Destroy;
 FConsole.Destroy;
 FTextCTRL.Destroy;
 inherited;
end;

procedure TGame.DestroyBonus(I: Integer);
Var J:Integer;
begin
 FBonuses[I].Destroy;
  For J:=I+1 To FBonusCount-1 Do FBonuses[J-1]:=FBonuses[J];
 Dec(FBonusCount);
 SetLength(FBonuses,FBonusCount);
end;

procedure TGame.DestroyBullet(I: Integer);
begin
 Destroying:=True;
 FBullets[I].Destroy;
 IF I<>FBCount-1 Then FBullets[I]:=FBullets[FBCount-1];
 Dec(FBCount);
 SetLength(FBullets,FBCount);
 Destroying:=False;
end;

procedure TGame.DestroyMaior(I: Integer);
begin
 FMaiors[I].Destroy;
 FMaiors[I]:=FMaiors[FMaiorsCount];
 Dec(FMaiorsCount);
 SetLength(FMaiors,FMaiorsCount);
 If FMaiorsCount=0 Then fZhizha.fEndGame;
end;

procedure TGame.DestroyZhizha(I: Integer);
begin
 FZhizhas[I]:=FZhizhas[FZhizhasCount-1];
 Dec(FZhizhasCount);
 SetLength(FZhizhas,FZhizhasCount);
 IF FZhizhasCount=0 Then
  Begin
   Complete:=True;
   FConsole.AddStirng('!!!Миссия Выполнена!!!');
  End;
end;

procedure TGame.Draw;
Var I:ShortInt;
begin
 if Destroying Then Exit;
 glLoadIdentity;
 FCamera.SetCamera;
 //Устанавливаем камеру
 FGameLand.Draw;

 glEnable(GL_BLEND);

 glBindTexture(GL_TEXTURE_2D, FLights.ID);
 glBlendFunc(GL_SRC_ALPHA, GL_ONE);

  For I:=0 To FMaiorsCount-1 Do
   FMaiors[I].DrawLights;

 glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

 glBindTexture(GL_TEXTURE_2D, FBonusTex.ID);
  For I:=0 To FBonusCount-1 Do
   FBonuses[I].Draw;

 glBindTexture(GL_TEXTURE_2D,FMaior.ID);

  For I:=0 To FMaiorsCount-1 Do
   FMaiors[I].Draw;

 glBlendFunc(GL_SRC_ALPHA, GL_ONE);
 glBindTexture(GL_TEXTURE_2D,FDIE.ID);

  For I:=0 To FMaiorsCount-1 Do
   FMaiors[I].DrawDie;

 glBindTexture(GL_TEXTURE_2D, FRocketFlame.ID);
  For I:=0 To FBCount-1 Do
   FBullets[I].DrawFlame;

 glBindTexture(GL_TEXTURE_2D,FRocket.ID);

  For I:=0 To FBCount-1 Do
   FBullets[I].Draw;

 glBindTexture(GL_TEXTURE_2D, FLights.ID);

  For I:=0 To FZhizhasCount-1 Do
   FZhizhas[I].Draw;


 FConsole.IniProjection2D;
 FConsole.Draw;

 IF Complete Then DrawComplete;

// glBindTexture(GL_TEXTURE_2D, teMiniMap.ID);
 glBlendFunc(GL_SRC_ALPHA, GL_ONE);
 glBindTexture(GL_TEXTURE_2D, Radar.ID);
 FMiniMap.Draw;

 glDisable(GL_TEXTURE_2D);
 glDisable(GL_BLEND);
   glColor3f(1,1,1);
   IF ShowFPS Then FTextCTRL.OutText(10,470,'К/C (FPS) - '+FPS);
 glEnable(GL_TEXTURE_2D);

 FConsole.RestoreProjection;

end;

procedure TGame.DrawComplete;
begin
 glBindTexture(GL_Texture_2D, FMisionComplete.ID);
 GLBegin(GL_Quads);
  glTexCoord2f(0,1); glVertex2f(192,208);
  glTexCoord2f(1,1); glVertex2f(448,208);
  glTexCoord2f(1,0); glVertex2f(448,272);
  glTexCoord2f(0,0); glVertex2f(192,272);
 GlEnd;
end;

procedure TGame.FreeZhizha(P: TPointInt);
Var I:Integer;
begin
 For I:=0 To FZhizhasCount-1 Do
  Begin
   FZhizhas[I].DestroyPoint(P.X, P.Y);
   IF FZhizhas[I].FActiveCount<=0 Then
    Begin
     DestroyZhizha(I);
     Exit
    End;
  End;
end;

procedure TGame.Impulse_101;
Var I,J:Integer; XY:TPoint;
begin
 For  J:=0 To MapSize-1 Do
  For  I:=0 To MapSize-1 Do
   Begin
    XY:=FGameLand.GetSqureCenter(J,I);
    AddBullet(XY.X,XY.Y,0.1,0);
   End;
end;

procedure TGame.SetMaiorKeys;
begin
 FMaiors[Id].SetKeys(vKeys);
end;

procedure TGame.Step;
Var I:ShortInt;
begin
 If Destroying Then Exit;
 FCamera.Step;
 FGameLand.FBorder:=FCamera.GetOutRect;
 For I:=0 To FBonusCount-1 Do
  Begin
   FBonuses[I].Step;
   IF FBonuses[I].FLife<=0 Then DestroyBonus(I);
  End;
 For I:=0 To FZhizhasCount-1 Do
  FZhizhas[I].Step;
 I:=0;
 While I<FBCount Do
  Begin
   FBullets[I].Step;
   if (Fbullets[I].nowExpl) and (Fbullets[I].Explose.TexId>Length(FFlameTiles)-1) Then DestroyBullet(I);
   Inc(I)
  End;
 For I:=0 To FMaiorsCount-1 Do
  Begin
   FMaiors[I].Step;
   FCamera.GoToPoint(FMaiors[I].MPlaceMent); //Направляем на него камеру
   IF FMaiors[I].MHealfs<=0 Then {DestroyMaior(I);}FMaiors[I].Die:=True; {DestroyMaior(I);}
  End;
 FMiniMap.Step;
 FConsole.ProcessKeys;
end;

function TGame.TakeBonus(X, Y: Integer): Byte;
Var I:Integer;
begin
 I:=0;
 While (I<FBonusCount)AND((FBonuses[I].sX<>X)OR(FBonuses[I].sY<>Y)) Do Inc(I);
 IF I=FBonusCount Then Result:=128
 Else Begin
       Result:=I;
       FGameLand.FSquares[X,Y]:=0;
       DestroyBonus(I);
      End;
end;

procedure TGame.ZhRespawn;
Var I:Shortint;
begin
 IF NotRespaw>0 Then Begin
                      dec(NotRespaw);
                      Exit;
                     End;
 For I:=0 To FZhizhasCount-1 Do
  FZhizhas[I].Respawn;
 Dec(Timer);
 IF Timer<0 Then
  Begin
   Timer:=15;
   AddBonus;
  End;
end;

{ TMaior }

constructor TMaior.Create;
Var Skeys:TSetOfKeys;
begin
 Die:=False;
 DieID:=0;
 DieIDr:=0;
 
 OpenFile('Data\Sounds\footsteps\boots.wav', StepsSound);
 OpenFile('Data\Sounds\Hill\Hill3.wav', Hill);
 NeedPlay:=False;

 Weapon:=TWeapon.Create;
 Weapon.FastReload:=False;
 Weapon.Parent:=Self;
 Weapon.Visible:=False;

 FControl:=TControl.Create(vCM,vKeys,VMouse);
 FControl.Parent:=Self;
 Skeys.kForward:=87; Skeys.kBackward:=83; Skeys.kStreifL:=68; Skeys.kStreifR:=65;
 Skeys.kSpace:=32;
 SetKeys(Skeys);

 FColor[0]:=0.8; FColor[1]:=0.8;  FColor[2]:=0.4;
 FSize:=0.15;
 FLightSize:=0.5;
 MHealfs:=100;
 MOrientation:=random(314*2)/100;
end;

destructor TMaior.Destroy;
begin
 CloseMusic(StepsSound);
 CloseMusic(Hill);

 Weapon.Destroy;
 FControl.Destroy;
 inherited;
end;

procedure TMaior.Draw;
begin
 inherited;
 IF Die Then Exit;
 glPushMatrix;
  glTranslatef(MPlaceMent.X,0,MPlaceMent.Y);
  {Чел}
  glRotatef(-MOrientation/pi*180+90,0,1,0);
  glColor3f(1,1,1);
  glBegin(GL_Quads);
   glTexCoord2f(0,0); glVertex3f(-FSize,0.005,-FSize);
   glTexCoord2f(1,0); glVertex3f( FSize,0.005,-FSize);
   glTexCoord2f(1,1); glVertex3f( FSize,0.005, FSize);
   glTexCoord2f(0,1); glVertex3f(-FSize,0.005, FSize);
  glEnd;
 glPopMatrix;
 Weapon.Draw
end;

procedure TMaior.DrawDie;
Var gParent:TGame;
begin
 If not Die Then Exit;
 If DieID>32 Then Exit;
 gParent:=TGame(FParent);
 glPushMatrix;
  glTranslatef(MPlaceMent.X,0,MPlaceMent.Y);
  {Чел}
  glRotatef(-MOrientation/pi*180+90,0,1,0);
  glColor3f(1,1,1);
  glBegin(GL_Quads);
   glTexCoord2fv(@gParent.FDieTiles[DieID].Coords[0]);
   glVertex3f(-FSize,0.005,-FSize);
   glTexCoord2fv(@gParent.FDieTiles[DieID].Coords[1]);
   glVertex3f( FSize,0.005,-FSize);
   glTexCoord2fv(@gParent.FDieTiles[DieID].Coords[2]);
   glVertex3f( FSize,0.005, FSize);
   glTexCoord2fv(@gParent.FDieTiles[DieID].Coords[3]);
   glVertex3f(-FSize,0.005, FSize);
  glEnd;
 glPopMatrix;
end;

procedure TMaior.DrawLights;
begin
 glPushMatrix;
  glTranslatef(MPlaceMent.X,0,MPlaceMent.Y);
  {Фонарик}
  glColor3fv(@FColor);
  glBegin(GL_Quads);
   glTexCoord2f(0   ,_128); glVertex3f(-FLightSize,0.002,-FLightSize);
   glTexCoord2f(_128,_128); glVertex3f( FLightSize,0.002,-FLightSize);
   glTexCoord2f(_128,_256); glVertex3f( FLightSize,0.002, FLightSize);
   glTexCoord2f(0   ,_256); glVertex3f(-FLightSize,0.002, FLightSize);
  GlEnd;
 glPopMatrix;
end;

procedure TMaior.SetKeys(vTSet: TSetOfKeys);
begin
 FControl.SetKeys:=vTSet;
end;

procedure TMaior.Step;
Var Ch,OldCh:TCh; NPos:TPointInt;
begin
 IF Die Then
  Begin
   DieIdr:=DieIdr+0.8;
   DieID:=Round(DieIdr);
   Exit
  End;

 OldCh.X:=MPlaceMent.X; OldCh.Z:=MPlaceMent.Y;
 OldCh.Orient:=MOrientation;
 Ch:=FControl.GetAction(OldCh);
 NPos:=FGameLand^.GetXY(Ch.X,Ch.Z);
 MOrientation:=Ch.Orient;
 IF not((NPos.X>MapSize-1)or(NPos.X<1)) Then MPlaceMent.X:=Ch.X;
 IF not((NPos.Y>MapSize-1)or(NPos.Y<1)) Then MPlaceMent.Y:=Ch.Z;
 NPos:=FGameLand^.GetXY(MPlaceMent.X,MPlaceMent.Y);
 Case FGameLand^.GetSquare(NPos.X,NPos.Y) OF
  3:IF TGame(FParent).TakeBonus(NPos.X,NPos.Y)<4 Then Weapon.bFastReload;
  2:IF TGame(FParent).TakeBonus(NPos.X,NPos.Y)<4 Then MHealfs:=MHealfs+50;
  1:IF TGame(FParent).TakeBonus(NPos.X,NPos.Y)<4 Then inc(TGame(FParent).NotRespaw,50);
  4:IF TGame(FParent).TakeBonus(NPos.X,NPos.Y)<4 Then ;
  5:Begin Dec(MHealfs); PlayAndStop(Hill) End;
  6:Begin MPlaceMent.X:=OldCh.X; MPlaceMent.Y:=OldCh.Z End
 End;

 IF NeedPlay Then PlayFile(StepsSound)
             Else StopFile(StepsSound);

 Weapon.StartX:=MPlaceMent.X+0.18*Cos(MOrientation);
 Weapon.StartY:=MPlaceMent.Y+0.18*Sin(MOrientation);
 Weapon.Direction:=MOrientation;
 Weapon.Step;
end;

{ TCamera }

constructor TCamera.Create;
begin
 FSensifity:=50;
 EyePos[0]:=0; EyePos[1]:=0.2; EyePos[2]:=0;
 LookPos[0]:=0; LookPos[1]:=0;  LookPos[2]:=0.001;
 vX:=0; vZ:=0;
end;

procedure TCamera.Draw;
begin
 inherited;
  glDisable(GL_LIGHTING);
  glDisable(GL_DEPTH_TEST);
   glPointSize(20);
   glColor3f(1,0,0);
   glBegin(GL_POINTS);
    glVertex3fv(@EyePos);
   glEnd;
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);
end;

function TCamera.GetOutRect: TRect;
Var Cx,Cy:ShortInt; QPI_DIV_2:Word;
begin
 Cx:=Round((EyePos[0]-Left)/FSquareSize);
 Cy:=Round((EyePos[2]-Bottom)/FSquareSize);
 QPI_DIV_2:= QPI Div 2;
 Result.LeftTop.X     := Cx - QPI_DIV_2 - 2;
 Result.LeftTop.Y     := Cy - QPI_DIV_2 - 2;
 Result.RigthBottom.X := Cx + QPI_DIV_2 + 2;
 Result.RigthBottom.Y := Cy + QPI_DIV_2 + 2;
end;

procedure TCamera.GoToPoint(vPoint: TPoint);
Var Lngth:Real;
begin
 Lngth:=sqrt(Sqr(EyePos[0]-vPoint.X)+Sqr(EyePos[2]-vPoint.Y));
 vX:=vX+(vPoint.X-EyePos[0])*Lngth/FSensifity;
 vZ:=vZ+(vPoint.Y-EyePos[2])*Lngth/FSensifity;
end;

procedure TCamera.SetCamera;
begin
 gluLookAt(EyePos[0],EyePos[1],EyePos[2],LookPos[0],LookPos[1],LookPos[2],0,1,0);
end;

procedure TCamera.Step;
begin
 EyePos[0]:=EyePos[0]+vX;  EyePos[2]:=EyePos[2]+vZ;
 LookPos[0]:=LookPos[0]+vX;  LookPos[2]:=LookPos[2]+vZ;
 vX:=0; vZ:=0;
end;

{ TControl }

constructor TControl.Create;
begin
 ControlMethod:=vCM;
 FKeys:=vKeys;
 FMouse:=vMouse;
 MSpeed:=0.01;
 MRSpeed:=0.05;
end;

function TControl.GetAction;
Var LDown:Boolean; cX,cY:Real;
begin
 cX:=TGame(TMaior(Parent).FParent).FCamera.EyePos[0];
 cY:=TGame(TMaior(Parent).FParent).FCamera.EyePos[2];
 Result.X:=vCH.X;
 Result.Z:=vCH.Z;
 Result.Orient:=vCH.Orient;
 LDown:=(FMouse^.Lbutton) and (cmMouse in ControlMethod);
 TMaior(Parent).NeedPlay:=False;
 IF cmMouse in ControlMethod Then
  Begin
   Result.Orient:=ArcTan2(-(Result.Z-cY)-FMouse^.Y,-(Result.X-cX)-FMouse^.X);
  End;
 IF cmKeyboard in ControlMethod Then
  Begin
   IF FKeys^[FSetKeys.kLeft] Then Result.Orient:=Result.Orient-MRSpeed;
   IF FKeys^[FSetKeys.kRight] Then Result.Orient:=Result.Orient+MRSpeed;
   If FKeys^[FSetKeys.kForward] Then
    Begin
     Result.X:=Result.X+MSpeed*Cos(Result.Orient);
     Result.Z:=Result.Z+MSpeed*Sin(Result.Orient);
     TMaior(Parent).NeedPlay:=True;
    End;
   IF FKeys^[FSetKeys.kBackward] Then
    Begin
     Result.X:=Result.X-MSpeed*Cos(Result.Orient);
     Result.Z:=Result.Z-MSpeed*Sin(Result.Orient);
     TMaior(Parent).NeedPlay:=True;
    End;
   IF FKeys^[FSetKeys.kStreifL] Then
    Begin
     Result.X:=Result.X+MSpeed*Cos(Result.Orient+pi/2);
     Result.Z:=Result.Z+MSpeed*Sin(Result.Orient+pi/2);
     TMaior(Parent).NeedPlay:=True;
    End;
   IF FKeys^[FSetKeys.kStreifR] Then
    Begin
     Result.X:=Result.X-MSpeed*Cos(Result.Orient+pi/2);
     Result.Z:=Result.Z-MSpeed*Sin(Result.Orient+pi/2);
     TMaior(Parent).NeedPlay:=True;
    End;
   IF ((LDown)or(FKeys^[FSetKeys.kSpace]))AND(not TMaior(Parent).Weapon.Visible) Then
    With TMaior(Parent) Do
     Begin
      Weapon.Visible:=True;
      Weapon.Power:=0;
     End;
   IF (not LDown)AND(not FKeys^[FSetKeys.kSpace])AND(TMaior(Parent).Weapon.Visible) Then
    With TMaior(Parent) Do Weapon.Shoot;
  End;
end;

{ TZhiZha }

constructor TZhiZha.Create;
begin
 OpenFile('Data\Sounds\Water.Wav',Water);
 TexId:=0;
 FActiveCount:=0;
 FSizeMin:=0.2;
 FSizeMax:=0.3;
 FPulse:=0.0025;
 FSize:=Random*(FSizeMax-FSizeMin)+FSizeMin;
end;

destructor TZhiZha.Destroy;
begin
 SetLength(FActivPoints,0);
 CloseMusic(Water);
 inherited;
end;

procedure TZhiZha.DestroyPoint(X, Y: Integer);
Var I:Integer;
begin
// IF FGameLand^.Squares[X,Y]<>5 Then Exit;
 I:=0;
 While (I<FActiveCount)AND((FActivPoints[I].X<>X)or(FActivPoints[I].Y<>Y)) Do Inc(I);
 IF I<FActiveCount Then
  Begin
   FActivPoints[I]:=FActivPoints[FActiveCount-1];
   Dec(FActiveCount);
   SetLength(FActivPoints,FActiveCount);
   FGameLand^.FSquares[X,Y]:=0
  End;
end;

procedure TZhiZha.Draw;
Const
     TexCoords:Array[0..2,0..3,0..1] of GLfloat=(((_128,_128),(_256,_128),(_256,_256),(_128,_256)),
                                                 ((_128,   0),(_256,   0),(_256,_128),(_128,_128)),
                                                 ((0,      0),(_128,   0),(_128,_128),(0   ,_128)));
Var I:Shortint;
begin
 glColor3f(1,1,1);
 glBegin(GL_QUADS);

 For I:=0 To FActiveCount-1 Do
  With FActivPoints[I] Do
  If FGameLand^.XYinBorder(X,Y) Then
   Begin
    glTexCoord2fv(@TexCoords[TexID,0]);
    glVertex3f(    Left+X*FSquareSize-FSize, 0.05,     Bottom+Y*FSquareSize-FSize);
    glTexCoord2fv(@TexCoords[TexID,1]);
    glVertex3f(Left+(X+1)*FSquareSize+FSize, 0.05,     Bottom+Y*FSquareSize-FSize);
    glTexCoord2fv(@TexCoords[TexID,2]);
    glVertex3f(Left+(X+1)*FSquareSize+FSize, 0.05, Bottom+(Y+1)*FSquareSize+FSize);
    glTexCoord2fv(@TexCoords[TexID,3]);
    glVertex3f(    Left+X*FSquareSize-FSize, 0.05, Bottom+(Y+1)*FSquareSize+FSize);
  End;
 glEnd;
end;

procedure TZhiZha.Respawn;
Var X,Y:Integer;
    Dx,Dy:Integer;
    XYInt:TPointInt;
    XY:TPoint;
    XY2:TPoint;
    Min,Min2:Real;
    I,MinI:Integer;
begin
  IF TGame(Parent).FMaiorsCount=0 Then Exit;
  PlayAndStop(Water);
  XY:=TGame(Parent).FMaiors[0].MPlaceMent;
  XYInt:=FGameLand^.GetXY(TGame(Parent).FMaiors[0].MPlaceMent.X,TGame(Parent).FMaiors[0].MPlaceMent.Y);
  Min:=99999999;
  MinI:=FActiveCount-1;
  For I:=0 To FActiveCount-1 Do
   Begin
    XY2:=FGameLand^.GetSqureCenter(FActivPoints[I].X,FActivPoints[I].Y);
    Min2:=Sqr(Xy.X-Xy2.X)+Sqr(XY.Y-XY2.Y);
    IF Min2<=Min Then
     Begin
      MinI:=I;
      Min:=Min2
     End;
   End;

  Dx:=XYInt.X-FActivPoints[minI].X; Dx:=Round(Dx/Abs(Dx));
  Dy:=XYInt.Y-FActivPoints[minI].Y; Dy:=Round(Dy/Abs(Dy));
  X:=FActivPoints[minI].X+Dx;
  Y:=FActivPoints[minI].Y+Dy;

  IF FGameLand^.Squares[X,Y]<>0 Then
   Begin
    X:=FActivPoints[minI].X+(Random(3)-1);
    Y:=FActivPoints[minI].Y+(Random(3)-1);
   End;

   IF FGameLand^.Squares[X,Y]=0 Then
    Begin
     inc(FActiveCount);
     SetLength(FActivPoints,FActiveCount);
     FActivPoints[FActiveCount-1].X:=X;
     FActivPoints[FActiveCount-1].Y:=Y;
     FGameLand^.FSquares[X,Y]:=5;
    End;
end;

procedure TZhiZha.Step;
begin
 FSize:=FSize+FPulse;
 IF (FSize>FSizeMax) or (FSize<FSizeMin) Then FPulse:=-FPulse;
end;

{ TGameBonus }

constructor TGameBonus.Create;
Var XY:TPoint;
begin
 FVisible:=True;
 FBonusID:=vBonusId;
 sX:=vX; sY:=vY;
 FGameLand:=vGameLand;
 FGameLand^.FSquares[sX,sY]:=FBonusID+1;
 XY:=FGameLand^.GetSqureCenter(Sx,Sy);
 Fx:=XY.X; Fy:=XY.Y;
 Angle:=Random(361);
 FBSize:=FSquareSize/2;
 FLife:=Random(10000)+1000;
end;

procedure TGameBonus.Draw;
Const
     TexCoords:Array[0..3,0..3,0..1] of GLfloat=(((0,_64),(_64,_64),(_64,1),(0,1)),
                                                 ((_64,_64),(1,_64),(1,1),(_64,1)),
                                                 ((0,0),(_64,0),(_64,_64),(0,_64)),
                                                 ((_64, 0),(1,0),(1,_64),(_64,_64)));
begin
 inherited;
 IF FVisible Then
  Begin
   glPushMatrix;
    glColor4f(1,1,1,1);

    glTranslatef(FX,0,FY);

    glRotatef(Angle,0,1,0);

     glBegin(GL_Quads);
      glTexCoord2fv(@TexCoords[FBonusID,0]);
      glVertex3f(-FBSize,0.05,-FBSize);
      glTexCoord2fv(@TexCoords[FBonusID,1]);
      glVertex3f( FBSize,0.05,-FBSize);
      glTexCoord2fv(@TexCoords[FBonusID,2]);
      glVertex3f( FBSize,0.05, FBSize);
      glTexCoord2fv(@TexCoords[FBonusID,3]);
      glVertex3f(-FBSize,0.05, FBSize);
     GlEnd;

   glPopMatrix;
  End;
end;

procedure TGameBonus.Step;
begin
 inc(Angle,3);
 Dec(FLife);
 IF Angle>360 Then Angle:=Angle-360;
end;

{ TWeapon }

procedure TWeapon.bFastReload;
begin
 FastReload:=True;
 Fasts:=1000;
end;

constructor TWeapon.Create;
begin
 OpenFile('Data\Sounds\Rocket.wav', Rocket);
end;

destructor TWeapon.Destroy;
begin
 CloseMusic(Rocket);
 inherited;
end;

procedure TWeapon.Draw;
Var FSize:Real;
begin
 inherited;
 IF not Visible Then Exit;
 FSize:=0.05;
 glPushMatrix;

  glBindTexture(GL_TEXTURE_2D, TGame(TMaior(Parent).FParent).FShoot.ID);

  glColor4F(1,1,1,1);

  glTranslatef(StartX,0,StartY);
  glRotatef(-Direction/pi*180+90,0,1,0);

  glBegin(GL_QUADS);
    glTexCoord2f(0,0); glVertex3f(-FSize,0.005,-FSize);
    glTexCoord2f(1,0); glVertex3f( FSize,0.005,-FSize);
    glTexCoord2f(1,1); glVertex3f( FSize,0.005, (FSize+1)*Power);
    glTexCoord2f(0,1); glVertex3f(-FSize,0.005, (FSize+1)*Power);
  glEnd;
 glPopMatrix;
end;

procedure TWeapon.Shoot;
begin
 Visible:=False;
 If FastReload Then dec(Fasts);
 If Fasts<0 Then FastReload:=False;
 IF Rocket.Playing Then StopFile(Rocket);
 PlayAndStop(Rocket);
 TGame(TMaior(Parent).FParent).AddBullet(StartX,StartY,0.1/0.5*Power,Direction);
end;

procedure TWeapon.Step;
begin
 inherited;
 IF (Visible) Then
  IF Power<0.5 Then Begin
                     IF FastReload Then Power:=Power+0.03
                     Else Power:=Power+0.015
                    End
               Else Shoot;
end;

{ TBullet }

constructor TBullet.Create(vX, vY, vSpeed, vDirection: Real;
  vParent: TObject);
begin
 TexID:=0; TexIdr:=0;
 X:=vX; Y:=vY; Speed:=vSpeed; Direction:=vDirection; Parent:=vParent;
 nowExpl:=False;
 OpenFile('Data\Sounds\RocketFly.wav', RocketFly);
 PlayFile(RocketFly);
end;

destructor TBullet.Destroy;
begin
 CloseMusic(RocketFly);
 Explose.Destroy;
 inherited;
end;

procedure TBullet.Draw;
Var FSizeX,FSizeY:Real;
begin
 inherited;

 IF nowExpl Then Begin
                  Explose.Draw;
                  exit;
                 End;
 glPushMatrix;

  FSizeX:=0.035; FSizeY:=2*FSizeX;

  glColor4F(1,1,1,1);

  glTranslatef(X,0,Y);
  glRotatef(-Direction/pi*180+90,0,1,0);

  glBegin(GL_QUADS);
    glTexCoord2f(0,0); glVertex3f(-FSizeX,0.005,-FSizeY);
    glTexCoord2f(1,0); glVertex3f( FSizeX,0.005,-FSizeY);
    glTexCoord2f(1,1); glVertex3f( FSizeX,0.005, FSizeY);
    glTexCoord2f(0,1); glVertex3f(-FSizeX,0.005, FSizeY);
  glEnd;

 glPopMatrix;
end;

procedure TBullet.DrawFlame;
Var FSizeX,FSizeY:Real;
    gParent:TGame;
begin
 gParent:=TGame(Parent);
 
 IF nowExpl Then exit;
                 
 If (TexID>Length(gParent.FRocketTiles)-1) Then Exit;
 glPushMatrix;

  FSizeX:=0.1; FSizeY:=1.4*FSizeX;

  glColor4F(1,1,1,1);

  glTranslatef(X,0,Y);
  glRotatef(-Direction/pi*180+270,0,1,0);
  glTranslatef(0,0,0.2);

  glBegin(GL_QUADS);
    glTexCoord2fv(@gParent.FRocketTiles[TexID].Coords[0]);
    glVertex3f(-FSizeX,0.005,-FSizeY);
    glTexCoord2fv(@gParent.FRocketTiles[TexID].Coords[1]);
    glVertex3f( FSizeX,0.005,-FSizeY);
    glTexCoord2fv(@gParent.FRocketTiles[TexID].Coords[2]);
    glVertex3f( FSizeX,0.005, FSizeY);
    glTexCoord2fv(@gParent.FRocketTiles[TexID].Coords[3]);
    glVertex3f(-FSizeX,0.005, FSizeY);
  glEnd;

 glPopMatrix;
end;

procedure TBullet.Explosive;
Var XY:TPointInt;
begin
 nowExpl:=True;
 Explose:=TExplosive.Create(X,Y);
 Explose.Parent:=Parent;
 XY:=TGame(Parent).FGameLand.GetXY(X,Y);
 TGame(Parent).FreeZhizha(XY); XY.Y:=XY.Y-1; TGame(Parent).FreeZhizha(XY);
 XY.X:=XY.X-1;  TGame(Parent).FreeZhizha(XY);
{ TGame(Parent).FreeZhizha(XY);
 TGame(Parent).FreeZhizha(XY);}
end;

procedure TBullet.Step;
begin
 X:=X+Cos(Direction)*Speed;
 Y:=Y+Sin(Direction)*Speed;
 Speed:=Speed-0.001;
 TexIDr:=TexIdr+1;
 TexID:=round(TexIDr);
 IF (Speed<0)and(not nowExpl) Then Explosive;
 IF (nowExpl)and(not TGame(Parent).Destroying) Then Explose.Step;
end;

{ TExplosive }

constructor TExplosive.Create(vX, vY: Real);
begin
 X:=vX; Y:=vY;
 Size:=FSquareSize;
 TexId:=0; TexIDr:=0;
 OpenFile('Data\Sounds\RocketExpl.Wav',RocketExpl);
 PlayFile(RocketExpl);
end;

destructor TExplosive.Destroy;
begin
 CloseMusic(RocketExpl);
 inherited;
end;

procedure TExplosive.Draw;
Var gParent:TGame;
begin
 inherited;

 gParent:=TGame(Parent);

 glPushMatrix;

  glBindTexture(GL_TEXTURE_2D, gParent.FFlame.ID);

  glTranslatef(X,0,Y);

  glBegin(GL_QUADS);
    glTexCoord2fv(@gParent.FFlameTiles[TexID].Coords[0]);
    glVertex3f(-Size,0.005,-Size);
    glTexCoord2fv(@gParent.FFlameTiles[TexID].Coords[1]);
    glVertex3f( Size,0.005,-Size);
    glTexCoord2fv(@gParent.FFlameTiles[TexID].Coords[2]);
    glVertex3f( Size,0.005, Size);
    glTexCoord2fv(@gParent.FFlameTiles[TexID].Coords[3]);
    glVertex3f(-Size,0.005, Size);
  glEnd;

 glBindTexture(GL_TEXTURE_2D, gParent.FRocket.ID);

 glPopMatrix;

end;

procedure TExplosive.Step;
begin
 //Size:=Size+0.001;
 TexIdr:=TexIdr+0.8;
 TexId:=Round(TexIDr);
end;

{ TMinimap }

constructor TMinimap.Create;
begin
 TexID:=0;
 TexIdr:=0;
 W:=100;
 H:=100;
 X:=0;
 Y:=0;
 dX:=W/MapSize;
 dY:=H/MapSize;
end;

procedure TMinimap.Draw;
Var I,J:Byte; gParent:TGame;
begin
 gParent:=TGame(Parent);
 glColor3f(0.7,1,0.7);
 GlBegin(GL_Quads);
  glTexCoord2fv(@gParent.FDieTiles[TexID].Coords[0]);
  glVertex2i(X  , Y);
  glTexCoord2fv(@gParent.FDieTiles[TexID].Coords[1]);
  glVertex2i(X+W, Y);
  glTexCoord2fv(@gParent.FDieTiles[TexID].Coords[2]);
  glVertex2i(X+W, Y+H);
  glTexCoord2fv(@gParent.FDieTiles[TexID].Coords[3]);
  glVertex2i(X  , Y+H);
 GlEnd;
 glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 GLDisable(GL_Texture_2d);
 GLBegin(GL_Quads);
   For I:=0 To MapSize-1 Do
    For J:=0 To MapSize-1 Do
     Begin
      Case FGameland^.GetSquare(I,J) of
       0:   glColor4f(1,1,1,0);
       1..4:glColor4f(1,1,0,0.5);
       5:   glColor4f(1,0,1,0.5);
       6:   glColor4f(0,1,0,0.5);
      End;
      glVertex2f(W-(X+I*dX),H-(Y+J*dY));
      glVertex2f(W-(X+(I+1)*dX),H-(Y+J*dY));
      glVertex2f(W-(X+(I+1)*dX),H-(Y+(J+1)*dY));
      glVertex2f(W-(X+I*dX),H-(Y+(J+1)*dY));
     End;
 GlEnd;
 glColor4f(0.0,0.0,0.0,0.25);
 glBegin(gl_Lines);
  For I:=0 To MapSize-1 Do
     Begin
      glVertex2f(X+I*dX,Y+dY);
      glVertex2f(X+I*dX,Y+H-dY);
      glVertex2f(X+dx,Y+I*dy);
      glVertex2f(X+W-Dx,Y+I*dy);
     End;
 glEnd;  
end;

procedure TMinimap.Step;
begin
 TexIDr:=TexIDr+0.4;
 TexID:=Round(TexIdr);
 IF TexID>31 Then Begin TexID:=0; TexIdr:=0 End;
end;

end.
