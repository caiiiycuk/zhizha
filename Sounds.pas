unit Sounds;

interface

Uses Fmod,FmodTypes,Windows;

type
  PSongType=^TSongType;
  TSongType = record
    Module: PFMusicModule;
    Stream: PFSoundStream;
    Channel: Integer;
    Playing: Boolean;
  end;

Function InitSound(Hwnd:Thandle):String;
Function OpenFile(Files:String; Var Music:TSongType):String;
Procedure PlayFile(Var Music:TSongType);
Procedure SetVolume(Var Music:TSongType; Volume:Integer);
Procedure StopFile(Var Music:TSongType);
Procedure CloseMusic(Var Music:TsongType);
Procedure PlayAndStop(Var Music:TsongType);
Procedure DestroySound;

implementation

Function InitSound(Hwnd:Thandle):String;
 Begin
  If Not FSOUND_SetOutput(FSOUND_OUTPUT_DSOUND) Then Result:='Неудалось обнаружть звуковую карту';
  If Not FSOUND_SetDriver(0) Then Result:='Не подключаеться звуковой драйвер';
  FSOUND_SetMixer(FSOUND_MIXER_QUALITY_AUTODETECT);
  FSOUND_SetHWND(Hwnd);
  If Not FSOUND_Init(44050, 256, 0) Then
   Begin FSOUND_Init(22050, 128, 0); Result:='22Кгц' End
  Else Result:='44Кгц';
 End;

Procedure DestroySound;
 Begin
  FSOUND_Close;
 End;

Function OpenFile(Files:String; Var Music:TSongType):String;
 Begin
  Music.Stream:=Nil;
  Music.Module:=FMUSIC_LoadSong(Pchar(Files));
  If Music.Module = Nil Then Music.Stream := FSOUND_Stream_OpenFile(PChar(Files), FSOUND_NORMAL or FSOUND_LOOP_NORMAL, 0);
  If (Music.Stream=nil)and(Music.Module=Nil) Then Result:='Файл нелоступен'
  Else Result:=Files+'.. успешно открыт.'
 End;

Procedure SetVolume(Var Music:TSongType; Volume:Integer);
Begin
 FSOUND_SetVolume(Music.Channel,Volume)
End;

Procedure PlayFile(Var Music:TSongType);
 Begin
  If Music.Module<>Nil Then Music.Playing:=FMUSIC_PlaySong(Music.Module);
  If Music.Stream<>Nil Then
   Begin
    Music.Channel:=FSOUND_Stream_Play(FSOUND_FREE,Music.Stream);
    Music.Playing:=Music.Channel>=0;
    If Music.Playing Then
     Begin
      FSOUND_SetPan(Music.Channel, FSOUND_STEREOPAN);
      FSOUND_SetVolume(Music.Channel, 255);
     End;
   End;
 End;

Procedure StopFile(Var Music:TSongType);
 Begin
  If Music.Module <> nil then FMUSIC_StopSong(Music.Module);
  If Music.Stream <> nil then FSOUND_Stream_Stop(Music.Stream);
  Music.Playing := False;
 End;

Procedure CloseMusic(Var Music:TsongType);
 Begin
  if Music.Module <> nil then FMUSIC_FreeSong(Music.Module);
  if Music.Stream <> nil then FSOUND_Stream_Close(Music.Stream);
 End;

Procedure PlayAndStop(Var Music:TsongType);
 Begin
  If Music.Stream<>Nil Then
   Begin
    FSOUND_Stream_SetMode(Music.Stream,1);
    PlayFile(Music);
    FSOUND_Stream_SetMode(Music.Stream,0);
   End; 
 End;

end.
