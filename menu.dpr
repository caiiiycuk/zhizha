program menu;

uses
  Forms,
  menuunit in 'menuunit.pas' {Menuform},
  objsZhiza in 'objsZhiza.pas' {fZhizha};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMenuform, Menuform);
  Application.CreateForm(TfZhizha, fZhizha);
  Application.Run;
end.
