unit objsZhiza;

interface

uses
  Windows,
  Messages,
  Forms,
  objects,
  loader,
  OpenGL15,
  Classes,
  MMSystem,
  ExtCtrls,
  PowerTimers,
  Sounds;

Const
  DrawDelay=1;

type
  TMouseButton = (mbLeft, mbRight, mbMiddle);

  TfZhizha = class(TForm)
    procedure fCreateGame;
    procedure fEndGame;
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure EngineProcess(Sender: TObject);
    procedure CharPressed(var MSG:TWMChar); message WM_CHAR;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    inGame: Boolean;
    FGame: TGame;
    DC:HDC;
    GLRC:HGLRC;
    FKeys: TKeys;
    FMouse: TMouse;
    Timer: TPowerTimer;
    //Timer_Paint: Cardinal;
    //Game_Event: Cardinal;
    GameTicks: Word;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fZhizha: TfZhizha;

implementation

uses SysUtils, Math, Functions, MenuUnit, Dialogs;

{$R *.dfm}

procedure TfZhizha.FormDestroy(Sender: TObject);
begin
 DestroySound;
 fEndGame;
end;

procedure TfZhizha.FormPaint(Sender: TObject);
begin
 FGame.Draw;
 glFlush;
 SwapBuffers(DC);
end;

procedure TfZhizha.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 FKeys[Key]:=True;
end;

procedure TfZhizha.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 FKeys[Key]:=False;
 IF Key=27 Then fEndGame;
end;

procedure TfZhizha.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 FMouse.X:=X/(ClientWidth div 2)-1; FMouse.Y:=Y/(ClientHeight div 2)-1;
end;

procedure TfZhizha.CharPressed(var MSG: TWMChar);
begin
 FGame.FConsole.LastChar:=MSG.CharCode;
end;

procedure TfZhizha.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 FMouse.Lbutton:=False;
end;

procedure TfZhizha.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 FMouse.Lbutton:=True;
end;

procedure TfZhizha.EngineProcess(Sender: TObject);
begin
 IF FGame.FPSInteger<>Timer.FrameRate Then
  Begin
   FGame.FPSInteger:=Timer.FrameRate;
   FGame.FPS:=IntToStr(FGame.FPSInteger)
  End;
 FGame.Step;
 Inc(GameTicks);
 IF GameTicks>=60 Then {Одна секунда}
  Begin
   GameTicks:=0;
   FGame.ZhRespawn;
  End;
end;

procedure TfZhizha.fCreateGame;
Var S,W,H,B:Integer; F:TextFile; OutRect:TRect;
begin
 inGame:=True;
 Visible:=True;

 AssignFile(F,'Options.ini');
 Reset(F);
  Readln(F,S,W,H,B);
 CloseFile(F);

 ClientWidth:=W; ClientHeight:=H;
 OutRect.LeftTop.X:=0; OutRect.LeftTop.Y:=0;
 OutRect.RigthBottom.X:=W; OutRect.RigthBottom.Y:=H;
 //IF S=1 Then SetFullScreenMode(ClientWidth,ClientHeight,B);
 Left:=0; Top:=0;
 {+Инициализация OpenGL}
 DC:=GetDC(Handle);
 GLRC:=CreateRenderingContext(DC,[opDoubleBuffered],B,0,0,0,0,0);
 ActivateRenderingContext(DC,GLRC);

 //Настройки отображения
 glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glViewport(0,0,ClientWidth,ClientHeight);
  gluOrtho2D(-1,1,-1,1);
  //Утснавливаем положение наблюдателя

 glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

 //Настройки OGL
// glEnable(GL_DITHER);
 glEnable(GL_Texture_2D);

 glClearColor(0.3,0.3,0.5,0);
 {-Инициализация OpenGL}

 FGame:=TGame.Create(@FKeys,@FMouse,OutRect);
 CreateGame('loader.ini',FGame);

 Timer:=TPowerTimer.Create(Self);
 Timer.Fps := 50;
 Timer.OnRender  := FormPaint;
 Timer.OnProcess := EngineProcess;
 Timer.OnAppActivate := nil;
 Timer.MayRealTime := false;
 Timer.MayProcess := true;
 Timer.MayRender := true;
end; 

procedure TfZhizha.fEndGame;
begin
 If not inGame Then Exit;
 Timer.Destroy;

 DeactivateRenderingContext;
 DestroyRenderingContext(GLRC);

 FGame.Destroy;
 inGame:=False;
 Visible:=False;
 Menuform.Visible:=True;
 Menuform.Repaint;
end;

procedure TfZhizha.FormCreate(Sender: TObject);
begin
 InitSound(Handle);
 InitOpenGL;
end;

end.
