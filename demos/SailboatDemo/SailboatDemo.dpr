program SailboatDemo;
uses
  System.StartUpCopy,
  FMX.Forms,
  fSailboatDemo in 'fSailboatDemo.pas' {FormSailboatDemo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormSailboatDemo, FormSailboatDemo);
  Application.Run;
end.
