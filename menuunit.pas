unit menuunit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Functions, objsZhiza;

type
  TMenuform = class(TForm)
    fon: TImage;
    newgame: TImage;
    Options: TImage;
    autors: TImage;
    records: TImage;
    exit: TImage;
    vpered: TImage;
    nazad: TImage;
    vyborM: TImage;
    Nastroiki: TImage;
    VyborZ: TImage;
    poexaly: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure newgameMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure newgameMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure autorsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure autorsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure exitMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure exitMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure exitDblClick(Sender: TObject);
    procedure OptionsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OptionsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure recordsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure recordsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure nazadMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure nazadMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure vperedMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure vperedMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OptionsClick(Sender: TObject);
    procedure NastroikiMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NastroikiMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure vyborMMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure vyborMMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure nazadClick(Sender: TObject);
    procedure vyborMClick(Sender: TObject);
    procedure VyborZMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VyborZMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VyborZClick(Sender: TObject);
    procedure recordsClick(Sender: TObject);
    procedure vperedClick(Sender: TObject);
    procedure poexalyClick(Sender: TObject);
    procedure poexalyMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure poexalyMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure newgameDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Menuform: TMenuform;
  S,H,W,D:integer;
  K, L :byte;

implementation

{$R *.dfm}

procedure TMenuform.FormCreate(Sender: TObject);
var F:textfile;
begin
 AssignFile(F,'Options.ini');
 Reset(F);
  Readln(F,S,W,H,D);
 CloseFile(F);
 ClientWidth:=w; ClientHeight:=h;
 menuform.Top:=0;
 menuform.Left:=0;
 SetFullscreenMode(W,H,D);
 Menuform.Color:=ClBlack;
 Poexaly.Top:=round(H/3+0.05*H);
 Poexaly.Left:=round(W/3);
 Poexaly.Picture.LoadFromFile('pictures\поехали.bmp');
end;

procedure TMenuform.poexalyClick(Sender: TObject);
begin
fon.Picture.LoadFromFile('pictures/Original.bmp');
 k:=0;
 POexaly.Visible:=false;
 exit.Visible:=true;
 autors.Visible:=true;
 fon.Visible:=true;
 newgame.Visible:=true;
 options.Visible:=true;
 records.Visible:=true;
 nastroiki.Visible:=false;
 vyborm.Visible:=false;
 vyborz.Visible:=false;
 newgame.Top:=round(H/3+0.05*H);
 newgame.Left:=round(W/3);
 newgame.Picture.LoadFromFile('pictures\новая игра.bmp');
 options.Top:=round(7.2*H/10);
 options.Left:=round(20);
 options.Picture.LoadFromFile('pictures\опции.bmp');
 records.Top:=round(8*H/10);
 records.Left:=round(20);
 records.Picture.LoadFromFile('pictures\рекорды.bmp');
 autors.Top:=round(8.75*H/10);
 autors.Left:=round(20);
 autors.Picture.LoadFromFile('pictures\авторы.bmp');
 exit.Top:=round(0.84*H);
 exit.Left:=round(0.81*w);
 exit.Picture.LoadFromFile('pictures\выход.bmp');
 vpered.Top:=round(0.9*h);
 vpered.Left:=round(w/2+0.5*vpered.Width);
 vpered.Picture.LoadFromFile('pictures\вперед.bmp');
 nazad.Top:=round(0.9*h);
 nazad.Left:=round(w/2-nazad.Width);
 nazad.Picture.LoadFromFile('pictures\назад.bmp');
end;

procedure TMenuform.OptionsClick(Sender: TObject);
begin
k:=0; L:=1;
fon.Picture.LoadFromFile('pictures/Original.bmp');
records.Visible:=false;
options.Visible:=false;
autors.Visible:=false;
newgame.Visible:=false;
exit.Visible:=true;
nastroiki.Visible:=true;
vyborm.Visible:=true;
vyborz.Visible:=true;
nastroiki.Top:=autors.Top;
nastroiki.Left:=autors.Left;
nastroiki.Picture.LoadFromFile('pictures\настройки.bmp');
vyborm.Top:=options.Top;
vyborm.Left:=options.Left;
vyborm.Picture.LoadFromFile('pictures\выбор майор.bmp');
vyborz.Top:=records.Top;
vyborz.Left:=records.Left;
vyborz.Picture.LoadFromFile('pictures\выбор зеленая.bmp');
end;

