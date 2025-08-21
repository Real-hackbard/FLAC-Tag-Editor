program FLACTagEditor;

uses
  Forms,
  FLACfileTest in 'FLACfileTest.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
