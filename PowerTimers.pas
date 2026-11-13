unit PowerTimers;
//---------------------------------------------------------------------------
// TPowerTimer v2.0 (c) 2001 - 2003
// Written by Lifepower (lifepower@fromru.com)
//
// NOTE: TPowerTimer replaces some Application events but provides you with
// the same events, but from TPowerTimer class.
//---------------------------------------------------------------------------
interface

//---------------------------------------------------------------------------
uses
 Windows, SysUtils, Classes, Forms;

//---------------------------------------------------------------------------
type
 TRealTimeEvent = procedure(Sender: TObject; Delta: Double) of object;

 TPowerTimer = class(TComponent)
 private
  FCouldRender,
  FMayRender,
  FMayProcess,
  FMayRealTime,
  FOverrun,
  FUnderrun: Boolean;
  FOnIdle: TNotifyEvent;
  FOnActivate,
  FOnDeactivate: TNotifyEvent;

  HPCounter: Boolean;
  HPFrequency: Int64;
  OldHPTime: Int64;

  OldFastTime: DWord;
  OldTime: DWord;

  FastFrameRate,
  Ticks,
  MaxTicks: Integer;

  RTValue: Double;

  FFrameRate,
  FFPS: Integer;

  FOnRender: TNotifyEvent;
  FOnProcess: TNotifyEvent;
  FOnRealTime: TRealTimeEvent;

  procedure SetFPS(NewFPS: Integer);
  procedure UpdateFastFrameRate();
  procedure UpdateFrameRate();
  procedure SetRender(Value: Boolean);

  procedure AppIdle(Sender: TObject; var Done: Boolean);
  procedure AppActivate(Sender: TObject);
  procedure AppDeactivate(Sender: TObject);
 public
  property FrameRate: Integer read FFrameRate;
  property Overrun: Boolean read FOverrun;
  property Underrun: Boolean read FUnderrun;

  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;

 published
  property FPS: Integer read FFPS write SetFPS;
  property MayProcess: Boolean read FMayProcess write FMayProcess;
  property MayRender: Boolean read FMayRender write SetRender;
  property MayRealTime: Boolean read FMayRealTime write FMayRealTime;
  property OnRender: TNotifyEvent read FOnRender write FOnRender;
  property OnProcess: TNotifyEvent read FOnProcess write FOnProcess;
  property OnRealTime: TRealTimeEvent read FOnRealTime write FOnRealTime;
  property OnAppIdle: TNotifyEvent read FOnIdle write FOnIdle;
  property OnAppActivate: TNotifyEvent read FOnActivate write FOnActivate;
  property OnAppDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
 end;

//---------------------------------------------------------------------------
implementation

//---------------------------------------------------------------------------
constructor TPowerTimer.Create(AOwner: TComponent);
begin
 inherited;

 if (not (csDesigning in ComponentState)) then
  begin
   HPCounter:= QueryPerformanceFrequency(HPFrequency);

   if (HPCounter) then
    QueryPerformanceCounter(OldHPTime)
     else OldFastTime:= GetTickCount;

   OldTime:= OldFastTime;

   Application.OnIdle:= AppIdle;
   Application.OnActivate:= AppActivate;
   Application.OnDeactivate:= AppDeactivate;
  end;

 MaxTicks:= 30;
 FMayProcess:= False;
 FMayRender:= False;
 FCouldRender:= False;
 FMayRealTime:= False;

 FFPS:= 60;
end;

//---------------------------------------------------------------------------
destructor TPowerTimer.Destroy();
begin
 if (not (csDesigning in ComponentState)) then
  begin
   Application.OnIdle:= nil;
   Application.OnActivate:= nil;
   Application.OnDeactivate:= nil;
  end;

 inherited;
end;

//---------------------------------------------------------------------------
procedure TPowerTimer.SetFPS(NewFPS: Integer);
begin
 if (NewFPS < 1)or(NewFPS > 240) then Exit;

 FFPS:= NewFPS;
end;

//---------------------------------------------------------------------------
procedure TPowerTimer.SetRender(Value: Boolean);
begin
 // if can't render now - leave
 if (not FMayRender)and(FCouldRender)and(Value) then Exit;

 FMayRender:= Value;
 FCouldRender:= Value;
