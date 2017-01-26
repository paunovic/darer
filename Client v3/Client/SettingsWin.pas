unit SettingsWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Menus, SkinMenus, DynamicSkinForm, SkinCtrls, StdCtrls, Mask, SkinBoxCtrls,
  spSkinShellCtrls, SkinExCtrls, pngimage, ExtCtrls, ComCtrls, SkinTabs, Localization,
  ImgList, PngImageList;

type
  TSettingsWindow = class(TForm, ILocalizationChanged)
    SkinForm: TspDynamicSkinForm;
    btOK: TspSkinButton;
    btCancel: TspSkinButton;
    pcSettings: TspSkinPageControl;
    tsClient: TspSkinTabSheet;
    tsDota: TspSkinTabSheet;
    lbLanguage: TspSkinShadowLabel;
    chbStartup: TspSkinCheckRadioBox;
    chbMinimizeOnLogin: TspSkinCheckRadioBox;
    lbWarcraftPath: TspSkinShadowLabel;
    dirWarcraft: TspSkinFileEdit;
    btDetect: TspSkinButton;
    imgClientBackground: TImage;
    imgDotaBackground: TImage;
    cbLanguages: TspSkinComboBox;
    spSkinPanel1: TspSkinPanel;
    spSkinPanel2: TspSkinPanel;
    spSkinPanel3: TspSkinPanel;
    spSkinPanel4: TspSkinPanel;
    ilFlags: TPngImageList;
    chbAdMessage: TspSkinCheckRadioBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btDetectClick(Sender: TObject);
    procedure btOKClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure dirWarcraftChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbLanguagesChange(Sender: TObject);
  private
    oldWarcraftPath : String;

    procedure ApplyLocalizationChange;
    procedure FillLanguageMenu;
  public
    procedure SelectComboboxLanguage;
  end;

var
  SettingsWindow: TSettingsWindow;

implementation

{$R *.dfm}

uses
  ComponentContainerUnit, MainWin, SharedVars, SharedFunctions, LocalizationStr;

procedure TSettingsWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DbgLn('TSettingsWindow.FormClose()');

  Action := caFree;
end;

procedure TSettingsWindow.FormCreate(Sender: TObject);
begin
  DbgLn('TSettingsWindow.FormCreate()');

  ComponentContainer.Localizer.Localize(self);

  FillLanguageMenu;

  LoadSettings;

  dirWarcraft.Text := Options.WarcraftExe;
  chbStartup.Checked := Options.StartupWindows;
  chbMinimizeOnLogin.Checked := Options.MinimizeOnLogin;
  chbAdMessage.Checked := Options.AdMessage;

  dirWarcraft.OpenDialog.CheckFileExists := TRUE;
end;

procedure TSettingsWindow.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Case Key of
    vk_ESCAPE : Close;
  End;
end;

procedure TSettingsWindow.SelectComboboxLanguage;
var
  C1, C2 : Integer;
begin
  for C1 := 0 to ComponentContainer.pmTrayLanguage.Count - 1 do
    if ComponentContainer.pmTrayLanguage.Items[C1].Default then
    begin
      For C2 := 0 to cbLanguages.Items.Count - 1 Do
        If cbLanguages.Items[C2] = ComponentContainer.pmTrayLanguage.Items[C1].Caption Then
        begin
          cbLanguages.ItemIndex := C2;
          Break;
        end;

      Break;
    end;
end;

procedure TSettingsWindow.btDetectClick(Sender: TObject);
var
  warExe : String;
begin
  DbgLn('TSettingsWindow.btDetectClick()');

  btDetect.Enabled := FALSE;
  Application.ProcessMessages;
  warExe := DetectWarcraftExe;
  dirWarcraft.Text := DetectWarcraftExe;
  btDetect.Enabled := TRUE;
end;

procedure TSettingsWindow.btOKClick(Sender: TObject);
begin
  DbgLn('TSettingsWindow.btOKClick()');

  Options.WarcraftExe := dirWarcraft.Text;
  Options.StartupWindows := chbStartup.Checked;
  Options.MinimizeOnLogin := chbMinimizeOnLogin.Checked;
  Options.AdMessage := chbAdMessage.Checked;
  
  SaveSettings;
  Close;
end;

procedure TSettingsWindow.cbLanguagesChange(Sender: TObject);
begin
  ComponentContainer.ChangeLanguage(cbLanguages.Text);
end;

procedure TSettingsWindow.btCancelClick(Sender: TObject);
begin
  DbgLn('TSettingsWindow.btCloseClick()');

  Close;
end;

procedure TSettingsWindow.dirWarcraftChange(Sender: TObject);
begin
  If FileExists(dirWarcraft.Text) Then
    oldWarcraftPath := dirWarcraft.Text
  else
    dirWarcraft.Text := oldWarcraftPath;
end;

procedure TSettingsWindow.FillLanguageMenu;
var
  C1 : Integer;
begin
  DbgLn('TComponentContainer.FillLanguageSubitems()');

  cbLanguages.Items.Clear;
  ilFlags.Clear;

  For C1 := 0 to ComponentContainer.pmTrayLanguage.Count - 1 Do
  Begin
    CopyImage(ComponentContainer.ilGlyphs16, ComponentContainer.pmTrayLanguage.Items[C1].ImageIndex, ilFlags, ComponentContainer.ilGlyphs16.PngImages[ComponentContainer.pmTrayLanguage.Items[C1].ImageIndex].Name);
    cbLanguages.Items.Add(ComponentContainer.pmTrayLanguage.Items[C1].Caption);
  End;
  ilFlags.PngImages.Add;

  SelectComboboxLanguage;
end;


procedure TSettingsWindow.ApplyLocalizationChange;
begin
  dirWarcraft.OpenDialog.Title := RS_WARDIALOG_TITLE;
end;

end.
