unit SkinEngine;

interface

uses
  SysUtils, Classes, SkinData;

const
  SKIN_EXTENSION = 'DSF';
  SKINS_DIR      = 'skins\';

type
  TSkinHeader_String = String[128];

  TSkinHeader = record
                  Info  : record
                            Name, Author, Description : TSkinHeader_String;
                          end;

                  Skins : record
                            LoginSkin, MainSkin : record
                                                    Size : Integer;
                                                  end;
                          end;
                end;

  TSkinItem = record
                Header   : TSkinHeader;
                Filename : String;
              end;

  TSkinList = record
                Count : Integer;
                Items : Array of TSkinItem;
              end;

procedure SaveSkin(const AFile : String; const AName, AAuthor, ADescription : TSkinHeader_String; const ALoginSkin, AMainSkin : String);
procedure EnumerateSkins(var ASkinList : TSkinList);
procedure ExtractLoginSkin(const ASkinFile, AToFile : String);
procedure ExtractMainSkin(const ASkinFile, AToFile : String);
procedure LoadSkin(const ASkinName : String; const ALogin, AMain : TspSkinData; const ADefaultSkin_Login, ADefaultSkin_Main : TspCompressedStoredSkin);

implementation

uses
  Windows, SharedData;

procedure SaveSkin(const AFile : String; const AName, AAuthor, ADescription : TSkinHeader_String; const ALoginSkin, AMainSkin : String);
var
  fs              : TFileStream;
  skinHeader      : TSkinHeader;
  msLogin, msMain : TMemoryStream;
begin
  skinHeader.Info.Name := AName;
  skinHeader.Info.Author := AAuthor;
  skinHeader.Info.Description := ADescription;

  msLogin := TMemoryStream.Create;
  msLogin.LoadFromFile(ALoginSkin);

  msMain := TMemoryStream.Create;
  msMain.LoadFromFile(AMainSkin);

  skinHeader.Skins.LoginSkin.Size := msLogin.Size;
  skinHeader.Skins.MainSkin.Size := msMain.Size;

  fs := TFileStream.Create(AFile + '.' + SKIN_EXTENSION, fmCreate);
  fs.WriteBuffer(skinHeader, SizeOf(TSkinHeader));
  fs.WriteBuffer(msLogin.Memory^, msLogin.Size);
  fs.WriteBuffer(msMain.Memory^, msMain.Size);
  fs.Free;

  msMain.Free;
  msLogin.Free;
end;

procedure GetSkinInfo(const ASkinFile : String; var ASkinHeader : TSkinHeader);
var
  fs : TFileStream;
begin
  fs := nil;
  try
    fs := TFileStream.Create(ASkinFile, fmOpenRead or fmShareDenyNone);
    fs.ReadBuffer(ASkinHeader, SizeOf(TSkinHeader));
  finally
    If Assigned(fs) Then
      fs.Free;
  end;
end;

procedure EnumerateSkins(var ASkinList : TSkinList);
var
  isFound   : Boolean;
  searchRec : TSearchRec;
begin
  ASkinList.Count := 0;
  SetLength(ASkinList.Items, ASkinList.Count);

  isFound := FindFirst(ITB(SKINS_DIR) + '*.' + SKIN_EXTENSION, faAnyFile - faDirectory, searchRec) = 0;
  While isFound Do
  Begin
    Inc(ASkinList.Count);
    SetLength(ASkinList.Items, ASkinList.Count);

    ASkinList.Items[ASkinList.Count - 1].Filename := ITB(SKINS_DIR) + searchRec.Name;
    GetSkinInfo(ASkinList.Items[ASkinList.Count - 1].Filename, ASkinList.Items[ASkinList.Count - 1].Header);

    isFound := FindNext(searchRec) = 0;
  End;
  SysUtils.FindClose(searchRec);
end;

procedure ExtractLoginSkin(const ASkinFile, AToFile : String);
var
  fs         : TFileStream;
  skinHeader : TSkinHeader;
  ms         : TMemoryStream;
begin
  fs := nil;
  ms := nil;
  try
    SysUtils.DeleteFile(AToFile);
    fs := TFileStream.Create(ASkinFile, fmOpenRead or fmShareDenyNone);
    fs.ReadBuffer(skinHeader, SizeOf(TSkinHeader));
    ms := TMemoryStream.Create;
    ms.SetSize(skinHeader.Skins.LoginSkin.Size);
    fs.ReadBuffer(ms.Memory^, ms.Size);
    ms.SaveToFile(AToFile);
  finally
    If Assigned(ms) Then
      ms.Free;
    If Assigned(fs) Then
      fs.Free;
  end;
end;

procedure ExtractMainSkin(const ASkinFile, AToFile : String);
var
  fs         : TFileStream;
  skinHeader : TSkinHeader;
  ms         : TMemoryStream;
begin
  fs := nil;
  ms := nil;
  try
    SysUtils.DeleteFile(AToFile);
    fs := TFileStream.Create(ASkinFile, fmOpenRead or fmShareDenyNone);
    fs.ReadBuffer(skinHeader, SizeOf(TSkinHeader));
    fs.Seek(skinHeader.Skins.LoginSkin.Size, soCurrent);
    ms := TMemoryStream.Create;
    ms.SetSize(skinHeader.Skins.MainSkin.Size);
    fs.ReadBuffer(ms.Memory^, ms.Size);
    ms.SaveToFile(AToFile);
  finally
    If Assigned(ms) Then
      ms.Free;
    If Assigned(fs) Then
      fs.Free;
  end;
end;

procedure LoadSkin(const ASkinName : String; const ALogin, AMain : TspSkinData; const ADefaultSkin_Login, ADefaultSkin_Main : TspCompressedStoredSkin);
var
  skinList : TSkinList;
  C1       : Integer;
  loaded   : Boolean;
begin
  loaded := FALSE;

  EnumerateSkins(skinList);
  For C1 := 0 to skinList.Count - 1 Do
    If skinList.Items[C1].Header.Info.Name = Options.Customize.Skin Then
    Begin
      ExtractLoginSkin(skinList.Items[C1].Filename, 'login.dsk');
      ExtractMainSkin(skinList.Items[C1].Filename, 'main.dsk');

      {$WARN SYMBOL_PLATFORM OFF}
      FileSetAttr(SelfPath + 'login.dsk', faHidden);
      FileSetAttr(SelfPath + 'main.dsk', faHidden);
      {$WARN SYMBOL_PLATFORM ON}

      ALogin.LoadFromCompressedFile('login.dsk');
      ALogin.SkinName := skinList.Items[C1].Header.Info.Name;
      ALogin.SkinAuthor := skinList.Items[C1].Header.Info.Author;

      AMain.LoadFromCompressedFile('main.dsk');
      AMain.SkinName := skinList.Items[C1].Header.Info.Name;
      AMain.SkinAuthor := skinList.Items[C1].Header.Info.Author;

      loaded := TRUE;
      Break;
    End;

  If not loaded Then
  Begin
    ALogin.LoadCompressedStoredSkin(ADefaultSkin_Login);
    AMain.LoadCompressedStoredSkin(ADefaultSkin_Main);
  End;
end;



end.
