unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, Zipper, Windows, Messages;

type

  { TFMain }

  TFMain = class(TForm)
    BDirName: TButton;
    BSave: TButton;
    BRestore: TButton;
    BDel: TButton;
    EDirName: TEdit;
    LBFiles: TListBox;
    SDDMain: TSelectDirectoryDialog;
    procedure BDelClick(Sender: TObject);
    procedure BDirNameClick(Sender: TObject);
    procedure BRestoreClick(Sender: TObject);
    procedure BSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure WMHotKey(var msg:TMessage);message WM_HotKey;
  public

  end;

var
  FMain: TFMain;

implementation
uses
  Math,IniFiles;

const
  ConfigName = 'config.ini';

type

  { TFnStringList }
  TFnStringList = class(TStringList)
    function Add(const S: string): Integer; override;
  end;

var
  SaveKeyID, RestoreKeyID: LongInt;
{$R *.lfm}

procedure RefreshFiles;
var
  TmpStrings: TFnStringList;
begin
  TmpStrings := TFnStringList.Create;
  FindAllFiles(TmpStrings, ProgramDirectory, '*.zip', False);
  FMain.LBFiles.Clear;
  FMain.LBFiles.Items.AddStrings(TmpStrings);
end;

procedure SaveDir;
var
  Zip: TZipper;
begin
  Zip := TZipper.Create;
  Zip.UseLanguageEncoding := True;
  Zip.ZipFiles(
    ProgramDirectory+FormatDateTime('yyyymmddhhmmss', Now)+'.zip',
    FindAllFiles(FMain.EDirName.Text+'\')
  );
  RefreshFiles;
  windows.Beep(1000, 50);
  windows.Beep(1000, 50);
end;

procedure RestoreDir;
var
  Zip: TUnZipper;
  FileName: string;
begin
  if FMain.LBFiles.Items.Count=0 then
     Exit;
  Zip := TUnZipper.Create;
  FileName := FMain.LBFiles.GetSelectedText;
  if FileName = '' then
     FileName:=FMain.LBFiles.Items[FMain.LBFiles.Items.Count-1];
  Zip.UnZipAllFiles(FileName);
  SysUtils.Beep;
  windows.Beep(1000, 50);
  windows.Beep(2000, 50);
  windows.Beep(3000, 50);
end;

{ TFnStringList }

function TFnStringList.Add(const S: string): Integer;
begin
  Result:=inherited Add(ExtractFileName(S));
end;

{ TFMain }

procedure TFMain.BDirNameClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  if not SDDMain.Execute() then
     Exit();
  EDirName.Text:=SDDMain.FileName;
  Ini := TIniFile.Create(ProgramDirectory+ConfigName);
  Ini.WriteString('Main', 'Dir', EDirName.Text);
end;

procedure TFMain.BDelClick(Sender: TObject);
var
  FileName: string;
begin
  FileName := FMain.LBFiles.GetSelectedText;
  if FileName = '' then
     Exit;
  DeleteFile(PChar(ProgramDirectory+FileName));
  RefreshFiles;
end;

procedure TFMain.BRestoreClick(Sender: TObject);
begin
  RestoreDir;
end;

procedure TFMain.BSaveClick(Sender: TObject);
begin
  SaveDir;
end;

procedure TFMain.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ProgramDirectory+ConfigName);
  EDirName.Text:=Ini.ReadString('Main', 'Dir', '');

  Randomize;
  SaveKeyID:=Random(2**32);
  RestoreKeyID:=Random(2**32);
  RegisterHotKey(Handle, SaveKeyID, MOD_ALT, ord('S'));
  RegisterHotKey(Handle, RestoreKeyID, MOD_ALT, ord('R'));

  RefreshFiles;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  UnregisterHotKey(Handle, SaveKeyID);
  UnregisterHotKey(Handle, RestoreKeyID);
end;

procedure TFMain.WMHotKey(var msg: TMessage);
begin
  if msg.wParam = SaveKeyID then
     SaveDir;
  if msg.wParam = RestoreKeyID then
     RestoreDir;
end;

end.

