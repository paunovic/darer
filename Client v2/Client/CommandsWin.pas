unit CommandsWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, RVScroll, RichView, RVStyle, SkinCtrls;

type
  TCommandsWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    rvText: TRichView;
    rvStyle: TRVStyle;
    rvScroll: TspSkinScrollBar;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure rvScrollChange(Sender: TObject);
    procedure rvTextVScrolled(Sender: TObject);
    procedure LocalLocalize;
  private
  public
  end;

var
  CommandsWindow: TCommandsWindow;

implementation

{$R *.dfm}

uses
  Localization, ComponentModule, RVTable, SharedData;

procedure TCommandsWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFREE;
end;

procedure TCommandsWindow.LocalLocalize;
var
  C1       : Integer;
  tmpTable : TRVTableItemInfo;
begin
  rvText.Clear;
  LocalizeCommandsText;

  For C1 := 0 to CommandsText.Count - 1 Do
  Begin
    If CommandsText.Lines[C1].IsCommand Then
    Begin
      tmpTable := TRVTableItemInfo.CreateEx(1, 2, rvText.RVData);
      tmpTable.BorderWidth := 0;
      tmpTable.CellVPadding := 0;
      tmpTable.CellBorderWidth := 0;
      tmpTable.CellVSpacing := 0;
      tmpTable.BorderVSpacing := 0;
      tmpTable.Color := clNone;
      tmpTable.Options := [rvtoColSizing, rvtoRTFAllowAutofit];
      tmpTable.Cells[0, 0].BestWidth := 250;
      tmpTable.Cells[0, 1].BestWidth := rvText.Width - 160;
      tmpTable.Cells[0, 0].Clear;
      tmpTable.Cells[0, 1].Clear;
      tmpTable.Cells[0, 0].AddFmt('%s', [CommandsText.Lines[C1].Command], 2, 0);
      tmpTable.Cells[0, 1].AddFmt('%s', [CommandsText.Lines[C1].Line], 0, 0);
      rvText.AddItem('', tmpTable);
    End
    else
      If CommandsText.Lines[C1].IsHeader Then
      Begin
        rvText.AddNL(CommandsText.Lines[C1].Line, 1, 0);
      End
      else
        rvText.AddNL(CommandsText.Lines[C1].Line, 0, 0);
    rvText.Format;
  End;

  rvScroll.Max := rvText.VScrollMax;
end;

procedure TCommandsWindow.FormCreate(Sender: TObject);
begin
  SkinForm.AlphaBlendAnimation := Options.Customize.FadeInEffect;

  Localize(self);
  LocalLocalize;
end;

procedure TCommandsWindow.rvScrollChange(Sender: TObject);
begin
  rvText.VScrollPos := TspSkinScrollBar(Sender).Position;
  If TspSkinScrollBar(Sender).Position = TspSkinScrollBar(Sender).Max Then
    rvText.VScrollPos := rvText.VScrollMax;
end;

procedure TCommandsWindow.rvTextVScrolled(Sender: TObject);
begin
  rvScroll.Position := TRichView(Sender).VScrollPos;
end;

end.
