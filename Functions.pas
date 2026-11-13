unit Functions;

interface

 Function SetFullScreenMode(Width, Height: Integer; ColorDepth:Byte) : Boolean;
 Procedure RestoreScreenMode;

implementation
 Uses Windows;

  Function SetFullscreenMode(Width, Height: Integer; ColorDepth:Byte) : Boolean;
   Var
    DeviceMode : TDevMode;
   Begin
    With DeviceMode do begin
     dmSize := SizeOf(DeviceMode);
     dmBitsPerPel := ColorDepth;
     dmPelsWidth := Width;
     dmPelsHeight := Height;
     dmFields := DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT;
     //??????? ???????????? ??????
     Result := ChangeDisplaySettings(DeviceMode,CDS_FULLSCREEN) = DISP_CHANGE_SUCCESSFUL;
    End;
   End;

 Procedure RestoreScreenMode;
  Begin
   ChangeDisplaySettings(DevMode(nil^), 0);
  End;

end.
