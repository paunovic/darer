unit OptionsWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SkinCtrls, ComCtrls, SkinTabs, StdCtrls, Mask,
  SkinBoxCtrls, SkinExCtrls, spSkinShellCtrls, sppngimagelist, ImgList,
  Buttons, ExtCtrls;

type
  TOptionsWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    cntOptions: TspSkinPageControl;
    tabClient: TspSkinTabSheet;
    btSave: TspSkinButton;
    tabSounds: TspSkinTabSheet;
    tabWarcraft: TspSkinTabSheet;
    lbWC3Path: TspSkinShadowLabel;
    chbWC3WindowedMode: TspSkinCheckRadioBox;
    lbWC3Params: TspSkinShadowLabel;
    ebWC3Params: TspSkinEdit;
    chbWC3OpenGLMode: TspSkinCheckRadioBox;
    ebWC3Path: TspSkinDirectoryEdit;
    chbMinimizeToSystray: TspSkinCheckRadioBox;
    tabCustomize: TspSkinTabSheet;
    lbStatusIcons: TspSkinShadowLabel;
    cbexStatusIcons: TspSkinComboBoxEx;
    lbSkin: TspSkinShadowLabel;
    cbSkin: TspSkinComboBox;
    chbFadeInEffect: TspSkinCheckRadioBox;
    lbScrollbackLines: TspSkinShadowLabel;
    ebScrollbackLines: TspSkinNumericEdit;
    chbShowFriendReqs: TspSkinCheckRadioBox;
    chbShowFriendGames: TspSkinCheckRadioBox;
    chbShowFriendOnline: TspSkinCheckRadioBox;
    paSoundsRest: TspSkinPanel;
    btSoundPlayPM: TspSkinSpeedButton;
    ebSoundsPM: TspSkinFileEdit;
    chbSoundsPM: TspSkinCheckRadioBox;
    chbSoundsNewPM: TspSkinCheckRadioBox;
    ebSoundsNewPM: TspSkinFileEdit;
    btSoundPlayNewPM: TspSkinSpeedButton;
    btSoundPlayBotPM: TspSkinSpeedButton;
    ebSoundsBotPM: TspSkinFileEdit;
    ebSoundsErrorMessage: TspSkinFileEdit;
    btSoundsPlayErrorMessage: TspSkinSpeedButton;
    btSoundPlayFriendOnline: TspSkinSpeedButton;
    ebSoundsFriendOn: TspSkinFileEdit;
    ebSoundsFriendOff: TspSkinFileEdit;
    btSoundPlayFriendOffline: TspSkinSpeedButton;
    btSoundPlayHighlighted: TspSkinSpeedButton;
    ebSoundsHighlighted: TspSkinFileEdit;
    chbSoundsHighlighted: TspSkinCheckRadioBox;
    chbSoundsFriendOff: TspSkinCheckRadioBox;
    chbSoundsFriendOn: TspSkinCheckRadioBox;
    chbSoundsErrorMessage: TspSkinCheckRadioBox;
    chbSoundsBotPM: TspSkinCheckRadioBox;
    chbSoundsSurpressIngame: TspSkinCheckRadioBox;
    paSoundsEnable: TspSkinPanel;
    chbSoundsEnable: TspSkinCheckRadioBox;
    chbShowPopups: TspSkinCheckRadioBox;
    chbWarcraftMaximize: TspSkinCheckRadioBox;
    chbAutoMinimize: TspSkinCheckRadioBox;
    chbAssociateReplays: TspSkinCheckRadioBox;
    lbGameLanguage: TspSkinShadowLabel;
    cbGameLanguage: TspSkinComboBox;
    chbLobbyFull: TspSkinCheckRadioBox;
    ebLobbyFull: TspSkinFileEdit;
    btLobbyFull: TspSkinSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure LocalLocalize;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SaveSettings;
    procedure LoadSettings;
    procedure btSaveClick(Sender: TObject);
    procedure ebSoundsPMChange(Sender: TObject);
    procedure btSoundPlayPMClick(Sender: TObject);
    procedure btSoundPlayNewPMClick(Sender: TObject);
    procedure btSoundPlayFriendOnlineClick(Sender: TObject);
    procedure btSoundPlayFriendOfflineClick(Sender: TObject);
    procedure btSoundPlayBotPMClick(Sender: TObject);
    procedure btSoundsPlayErrorMessageClick(Sender: TObject);
    procedure btSoundPlayHighlightedClick(Sender: TObject);
    procedure chbSoundsEnableClick(Sender: TObject);
    procedure chbSoundsEnableKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btLobbyFullClick(Sender: TObject);
  private
  public
  end;

