unit objConsole;

interface

Uses sglTxt,Textures;

 Type
      TKeys   = Array[0..255] of Boolean;

      TRect    = Record
                  Left,Top,Right,Bottom: Integer;
                 End;

      TConsloe = Class(TObject)
                  Private
                   FParent     : TObject;
                   FTextCTRL   : TTextCtrl;
                   FPlaceRect  : TRect;
                   FVisible,FInput:Boolean;
                   FStrings    : Array[0..24] of String;
                   FStrCount   : Shortint;
                   FCharHeight : Word;
                   FOutStrCount: Word;
                   FLastChar   : Word;
                   FTexture    : Texture;
                  Public
                   Property    Visible: Boolean Read FVisible Write FVisible;
                   Property    LastChar: Word write FLastChar;
                   Procedure   IniProjection2D;
                   Procedure   RestoreProjection;
                   Constructor Create(vParent: TObject);
                   Procedure   Draw;
                   Procedure   ProcessKeys;
                   Procedure   AddStirng(vString:String);
                   Destructor  Destroy; override;
                 End;

implementation

Uses OpenGL15, Loader, objects;
{ TConsloe }

procedure TConsloe.AddStirng(vString: String);
Var I:ShortInt;
begin
 IF FStrCount=25 Then
  Begin
   For I:=0 To 23 Do FStrings[I]:=FStrings[I+1];
   FStrings[24]:='>'+vString;
  End
 Else
  Begin
   FStrings[FStrCount]:='>'+vString;
   inc(FStrCount);
  End;
end;

constructor TConsloe.Create;
begin
 FParent:=vParent;

 FLastChar:=0;

 FStrCount:=3;
 FStrings[0]:='>Подключен шрифт - Data\Fonts\CyrillicGaramond.FoF';
 FStrings[1]:='>Консоль включена (~ - переключение консоли).';
 FStrings[2]:='>Загружена консольная текстура - Data\Console.jpg';

 FTextCTRL:=TTextCtrl.Create;
 FTextCTRL.HorzJustify:=jLeft;
 FTextCTRL.VertJustify:=jBottom;
 FTextCTRL.LoadFont('Data\Fonts\CyrillicGaramond.FoF','Standart');
 FTextCTRL.Font:='Standart';

 FPlaceRect.Left:=0; FPlaceRect.Top:=0;
 FPlaceRect.Right:=640; FPlaceRect.Bottom:=200;
 FVisible:=True; FInput:=True;

 FCharHeight:=FTextCTRL.GetMaxHeight;
 FOutStrCount:=(FPlaceRect.Bottom-FPlaceRect.Top-30) div FCharHeight;

 glGenTextures(1,@FTexture.Id);
 BindNewTexture(FTexture,GL_REPEAT,'Data\Console.jpg',l_jpg);
end;

destructor TConsloe.Destroy;
begin
 glDeleteTextures(1,@FTexture.Id);
 FTextCTRL.Destroy;
 inherited;
end;

procedure TConsloe.Draw;
Var I:Byte; Min:ShortInt;
begin
 If FVisible Then
  Begin
   glBindTexture(GL_TEXTURE_2D, FTexture.ID);

   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   glColor4f(0.8,0.8,0.8,0.7);

   GlBegin(GL_QUADS);
    glTexCoord2f(0,0); glVertex2i(FPlaceRect.Left , FPlaceRect.Top);
    glTexCoord2f(1,0); glVertex2i(FPlaceRect.Right, FPlaceRect.Top);
    glTexCoord2f(1,1); glVertex2i(FPlaceRect.Right, FPlaceRect.Bottom);
    glTexCoord2f(0,1); glVertex2i(FPlaceRect.Left , FPlaceRect.Bottom);
   glEnd;

   glColor4f(0,0,0,0.8);
    Min:=FStrCount-1-FOutStrCount;
    IF Min<0 Then Min:=0;
    For I:=Min To FStrCount-1 Do
     FTextCTRL.OutText(10,20+(I-Min)*FCharHeight,FStrings[I]);
  End;
end;

procedure TConsloe.IniProjection2D;
begin
 glMatrixMode(GL_PROJECTION);
  glPushMatrix;
   glLoadIdentity;
   gluOrtho2D(0,640,480,0);
 glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
   glLoadIdentity;
end;

procedure TConsloe.ProcessKeys;
begin
 If (FLastChar=96{~})And(FInput) Then
                                Begin
                                 FVisible:=not FVisible;
                                 FLastChar:=0
                                End;
 If (FInput)and(FVisible) Then
  Begin
   IF FLastChar=13 Then Begin
                         ExecuteComm(FStrings[FStrCount-1],FParent); AddStirng('');
                         FLastChar:=0;
                        End;
   If (FLastChar=8)AND(Length(FStrings[FStrCount-1])>1) Then
                        Begin
                         Delete(FStrings[FStrCount-1],Length(FStrings[FStrCount-1]),1);
                         FLastChar:=0;
                        End;
   If (FLastChar<>0)AND(FLastChar<>8) Then
                        Begin
                         FStrings[FStrCount-1]:=FStrings[FStrCount-1]+chr(FLastChar);
                         FLastChar:=0
                        end;


  End
end;

procedure TConsloe.RestoreProjection;
begin
  glPopMatrix;
 glMatrixMode(GL_PROJECTION);
  glPopMatrix;
 glMatrixMode(GL_MODELVIEW);
end;

end.
