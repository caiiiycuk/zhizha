unit loader;

interface

Uses objects;

  Procedure CreateGame(vFile:String; var vGame:TGame);
  Procedure ExecuteComm(vCommand: String; var obj:TObject);

implementation

uses SysUtils;




  Procedure ExecuteComm(vCommand: String; var obj:TObject);
   Var Name:String; Placment:TPoint; PLint:TPointInt; CMethod:TCMethod; SKeys:TSetOfKeys;
       ID:Byte; vGame:TGame;
   Begin
    vGame:=(obj as TGame);
    IF vCommand[1]<>'>' Then vGame.FConsole.AddStirng(vCommand)
    Else Delete(vCommand,1,1);
    vCommand:=UpperCase(vCommand);
    IF Pos('IMPULSE 101',vCommand)>0 Then
     Begin
      ExecuteComm('SWITCHCONSOLE',obj);
      vGame.Impulse_101;
      Exit
     End;
    IF Pos('SHOWFPS',vCommand)>0 Then
     Begin
      Delete(vCommand,1,Pos('=',vCommand));
      IF vCommand[1]='1' Then vGame.ShowFPS:=True
                         Else vGame.ShowFPS:=False;
      Exit;                   
     End;
    IF Pos('LOADMAP',vCommand)>0 Then
     Begin
      vGame.GameLand.LoadMap(copy(vCommand,9,Length(vCommand)-8));
      vGame.FConsole.AddStirng('Карта загружена.');
      Exit;
     End;
    IF Pos('INITPLAYER',vCommand)>0 Then
     Begin
      Delete(vCommand,1,12);
      try
       Name:=Copy(vCommand,1,Pos(',',vCommand)-1);
       Delete(vCommand,1,Pos(',',vCommand));
       Placment.X:=StrToFloat(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
       Placment.Y:=StrToFloat(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
       CMethod:=[];
       IF Pos('KEY',vCommand)>0 Then CMethod:=CMethod+[cmKeyboard];
       IF Pos('MOUSE',vCommand)>0 Then CMethod:=CMethod+[cmMouse];
      except
      end;
      vGame.AddMaior(CMethod,Name,Placment);
      vGame.FConsole.AddStirng('Игрок добавлен.');
      Exit;
     End;
    IF Pos('SETKEYS',vCommand)>0 Then
     Begin
      Delete(vCommand,1,9);
      try
       ID:=StrToInt(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
       SKeys.kForward:=StrToInt(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
       SKeys.kBackward:=StrToInt(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
       SKeys.kLeft:=StrToInt(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
       SKeys.kRight:=StrToInt(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
       SKeys.kStreifL:=StrToInt(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
       SKeys.kStreifR:=StrToInt(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
       SKeys.kSpace:=StrToInt(Copy(vCommand,1,Pos(']',vCommand)-1));
      except
      end;
      vGame.SetMaiorKeys(ID,SKeys);
      vGame.FConsole.AddStirng('Управление установлено.');
      Exit;
     End;
    IF Pos('INITZHIZHA',vCommand)>0 Then
     Begin
      Delete(vCommand,1,12);
      try
       ID:=StrToInt(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
       PLint.X:=StrToInt(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
       PLint.Y:=StrToInt(Copy(vCommand,1,Pos(',',vCommand)-1));
       Delete(vCommand,1,Pos(',',vCommand));
      except
      end;
      vGame.AddZhizha(ID,PLint);
      vGame.FConsole.AddStirng('Добавлена жижа.');
      Exit;
     End;
    IF Pos('SWITCHCONSOLE',vCommand)>0 Then
     Begin
      vGame.FConsole.Visible:=not vGame.FConsole.Visible;
      Exit;
     End;
   End;

  Procedure CreateGame(vFile:String; var vGame:TGame);
   Var F:TextFile; Line:String; GameObj:TObject;
   Begin
    vGame.FConsole.AddStirng('Использование инициализующего файла - '+vFile);
    AssignFile(F,vFile);
    Reset(F);
     while not eof(F) do
      begin
       Readln(F,Line);
       GameObj:=vGame;
       ExecuteComm(Line,{vGame}GameObj)
      end;
    CloseFile(F);
    vGame.FConsole.AddStirng('');
   End;

begin
 DecimalSeparator:='.';  
end.
