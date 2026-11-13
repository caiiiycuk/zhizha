unit sglTxt;

interface

 Uses Windows, OpenGL15;

 Const jLeft   = $0001; //
       jCenter = $0002; //
       jRight  = $0003; //Констатнты форматирования
       jTop    = $0004; //   текста.
       jMiddle = $0005; //
       jBottom = $0006; //


 Type
      TChar = Record
               Metrics: _GLYPHMETRICS;
               Data: Pointer;
              End;

      TFont = Record
               Index: GLuint;
               Name : String;
               Chars: Array[0..255] of TChar;
              End;

      TTextCtrl = Class(TObject)
                   private
                    FHorzJystify:Byte;
                    FVertJystify:Byte;
                    FSelectedFont: ^TFont;
                    FFonts: Array of TFont;
                    Procedure FreeFont(var vFont: TFont);
                    Procedure BuildFontLists(var vFont: TFont);
                    Procedure SetFontByName(const FName:String);
                    Procedure SetFontByID(ID:LongInt);
                    Function  GetFontName:String;
                    Procedure SetHJystify(JType: Byte);
                    Procedure SetVJystify(JType: Byte);
                   public
                    Constructor Create; virtual;
                    Procedure   LoadFont(const FileName,FName:String); virtual;
                    Procedure   DeleteFont(const FName:String);
                    Function    GetTextWidth(Text:String):LongInt;
                    Function    GetTextHeight(Text:String):Word;
                    Function    GetMaxHeight:Word;
                    Procedure   OutText(X,Y:Integer; Text:String); virtual;
                    Destructor  Destroy; override;
                    Property    Font:String read GetFontName write SetFontByName;
                    Property    FontID:LongInt write SetFontByID;
                    Property    HorzJustify:Byte Read FHorzJystify Write SetHJystify;
                    Property    VertJustify:Byte Read FVertJystify Write SetVJystify;
                  End;
implementation

uses Math;

{ TTextCtrl }

constructor TTextCtrl.Create;
begin
 Inherited;
 FHorzJystify:=jCenter;
 FVertJystify:=jBottom;
 FSelectedFont:=nil;
 SetLength(FFonts,0);
end;

procedure TTextCtrl.LoadFont(const FileName, FName: String);
Var F:File; I:Byte; DataSize:LongInt;
begin
 SetLength(FFonts,Length(FFonts)+1);
 AssignFile(F,FileName);
 Reset(F,1);
  For I:=0 To 255 Do
   With FFonts[Length(FFonts)-1].Chars[I] Do
    Begin
     BlockRead(F,Metrics,SizeOf(Metrics)); //Характеристики буквы
     BlockRead(F,DataSize,SizeOf(DataSize)); //Размер изображения
     GetMem(Data,DataSize);
     BlockRead(F,Data^,DataSize);
    End;
  FFonts[Length(FFonts)-1].Name:=FName;
 CloseFile(F);
 //Создание списков отображения
 BuildFontLists(FFonts[Length(FFonts)-1]);
end;

procedure TTextCtrl.SetFontByName(const FName: String);
Var I,Last:LongInt;
begin
 I:=0;
 Last:=Length(FFonts)-1;
 While (Last>=I)AND(FFonts[I].Name<>FName) Do Inc(I);
 IF Last>=I Then FSelectedFont:=@FFonts[I]
end;

procedure TTextCtrl.SetFontByID(ID: Integer);
begin
 FSelectedFont:=@FFonts[ID]
end;

procedure TTextCtrl.DeleteFont(const FName: String);
Var I,Last:LongInt;
begin
 I:=0;
 Last:=Length(FFonts)-1;
 While (Last>=I)AND(FFonts[I].Name<>FName) Do Inc(I);
 IF Last>=I Then
  Begin
   FFonts[I]:=FFonts[Last];
   FreeFont(FFonts[Last]);
   SetLength(FFonts,Last);
  End;
end;

procedure TTextCtrl.FreeFont(var vFont: TFont);
Var I:Byte;
begin
 glDeleteLists(vFont.Index,256);
 For I:=0 To 255 Do
  FreeMem(vFont.Chars[I].Data);
end;

procedure TTextCtrl.BuildFontLists(var vFont: TFont);
Var I:Byte; Data:Pointer;
begin
 With vFont Do
  Begin
   Index:=glGenLists(255);
   For I:=0 To 255 Do
    Begin
     glNewList(Index+I,GL_COMPILE);
      With Chars[I].Metrics Do
       Begin
        If Chars[I].Data<>Nil Then
         glBitmap(gmBlackBoxX,gmBlackBoxY,gmptGlyphOrigin.X,gmptGlyphOrigin.Y,
                  gmCellIncX,gmCellIncY,Chars[I].Data)
        Else Begin
              GetMem(Data,gmBlackBoxX*gmBlackBoxY);
              FillMemory(Data,gmBlackBoxX*gmBlackBoxY,0);
              glBitmap(gmBlackBoxX,gmBlackBoxY,gmptGlyphOrigin.X,gmptGlyphOrigin.Y,
                       gmCellIncX,gmCellIncY,Data);
              FreeMem(Data);
             End;
       End;
     glEndList;
    End;
  End;
end;

destructor TTextCtrl.Destroy;
Var I:Integer;
begin
 For I:=0 To Length(FFonts)-1 Do FreeFont(FFonts[I]);
 SetLength(FFonts,0);
 Inherited;
end;

procedure TTextCtrl.OutText(X, Y: Integer; Text: String);
begin
 IF FSelectedFont<>Nil Then
  Begin
   Case FHorzJystify of
    jCenter: X:=X-GetTextWidth(Text) div 2;
    jRight:  X:=X-GetTextWidth(Text);
   End;
   Case FVertJystify of
    jMiddle: Y:=Y+GetTextHeight(Text) div 2;
    jTop:    Y:=Y+GetTextHeight(Text);
   End;
   glRasterPos2i(X,Y);
   glListBase(FSelectedFont^.Index);
   glCallLists(Length(Text),GL_UNSIGNED_BYTE,PChar(Text))
  End 
end;

function TTextCtrl.GetFontName: String;
begin
 Result:=FSelectedFont^.Name
end;

function TTextCtrl.GetTextWidth(Text: String): LongInt;
Var I,L:Integer;
begin
 L:=Length(Text);
 Result:=0;
 For I:=1 To L Do Inc(Result,FSelectedFont^.Chars[ord(Text[I])].Metrics.gmCellIncX);
end;

function TTextCtrl.GetTextHeight(Text: String): Word;
Var I,L:Integer;
begin
 L:=Length(Text);
 Result:=0;
 For I:=1 To L Do
  With FSelectedFont^.Chars[ord(Text[I])].Metrics Do
   IF Result<gmBlackBoxY Then Result:=gmBlackBoxY;
end;

procedure TTextCtrl.SetHJystify(JType: Byte);
begin
 IF (JType=jLeft)or(JType=jCenter)or(JType=jRight) Then FHorzJystify:=JType
end;

procedure TTextCtrl.SetVJystify(JType: Byte);
begin
 IF (JType=jTop)or(JType=jMiddle)or(JType=jBottom) Then FVertJystify:=JType
end;

function TTextCtrl.GetMaxHeight: Word;
Var I:Integer;
begin
 Result:=0;
 For I:=0 To 255 Do
  With FSelectedFont^.Chars[I].Metrics Do
   IF Result<gmBlackBoxY Then Result:=gmBlackBoxY;
end;

end.
