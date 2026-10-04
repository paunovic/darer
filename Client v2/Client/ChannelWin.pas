unit ChannelWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, StdCtrls, Mask, SkinBoxCtrls, SkinCtrls,
  SkinExCtrls;

type
  TChannelWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    lbChannelName: TspSkinShadowLabel;
    lbPassword: TspSkinShadowLabel;
    ebChannelName: TspSkinEdit;
    btOk: TspSkinButton;
    btCancel: TspSkinButton;
    ebPassword: TspSkinPasswordEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
  public
  end;

var
  ChannelWindow: TChannelWindow;

implementation

{$R *.dfm}

uses
  ComponentModule;

procedure TChannelWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFREE;
end;

procedure TChannelWindow.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TChannelWindow.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Case Key of
    vk_ESCAPE : Close;
    vk_RETURN : SelectNext(ActiveControl as TWinControl, TRUE, TRUE);
  End;
end;

end.