var
  OptionsWindow: TOptionsWindow;

implementation

{$R *.dfm}

uses
  ComponentModule, Localization, SharedData, Misc, MainWin, SkinEngine,
  HotkeyMapWin, SharedVars;

procedure TOptionsWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFREE;
end;

procedure TOptionsWindow.LocalLocalize;
begin
//
end;

procedure TOptionsWindow.SaveSettings;
begin
  // Client panel
  Options.Client.MinimizeToSystray := chbMinimizeToSystray.Checked;
  Options.Client.ScrollbackLines := Trunc(ebScrollbackLines.Value);
  Options.Client.ShowFriendRequests := chbShowFriendReqs.Checked;
  Options.Client.ShowFriendGameMsgs := chbShowFriendGames.Checked;
  Options.Client.ShowFriendOnlineMsgs := chbShowFriendOnline.Checked;
  Options.Client.GameAutoMinimize := chbAutoMinimize.Checked;
  Options.Client.ShowPopups := chbShowPopups.Checked;
  Options.Client.AssociateReplays := chbAssociateReplays.Checked;

  // Sounds panel
  Options.Sounds.Enabled := chbSoundsEnable.Checked;
  Options.Sounds.SurpressIngame := chbSoundsSurpressIngame.Checked;

  Options.Sounds.PM.Enabled := chbSoundsPM.Checked;
  Options.Sounds.PM.Path := ebSoundsPM.Text;

  Options.Sounds.NewPM.Enabled := chbSoundsNewPM.Checked;
  Options.Sounds.NewPM.Path := ebSoundsNewPM.Text;

  Options.Sounds.BotPM.Enabled := chbSoundsBotPM.Checked;
  Options.Sounds.BotPM.Path := ebSoundsBotPM.Text;

  Options.Sounds.ErrorMessage.Enabled := chbSoundsErrorMessage.Checked;
  Options.Sounds.ErrorMessage.Path := ebSoundsErrorMessage.Text;

  Options.Sounds.FriendOn.Enabled := chbSoundsFriendOn.Checked;
  Options.Sounds.FriendOn.Path := ebSoundsFriendOn.Text;

  Options.Sounds.FriendOff.Enabled := chbSoundsFriendOff.Checked;
  Options.Sounds.FriendOff.Path := ebSoundsFriendOff.Text;

  Options.Sounds.Highlighted.Enabled := chbSoundsHighlighted.Checked;
  Options.Sounds.Highlighted.Path := ebSoundsHighlighted.Text;

  Options.Sounds.LobbyFull.Enabled := chbLobbyFull.Checked;
  Options.Sounds.LobbyFull.Path := ebLobbyFull.Text;

  // Warcraft III panel
  Options.WC3.Path := ebWC3Path.Text;
  Options.WC3.Exe := ITB(ebWC3Path.Text) + 'war3.exe';
  Options.WC3.Params := ebWC3Params.Text;
  Options.WC3.Windowed := chbWC3WindowedMode.Checked;
  Options.WC3.OpenGL := chbWC3OpenGLMode.Checked;
  Options.WC3.Maximize := chbWarcraftMaximize.Checked;
  Options.WC3.Language := cbGameLanguage.Text;

  // Customize panel
  Options.Customize.Skin := cbSkin.Items[cbSkin.ItemIndex];
  Options.Customize.StatusIcons := cbexStatusIcons.ItemIndex;
  Options.Customize.FadeInEffect := chbFadeInEffect.Checked;

  Misc.SaveSettings;
  Misc.LoadSettings;
end;

procedure TOptionsWindow.LoadSettings;
var
  C1 : Integer;
