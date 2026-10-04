unit MainWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OverbyteIcsWndControl, OverbyteIcsHttpProt, ExtCtrls;

type
  TMainWindow = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    httpClient: THttpCli;
    Memo2: TMemo;
    Button2: TButton;
    Edit3: TEdit;
    Label3: TLabel;
    CheckBox1: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure httpClientRequestHeaderEnd(Sender: TObject);
    procedure httpClientSessionConnected(Sender: TObject);
    procedure httpClientSessionClosed(Sender: TObject);
    procedure httpClientDocBegin(Sender: TObject);
    procedure httpClientDocEnd(Sender: TObject);
    procedure httpClientRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure FormCreate(Sender: TObject);
    procedure AddLine(const ALine : String);
    function GetDeltaTime : String;
    procedure Button2Click(Sender: TObject);
  private
    startTime, endTime : DWORD;
  public
  end;

var
  MainWindow: TMainWindow;

implementation

{$R *.dfm}

uses
  SharedData, SharedVars;

function TMainWindow.GetDeltaTime : String;
begin
  result := IntToStr(GetTickCount - startTime);
  While Length(result) < 3 Do
    Insert('0', result, 0);
  Insert('.', result, Length(result) - 2);
end;

procedure TMainWindow.AddLine(const ALine : String);
begin
  Memo1.Lines.Add(Format('%s   %s', [GetDeltaTime, ALine]));
end;

procedure TMainWindow.Button1Click(Sender: TObject);
var
  loops : Integer;
begin
  Memo1.Clear;
  Memo2.Clear;
  startTime := GetTickCount;

  loops := 0;
  repeat
    httpPostRequest(httpClient, Edit1.Text, Edit2.Text);
    While httpClient.State <> httpReady Do
      Application.ProcessMessages;
    Inc(loops);
  until loops = StrToIntDef(Edit3.Text, 1);
end;

procedure TMainWindow.httpClientRequestHeaderEnd(Sender: TObject);
begin
  AddLine('Request sent');
end;

procedure TMainWindow.httpClientSessionConnected(Sender: TObject);
begin
  AddLine('Session connected');
end;

procedure TMainWindow.httpClientSessionClosed(Sender: TObject);
begin
  AddLine('Session closed');
end;

procedure TMainWindow.httpClientDocBegin(Sender: TObject);
begin
  AddLine('Request done, receiving data...');
end;

procedure TMainWindow.httpClientDocEnd(Sender: TObject);
begin
  AddLine('Receiving data done !');
end;

procedure TMainWindow.httpClientRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
begin
  endTime := GetTickCount;
  AddLine(Format('Request done [error code: %d] [status code: %d] [received stream size: %db]', [ErrCode, httpClient.StatusCode, httpClient.RcvdCount]));

  If (ErrCode = 0) and
     (THTTPCli(Sender).StatusCode = 200) Then
  Begin
//    stringStream := TStringStream.Create('');
    httpClient.RcvdStream.Position := 0;
//    TMemoryStream(httpClient.RcvdStream).SaveToStream(stringStream);
    Memo2.Lines.LoadFromStream(httpClient.RcvdStream);
//    stringStream.Free;
  End;

  httpFree(httpClient);
end;

procedure TMainWindow.FormCreate(Sender: TObject);
begin
  Edit1.Text := URL_API;
end;

procedure TMainWindow.Button2Click(Sender: TObject);
begin
  Memo1.Clear;
  Memo2.Clear;
  startTime := GetTickCount;
  If Edit2.Text <> '' Then
    httpGetRequest(httpClient, Edit1.Text + '?' + Edit2.Text)
  else
    httpGetRequest(httpClient, Edit1.Text);
end;

end.
//
key=4e78829d$1$pXGImx4G$0ojYui54N8JIgbnABOnw/0&to=Pafkata&server=EU
