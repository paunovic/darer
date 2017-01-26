unit HotkeyMapWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SkinCtrls, SkinExCtrls, StdCtrls;

type
  THotkeyMapWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    lbEnterHotkey: TspSkinStdLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
  public
    ShiftState : TShiftState;
    Hotkey     : Word;
  end;

var
  HotkeyMapWindow: THotkeyMapWindow;

implementation

{$R *.dfm}

uses
  ComponentModule;


procedure THotkeyMapWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure THotkeyMapWindow.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  ShiftState := Shift;
  Hotkey := Key;
  Close;
end;

end.
