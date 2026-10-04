object MainWindow: TMainWindow
  Left = 522
  Top = 282
  Width = 633
  Height = 674
  Caption = 'API form'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    625
    647)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 20
    Top = 20
    Width = 19
    Height = 13
    Caption = 'URL'
  end
  object Label2: TLabel
    Left = 8
    Top = 48
    Width = 35
    Height = 13
    Caption = 'Params'
  end
  object Label3: TLabel
    Left = 12
    Top = 80
    Width = 82
    Height = 13
    Caption = 'Number of loops:'
  end
  object Edit1: TEdit
    Left = 52
    Top = 18
    Width = 561
    Height = 19
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
  end
  object Edit2: TEdit
    Left = 52
    Top = 46
    Width = 561
    Height = 19
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
  end
  object Button1: TButton
    Left = 504
    Top = 76
    Width = 107
    Height = 29
    Anchors = [akTop, akRight]
    Caption = 'Post'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 10
    Top = 132
    Width = 605
    Height = 149
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 3
  end
  object Memo2: TMemo
    Left = 10
    Top = 288
    Width = 605
    Height = 349
    Anchors = [akLeft, akTop, akRight, akBottom]
    Ctl3D = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 4
  end
  object Button2: TButton
    Left = 388
    Top = 76
    Width = 107
    Height = 29
    Anchors = [akTop, akRight]
    Caption = 'Get'
    TabOrder = 5
    OnClick = Button2Click
  end
  object Edit3: TEdit
    Left = 120
    Top = 78
    Width = 64
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 6
    Text = '1'
  end
  object CheckBox1: TCheckBox
    Left = 204
    Top = 78
    Width = 101
    Height = 20
    Caption = 'Break on error'
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 7
  end
  object httpClient: THttpCli
    LocalAddr = '0.0.0.0'
    ProxyPort = '80'
    Agent = 'Mozilla/4.0 (compatible; ICS)'
    Accept = 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*'
    NoCache = False
    ContentTypePost = 'application/x-www-form-urlencoded'
    MultiThreaded = False
    RequestVer = '1.0'
    FollowRelocation = True
    LocationChangeMaxCount = 5
    ServerAuth = httpAuthNone
    ProxyAuth = httpAuthNone
    BandwidthLimit = 10000
    BandwidthSampling = 1000
    Options = []
    Timeout = 30
    OnSessionConnected = httpClientSessionConnected
    OnSessionClosed = httpClientSessionClosed
    OnRequestHeaderEnd = httpClientRequestHeaderEnd
    OnDocBegin = httpClientDocBegin
    OnDocEnd = httpClientDocEnd
    OnRequestDone = httpClientRequestDone
    SocksAuthentication = socksNoAuthentication
    Left = 484
    Top = 200
  end
end
