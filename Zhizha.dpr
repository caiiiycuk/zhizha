program Zhizha;

uses
  Forms,
  objsZhiza in 'objsZhiza.pas' {fZhizha},
  objects in 'objects.pas',
  loader in 'loader.pas',
  objConsole in 'objConsole.pas',
  glErrors in 'glErrors.pas',
  Functions in 'Functions.pas';

{$R Zhizhka.Res}

begin
  Randomize;
  Application.Initialize;
  Application.CreateForm(TfZhizha, fZhizha);
  Application.Run;
end.