begin
  Misc.LoadSettings;
  
  // Client panel
  chbMinimizeToSystray.Checked := Options.Client.MinimizeToSystray;
  ebScrollbackLines.Value := Options.Client.ScrollbackLines;
  chbShowFriendReqs.Checked := Options.Client.ShowFriendRequests;
  chbShowFriendGames.Checked := Options.Client.ShowFriendGameMsgs;
  chbShowFriendOnline.Checked := Options.Client.ShowFriendOnlineMsgs;
  chbAutoMinimize.Checked := Options.Client.GameAutoMinimize;
  chbShowPopups.Checked := Options.Client.ShowPopups;
  Options.Client.AssociateReplays := IsReplaysAssociated;
  chbAssociateReplays.Checked := Options.Client.AssociateReplays;

  // Sounds panel
  chbSoundsEnable.Checked := Options.Sounds.Enabled;
  chbSoundsSurpressIngame.Checked := Options.Sounds.SurpressIngame;

  chbSoundsPM.Checked := Options.Sounds.PM.Enabled;
  ebSoundsPM.Text := Options.Sounds.PM.Path;

  chbSoundsNewPM.Checked := Options.Sounds.NewPM.Enabled;
  ebSoundsBotPM.Text := Options.Sounds.BotPM.Path;

  chbSoundsBotPM.Checked := Options.Sounds.BotPM.Enabled;
  ebSoundsNewPM.Text := Options.Sounds.NewPM.Path;

  chbSoundsErrorMessage.Checked := Options.Sounds.ErrorMessage.Enabled;
  ebSoundsErrorMessage.Text := Options.Sounds.ErrorMessage.Path;

  chbSoundsFriendOn.Checked := Options.Sounds.FriendOn.Enabled;
  ebSoundsFriendOn.Text := Options.Sounds.FriendOn.Path;

  chbSoundsFriendOff.Checked := Options.Sounds.FriendOff.Enabled;
  ebSoundsFriendOff.Text := Options.Sounds.FriendOff.Path;

  chbSoundsHighlighted.Checked := Options.Sounds.Highlighted.Enabled;
  ebSoundsHighlighted.Text := Options.Sounds.Highlighted.Path;

  chbLobbyFull.Checked := Options.Sounds.LobbyFull.Enabled;
  ebLobbyFull.Text := Options.Sounds.LobbyFull.Path;

  // Warcraft III panel
  ebWC3Path.Text := Options.WC3.Path;
  ebWC3Params.Text := Options.WC3.Params;
  chbWC3WindowedMode.Checked := Options.WC3.Windowed;
  chbWC3OpenGLMode.Checked := Options.WC3.OpenGL;
  chbWarcraftMaximize.Checked := Options.WC3.Maximize;

  cbGameLanguage.ItemIndex := -1;
  For C1 := 0 to cbGameLanguage.Items.Count - 1 Do
    If cbGameLanguage.Items.Strings[C1] = Options.WC3.Language Then
    Begin
      cbGameLanguage.ItemIndex := C1;
      Break;
    End;

  // Customize panel
  cbSkin.ItemIndex := 0;
  For C1 := 0 to cbSkin.Items.Count - 1 Do
    If cbSkin.Items[C1] = Options.Customize.Skin Then
    Begin
      cbSkin.ItemIndex := C1;
      Break;
    End;

  cbexStatusIcons.ItemIndex := Options.Customize.StatusIcons;
  chbFadeInEffect.Checked := Options.Customize.FadeInEffect;
end;

procedure TOptionsWindow.FormCreate(Sender: TObject);
var
  skinList : TSkinList;
  C1       : Integer;
begin
  SkinForm.AlphaBlendAnimation := Options.Customize.FadeInEffect;

  Localize(self);
  LocalLocalize;

  ebSoundsPM.DlgInitialDir := SelfPath + 'sounds';
  ebSoundsNewPM.DlgInitialDir := SelfPath + 'sounds';
  ebSoundsBotPM.DlgInitialDir := SelfPath + 'sounds';
  ebSoundsErrorMessage.DlgInitialDir := SelfPath + 'sounds';
  ebSoundsFriendOn.DlgInitialDir := SelfPath + 'sounds';
  ebSoundsFriendOff.DlgInitialDir := SelfPath + 'sounds';
  ebSoundsHighlighted.DlgInitialDir := SelfPath + 'sounds';
  ebLobbyFull.DlgInitialDir := SelfPath + 'sounds';

  EnumerateSkins(skinList);
  For C1 := 0 to skinList.Count - 1 Do
    cbSkin.Items.Add(skinList.Items[C1].Header.Info.Name);

  ComponentModuleWindow.FillGameLanguages(cbGameLanguage);

  LoadSettings;

  chbSoundsEnable.OnClick(Sender);
