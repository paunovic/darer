unit BlocklistWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SkinCtrls, SkinBoxCtrls, OverbyteIcsWndControl,
  OverbyteIcsHttpProt;

type
  TBlocklistWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    lbBlockedUsers: TspSkinListBox;
    btUnblock: TspSkinButton;
    httpQuickAPI: THttpCli;
    procedure LocalLocalize;
    procedure PopulateListbox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btUnblockClick(Sender: TObject);
  private
  public
  end;

var
  BlocklistWindow: TBlocklistWindow;

implementation

{$R *.dfm}

uses
  ComponentModule, Localization, SharedData, MainWin, Misc;

procedure TBlocklistWindow.LocalLocalize;
begin
//
end;

procedure TBlocklistWindow.PopulateListbox;
var
  C1 : Integer;
begin
  lbBlockedUsers.Items.Clear;

  For C1 := 0 to Blocklist.Count - 1 Do
    lbBlockedUsers.Items.Add(Blocklist.Strings[C1]);

  If lbBlockedUsers.Items.Count > 0 Then
    lbBlockedUsers.ItemIndex := 0;
end;

procedure TBlocklistWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFREE;
end;

procedure TBlocklistWindow.FormCreate(Sender: TObject);
begin
  Localize(self);
  LocalLocalize;

  PopulateListbox;
end;

procedure TBlocklistWindow.btUnblockClick(Sender: TObject);
begin
  If lbBlockedUsers.ItemIndex <> -1 Then
  Begin
    MainWindow.UnblockUser(Blocklist.Strings[lbBlockedUsers.ItemIndex]);
    PopulateListbox;
  End;
end;

end.