end;

//---------------------------------------------------------------------------
procedure TPowerTimer.UpdateFastFrameRate();
var
 NewTime: DWord;
 NewHPTime, Delta: Int64;
begin
 if (HPCounter) then
  begin
   // use high-performance counter
   QueryPerformanceCounter(NewHPTime);

   Delta:= Abs(NewHPTime - OldHPTime);
   OldHPTime:= NewHPTime;

   if (Delta > 0) then
    FastFrameRate:= Round(HPFrequency / Delta)
     else FastFrameRate:= High(Integer);

  end else
  begin
   // use GetTickCount() routine
   NewTime:= GetTickCount();
   Delta:= Abs(NewTime - OldFastTime);
   OldFastTime:= NewTime;

   if (Delta > 0) then
    FastFrameRate:= Round(1000 / Delta)
     else FastFrameRate:= High(Integer);
  end;
end;

//---------------------------------------------------------------------------
procedure TPowerTimer.UpdateFrameRate();
var
 NewTime, Delta: DWord;
begin
 NewTime:= GetTickCount();
 Delta:= NewTime - OldTime;
 OldTime:= NewTime;
 if (Delta > 0) then
  FFrameRate:= Round(Ticks * 1000 / Delta)
   else FFrameRate:= 0;
end;

//---------------------------------------------------------------------------
procedure TPowerTimer.AppIdle(Sender: TObject; var Done: Boolean);
var
 i: Integer;
begin
 Done:= False;

 FUnderrun:= False;
 FOverrun:= False;

 // exit if no routines are called
 if (not FMayRender)and(not FMayProcess)and(not FMayRealTime) then Exit;

 // update fast frame rate used for OnProcess and OnRealTime events
 UpdateFastFrameRate();

 // update average frame rate
 Inc(Ticks);
 if (Ticks > MaxTicks) then
  begin
   UpdateFrameRate();

   Ticks:= 0;
   MaxTicks:= 19;
   if (FrameRate > 20) then MaxTicks:= 29;
   if (FrameRate > 44) then MaxTicks:= 59;
   if (FrameRate > 65) then MaxTicks:= 74;
   if (FrameRate > 100) then MaxTicks:= 200;
   if (FrameRate > 250) then MaxTicks:= 500;
  end;

 // calculate Real-time value
 if (FastFrameRate <> 0) then RTValue:= RTValue + (FFPS / FastFrameRate)
  else
   begin // timer underrun
    RTValue:= 1;
    FUnderrun:= True;
   end;

 // timer overrun
 if (RTValue > 8) then
  begin
   RTValue:= 8;
   FOverrun:= True;
  end;

 // rendering
 if (FMayRender)and(Assigned(FOnRender)) then FOnRender(Self);
 // real-time processing
 if (FMayRealTime)and(FastFrameRate <> 0)and(Assigned(FOnRealTime)) then FOnRealTime(Self, (FFPS / FastFrameRate));
 // normal processing
 if (FMayProcess)and(Assigned(FOnProcess)) then
  begin
   for i:= 1 to Trunc(RTValue) do
    FOnProcess(Self);
  end;

 RTValue:= RTValue - Trunc(RTValue);

 if (Assigned(FOnIdle)) then
  FOnIdle(Sender);
end;

//---------------------------------------------------------------------------
procedure TPowerTimer.AppActivate(Sender: TObject);
begin
 if (FCouldRender) then
  begin
   FMayRender:= True;
   FCouldRender:= False;
  end;

  OldTime:= GetTickCount;
  Ticks:= 0;
  MaxTicks:= 19;

 if (Assigned(FOnActivate)) then
  FOnActivate(Sender);
end;

//---------------------------------------------------------------------------
procedure TPowerTimer.AppDeactivate(Sender: TObject);
begin
 if (FMayRender) then
  begin
   FMayRender:= False;
   FCouldRender:= True;
  end;

 if (Assigned(FOnDeactivate)) then
  FOnDeactivate(Sender);
end;

//---------------------------------------------------------------------------
end.