end;

procedure TOptionsWindow.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    vk_ESCAPE : Close;
  End;
end;

procedure TOptionsWindow.btSaveClick(Sender: TObject);
begin
  SaveSettings;
  Close;
end;

procedure TOptionsWindow.ebSoundsPMChange(Sender: TObject);
begin
  If LowerCase(ITB(ExtractFilePath(TspSkinFileEdit(Sender).Text))) = LowerCase(ITB(SelfPath) + 'sounds\') Then
    TspSkinFileEdit(Sender).Text := ExtractFileName(TspSkinFileEdit(Sender).Text);
end;

procedure TOptionsWindow.btSoundPlayPMClick(Sender: TObject);
var
  sfile : String;
begin
  sfile := ebSoundsPM.Text;
  If not FileExists(sfile) Then
    sfile := ITB(SelfPath) + SOUND_DIR + ebSoundsPM.Text;
  PSound(sfile);
end;

procedure TOptionsWindow.btSoundPlayNewPMClick(Sender: TObject);
var
  sfile : String;
begin
  sfile := ebSoundsNewPM.Text;
  If not FileExists(sfile) Then
    sfile := ITB(SelfPath) + SOUND_DIR + ebSoundsNewPM.Text;
  PSound(sfile);
end;

procedure TOptionsWindow.btSoundPlayFriendOnlineClick(Sender: TObject);
var
  sfile : String;
begin
  sfile := ebSoundsFriendOn.Text;
  If not FileExists(sfile) Then
    sfile := ITB(SelfPath) + SOUND_DIR + ebSoundsFriendOn.Text;
  PSound(sfile);
end;

procedure TOptionsWindow.btSoundPlayFriendOfflineClick(Sender: TObject);
var
  sfile : String;
begin
  sfile := ebSoundsFriendOff.Text;
  If not FileExists(sfile) Then
    sfile := ITB(SelfPath) + SOUND_DIR + ebSoundsFriendOff.Text;
  PSound(sfile);
end;

procedure TOptionsWindow.btSoundPlayBotPMClick(Sender: TObject);
var
  sfile : String;
begin
  sfile := ebSoundsBotPM.Text;
  If not FileExists(sfile) Then
    sfile := ITB(SelfPath) + SOUND_DIR + ebSoundsBotPM.Text;
  PSound(sfile);
end;

procedure TOptionsWindow.btSoundsPlayErrorMessageClick(Sender: TObject);
var
  sfile : String;
begin
  sfile := ebSoundsErrorMessage.Text;
  If not FileExists(sfile) Then
    sfile := ITB(SelfPath) + SOUND_DIR + ebSoundsErrorMessage.Text;
  PSound(sfile);
end;

procedure TOptionsWindow.btSoundPlayHighlightedClick(Sender: TObject);
var
  sfile : String;
begin
  sfile := ebSoundsHighlighted.Text;
  If not FileExists(sfile) Then
    sfile := ITB(SelfPath) + SOUND_DIR + ebSoundsHighlighted.Text;
  PSound(sfile);
end;

procedure TOptionsWindow.chbSoundsEnableClick(Sender: TObject);
begin
  paSoundsRest.Enabled := chbSoundsEnable.Checked;
end;

procedure TOptionsWindow.chbSoundsEnableKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  chbSoundsEnable.OnClick(Sender);
end;

procedure TOptionsWindow.btLobbyFullClick(Sender: TObject);
var
  sfile : String;
begin
  sfile := ebLobbyFull.Text;
  If not FileExists(sfile) Then
    sfile := ITB(SelfPath) + SOUND_DIR + ebLobbyFull.Text;
  PSound(sfile);
end;

end.
