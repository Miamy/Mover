unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Grids, ValEdit, Vcl.Imaging.pngimage, System.UITypes;

type
  TformMain = class(TForm)
    imageScreen1: TImage;
    imageScreen2: TImage;
    listBoxProcesses: TListBox;
    valListEditorCoordinates: TValueListEditor;
    btnTo1stMonitor: TButton;
    btnTo2ndMonitor: TButton;
    lblMonitor1Descr: TLabel;
    lblMonitor2Descr: TLabel;
    btnRefresh: TButton;
    btnExit: TButton;
    lblMonitor1Name: TLabel;
    lblMonitor2Name: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure listBoxProcessesClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnTo1stMonitorClick(Sender: TObject);
  private
    { Private declarations }
    procedure FillProcessesList;
    procedure FillMonitorsList;

    procedure GetProcessCoordinates;
    function GetSelectedProcessHandle: HWND;
    procedure MoveToMonitor(aMonitorIndex: integer; aHandle: THandle);
  public
    { Public declarations }
  end;

var
  formMain: TformMain;

implementation

{$R *.dfm}

procedure TformMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TformMain.btnRefreshClick(Sender: TObject);
begin
  FillProcessesList;
end;


procedure TformMain.btnTo1stMonitorClick(Sender: TObject);
begin
  MoveToMonitor(TButton(Sender).Tag, INVALID_HANDLE_VALUE);
end;

procedure TformMain.FillMonitorsList;
var
  currentMonitor: TMonitor;
  i: integer;
begin
  imageScreen1.Visible := false;
  imageScreen2.Visible := false;
  btnTo1stMonitor.Visible := false;
  btnTo2ndMonitor.Visible := false;

  if Screen.MonitorCount < 1 then
    exit;
  currentMonitor := Screen.PrimaryMonitor;
//  lblMonitor1Name.Caption := currentMonitor.UnitName;
  lblMonitor1Descr.Caption := IntToStr(currentMonitor.Width) + ' x ' +
    IntToStr(currentMonitor.Height);
  imageScreen1.Visible := true;
  btnTo1stMonitor.Visible := true;

  if Screen.MonitorCount < 2 then
    exit;
  for i := 0 to Screen.MonitorCount - 1 do
  begin
    if Screen.Monitors[i].Primary then
      continue;
    currentMonitor := Screen.Monitors[i];
    break;
  end;

  lblMonitor2Descr.Caption := IntToStr(currentMonitor.Width) + ' x ' +
    IntToStr(currentMonitor.Height);
  imageScreen2.Visible := true;
  btnTo2ndMonitor.Visible := true;
end;

procedure TformMain.FillProcessesList;
var
  Wnd: HWND;
  WndName: array [0..127] of Char;
begin
  listBoxProcesses.Clear;
  Wnd := GetWindow(Handle, GW_HWNDFIRST);
  while Wnd <> 0 do
  begin
    if (Wnd <> {Application.}Handle) and IsWindowVisible(Wnd) and
       (GetWindow(Wnd, GW_OWNER) = 0) and
       (GetWindowText(Wnd, WndName, SizeOf(WndName)) <> 0) then
    begin
      GetWindowText(Wnd, WndName, SizeOf(WndName));
      listBoxProcesses.Items.AddObject(StrPas(WndName), TObject(Wnd));
    end;
    Wnd := GetWindow(Wnd, GW_HWNDNEXT);
  end;
  listBoxProcesses.ItemIndex := 0;
  listBoxProcessesClick(nil);
end;

procedure TformMain.FormActivate(Sender: TObject);
begin
  FillProcessesList;
  FillMonitorsList;

  MoveToMonitor(Screen.PrimaryMonitor.MonitorNum + 1, Handle);
end;

procedure TformMain.FormCreate(Sender: TObject);
begin
  if Screen.MonitorCount > 2 then
    MessageDlg('Graphical representation works for first and second monitors only.',
      mtInformation, [mbOK], 0);
end;

procedure TformMain.GetProcessCoordinates;
var
  i :integer;
  coordinates: TRect;
  selectedHandle: THandle;
begin
  for i := 1 to 4 do
    valListEditorCoordinates.Values[valListEditorCoordinates.Keys[i]] := '';

  selectedHandle := GetSelectedProcessHandle;
  if selectedHandle = INVALID_HANDLE_VALUE then
    exit;
  if not GetWindowRect(selectedHandle, coordinates) then
    exit;

  valListEditorCoordinates.Values['Left'] := IntToStr(coordinates.Left);
  valListEditorCoordinates.Values['Top'] := IntToStr(coordinates.Top);
  valListEditorCoordinates.Values['Width'] :=
    IntToStr(coordinates.Right - coordinates.Left);
  valListEditorCoordinates.Values['Height'] :=
    IntToStr(coordinates.Bottom - coordinates.Top);
end;

function TformMain.GetSelectedProcessHandle: HWND;
begin
  Result := INVALID_HANDLE_VALUE;
  if listBoxProcesses.ItemIndex < -1 then
    exit;
  Result := LongWord(listBoxProcesses.Items.Objects[listBoxProcesses.ItemIndex]);
end;

procedure TformMain.listBoxProcessesClick(Sender: TObject);
begin
  GetProcessCoordinates;
end;

procedure TformMain.MoveToMonitor(aMonitorIndex: integer; aHandle: THandle);
var
  currentMonitor: TMonitor;
begin
  if (aMonitorIndex < 1) or (aMonitorIndex > Screen.MonitorCount) then
    exit;

  if aHandle = INVALID_HANDLE_VALUE then
    aHandle := GetSelectedProcessHandle;
  if aHandle = INVALID_HANDLE_VALUE then
    exit;

  currentMonitor := Screen.Monitors[aMonitorIndex - 1];

  SetWindowPos(aHandle, HWND_TOP,
    currentMonitor.Left + 8, currentMonitor.Top + 8, 50, 50, SWP_NOSIZE);
end;

end.