procedure TMenuform.FormDestroy(Sender: TObject);
begin
 RestoreScreenMode;
end;

procedure TMenuform.vyborMClick(Sender: TObject);
begin
k:=1; L:=2;
fon.Picture.LoadFromFile('pictures\майор.bmp');
vyborm.Visible:=false;
vyborz.Visible:=false;
nastroiki.Visible:=false;
exit.Visible:=false;
end;

procedure TMenuform.VyborZClick(Sender: TObject);
begin
k:=1; L:=3;
fon.Picture.LoadFromFile('pictures\зеленая.bmp');
vyborm.Visible:=false;
vyborz.Visible:=false;
nastroiki.Visible:=false;
exit.Visible:=false;
end;

procedure TMenuform.recordsClick(Sender: TObject);
begin
k:=0; L:=4;
newgame.Visible:=false;
exit.Visible:=false;
records.Visible:=false;
autors.Visible:=false;
options.Visible:=false;
fon.Picture.LoadFromFile('pictures\рекорды фон.bmp');
end;

procedure TMenuform.nazadClick(Sender: TObject);
begin
case k of
0: poexalyClick(sender);
1: optionsclick(sender);
end;
end;

procedure TMenuform.vperedClick(Sender: TObject);
begin
case K of
1: OptionsClick(sender);
2: VyborMClick(sender);
3: VyborZclick(sender);
end;
end;

procedure TMenuform.newgameMouseDown(Sender: TObject; Button: TMouseButton;
 Shift: TShiftState; X, Y: Integer);
begin
 NEWGAME.Picture.LoadFromFile('pictures\новая игра 2.bmp');
end;

procedure TMenuform.newgameMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 NEWGAME.Picture.LoadFromFile('pictures\новая игра.bmp');
end;

procedure TMenuform.autorsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

 autors.Picture.LoadFromFile('pictures\авторы 2.bmp');
end;

procedure TMenuform.autorsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 autors.Picture.LoadFromFile('pictures\авторы.bmp');
end;

procedure TMenuform.exitMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 exit.Picture.LoadFromFile('pictures\выход 2.bmp');
end;

procedure TMenuform.exitMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 exit.Picture.LoadFromFile('pictures\выход.bmp');
end;

procedure TMenuform.exitDblClick(Sender: TObject);
begin
 exit.Picture.LoadFromFile('pictures\выход 2.bmp');
 close
end;

procedure TMenuform.OptionsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  options.Picture.LoadFromFile('pictures\опции 2.bmp');
end;

procedure TMenuform.OptionsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  options.Picture.LoadFromFile('pictures\опции.bmp');
end;

procedure TMenuform.recordsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  records.Picture.LoadFromFile('pictures\рекорды 2.bmp');
end;

procedure TMenuform.recordsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  records.Picture.LoadFromFile('pictures\рекорды.bmp');
end;

procedure TMenuform.nazadMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 nazad.Picture.LoadFromFile('pictures\назад 2.bmp');
end;

procedure TMenuform.nazadMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 nazad.Picture.LoadFromFile('pictures\назад.bmp');
end;

procedure TMenuform.vperedMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  vpered.Picture.LoadFromFile('pictures\вперед.bmp');
end;

procedure TMenuform.vperedMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  vpered.Picture.LoadFromFile('pictures\вперед 2.bmp');
end;



procedure TMenuform.NastroikiMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 nastroiki.Picture.LoadFromFile('pictures\настройки 2.bmp');
 end;

procedure TMenuform.NastroikiMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
nastroiki.Picture.LoadFromFile('pictures\настройки.bmp');
end;

procedure TMenuform.vyborMMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 vyborm.Picture.LoadFromFile('pictures\выбор майор 2.bmp');
end;

procedure TMenuform.vyborMMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  vyborm.Picture.LoadFromFile('pictures\выбор майор.bmp');
end;



procedure TMenuform.VyborZMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 vyborz.Picture.LoadFromFile('pictures\выбор зеленая 2.bmp');
end;

procedure TMenuform.VyborZMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 vyborz.Picture.LoadFromFile('pictures\выбор зеленая.bmp');
end;

procedure TMenuform.poexalyMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 poexaly.Picture.LoadFromFile('pictures\поехали 2.bmp');
end;

procedure TMenuform.poexalyMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  poexaly.Picture.LoadFromFile('pictures\поехали.bmp');
end;

procedure TMenuform.newgameDblClick(Sender: TObject);
begin
 Visible:=False;
 fZhizha.fCreateGame;
end;

end.
