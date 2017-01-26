unit TutorialWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, OleCtrls, SHDocVw, JvComponentBase, JvThread;

type
  TTutorialWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    WebBrowser: TWebBrowser;
    WebThread: TJvThread;
    procedure LocalLocalize;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure WebThreadExecute(Sender: TObject; Params: Pointer);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WebBrowserBeforeNavigate2(Sender: TObject; const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
    procedure WebBrowserDocumentComplete(Sender: TObject; const pDisp: IDispatch; var URL: OleVariant);
  private
    Saved8087CW : Word;
  public
  end;

var
  TutorialWindow: TTutorialWindow;

implementation

{$R *.dfm}

uses
  ActiveX, Localization, SharedData, MainWin, ComponentModule;

procedure TTutorialWindow.LocalLocalize;
begin
//
end;

procedure TTutorialWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFREE;
end;

procedure TTutorialWindow.WebThreadExecute(Sender: TObject; Params: Pointer);
begin
  WebBrowser.Navigate('http://www.darer.com/media/default/ClientVideo/Player.html');
end;

procedure TTutorialWindow.FormShow(Sender: TObject);
begin
  WebThread.Execute(nil);
end;

procedure TTutorialWindow.FormCreate(Sender: TObject);
begin
  SkinForm.AlphaBlendAnimation := Options.Customize.FadeInEffect;

  Caption := MainWindow.smTutorial.Caption;
end;

procedure TTutorialWindow.WebBrowserBeforeNavigate2(Sender: TObject; const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData, Headers: OleVariant; var Cancel: WordBool);
begin
  Saved8087CW := Default8087CW;
  Set8087CW($133F); // Disable FPU exceptions
end;

procedure TTutorialWindow.WebBrowserDocumentComplete(Sender: TObject; const pDisp: IDispatch; var URL: OleVariant);
begin
  Set8087CW(Saved8087CW);
end;

end.
