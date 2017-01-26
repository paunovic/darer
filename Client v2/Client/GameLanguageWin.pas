unit GameLanguageWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SkinCtrls, SkinBoxCtrls, SkinExCtrls, DynamicSkinForm;

type
  TGameLanguageWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    lbSelectGameLang: TspSkinShadowLabel;
    cbGameLanguage: TspSkinComboBox;
    btOK: TspSkinButton;
    procedure btOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  GameLanguageWindow: TGameLanguageWindow;

implementation

{$R *.dfm}

uses
  SharedData, SharedVars, ComponentModule;

procedure TGameLanguageWindow.btOKClick(Sender: TObject);
begin
  Options.WC3.Language := cbGameLanguage.Text;
  Close;
end;

procedure TGameLanguageWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TGameLanguageWindow.FormCreate(Sender: TObject);
begin
  ComponentModuleWindow.FillGameLanguages(cbGameLanguage);
end;

end.
