unit FLACfileTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FLACfile, XPMan, Mask, ExtCtrls, Buttons, Jpeg,
  ExtDlgs, Vcl.ComCtrls, ShellApi, Vcl.Themes, TAGEdit, IniFiles;

type
  {$IFNDEF UNICODE}
  UnicodeString = WideString;
  {$ENDIF}

  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    Label6: TLabel;
    edFile: TEdit;
    GroupBox3: TGroupBox;
    lbFileSize: TLabel;
    lbLength: TLabel;
    lbBitrate: TLabel;
    lbChannels: TLabel;
    lbSamplingRate: TLabel;
    lbVendor: TLabel;
    lbVendor1: TLabel;
    lbVendor2: TLabel;
    Label15: TLabel;
    OpenPictureDialog1: TOpenPictureDialog;
    Label16: TLabel;
    lblBPS: TLabel;
    lbCompressRatio: TLabel;
    lbSamples: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    GroupBox2: TGroupBox;
    lbExtraTags: TListBox;
    Label2: TLabel;
    edTitle: TEdit;
    Label1: TLabel;
    edArtist: TEdit;
    edAlbum: TEdit;
    Label3: TLabel;
    Label9: TLabel;
    edGenre: TEdit;
    lblTrack: TLabel;
    edTrack: TEdit;
    edDate: TEdit;
    Label18: TLabel;
    Label5: TLabel;
    memoComment: TMemo;
    TabSheet4: TTabSheet;
    BitBtn1: TBitBtn;
    StatusBar1: TStatusBar;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Image8: TImage;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    BitBtn8: TBitBtn;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    GroupBox4: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label17: TLabel;
    lblAttribute: TLabel;
    edPicCounter: TEdit;
    cbPictureList: TComboBox;
    edDescription: TEdit;
    Panel1: TPanel;
    TagPic: TImage;
    cbPicTypes: TComboBox;
    cbMIMETypes: TComboBox;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure cbPictureListChange(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure cbPicTypesChange(Sender: TObject);
    procedure cbMIMETypesChange(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure edDateKeyPress(Sender: TObject; var Key: Char);
    procedure edTrackKeyPress(Sender: TObject; var Key: Char);
    procedure CheckBox6Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure CheckBox7Click(Sender: TObject);
    procedure CheckBox8Click(Sender: TObject);
    procedure CheckBox9Click(Sender: TObject);
  private
    { Private declarations }
    PictureInfo: TPictureInfo;
    PictureData: TMemoryStream;

    procedure ClearFields;
    procedure FillExtraTags(Tags : WideString);
    function  GetExtraTags : WideString;
    procedure ViewPicture(PicNo : DWORD);
    function  CheckForChanges : boolean;
  public
    { Public declarations }
    procedure ReadOptions;
    procedure WriteOptions;
  end;

var
  Form1: TForm1;
  TIF : TIniFile;
  TAGEditForm : TTAGEditForm;
  OpenedFLACFile : boolean = false;
  FLACfile : TFLACfile;

const
   MsgConfirmClose = 'There are any changes not saved.'#10#10'Close anyway ?';

implementation

{$R *.dfm}
function MainDir : string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

procedure TForm1.WriteOptions;    // ################### Options Write
var OPT :string;
begin
   OPT := 'Options';

   if not DirectoryExists(MainDir + 'Data\Options\')
   then ForceDirectories(MainDir + 'Data\Options\');

   TIF := TIniFile.Create(MainDir + 'Data\Options\Options.ini');
   with TIF do
   begin
   WriteBool(OPT,'StayTop',CheckBox1.Checked);
   WriteBool(OPT,'HideOnTask',CheckBox2.Checked);
   //WriteBool(OPT,'Skin',CheckBox3.Checked);
   WriteBool(OPT,'SupportMultiImage',CheckBox6.Checked);
   WriteBool(OPT,'Support1MBImage',CheckBox4.Checked);
   WriteBool(OPT,'TryCompressJPG',CheckBox5.Checked);
   WriteBool(OPT,'ReceivedOriginalInformation',CheckBox7.Checked);
   WriteBool(OPT,'Backup',CheckBox8.Checked);
   WriteBool(OPT,'ClearBackup',CheckBox9.Checked);

   //WriteBool(OPT,'SaveOptions',CheckBox1.Checked);
   //WriteInteger(OPT,'Compress',Combobox1.ItemIndex);
   //WriteInteger(OPT,'Overlay',RadioGroup1.ItemIndex);
   Free;
   end;
end;

procedure TForm1.ReadOptions;    // ################### Options Read
var OPT:string;
begin
  OPT := 'Options';
  if FileExists(MainDir + 'Data\Options\Options.ini') then
  begin
  TIF:=TIniFile.Create(MainDir + 'Data\Options\Options.ini');
  with TIF do
  begin
  CheckBox1.Checked:=ReadBool(OPT,'StayTop',CheckBox1.Checked);
  CheckBox2.Checked:=ReadBool(OPT,'HideOnTask',CheckBox2.Checked);
  //CheckBox3.Checked:=ReadBool(OPT,'Skin',CheckBox3.Checked);
  CheckBox6.Checked:=ReadBool(OPT,'SupportMultiImage',CheckBox6.Checked);
  CheckBox4.Checked:=ReadBool(OPT,'Support1MBImage',CheckBox4.Checked);
  CheckBox5.Checked:=ReadBool(OPT,'TryCompressJPG',CheckBox5.Checked);
  CheckBox7.Checked:=ReadBool(OPT,'ReceivedOriginalInformation',CheckBox7.Checked);
  CheckBox8.Checked:=ReadBool(OPT,'Backup',CheckBox8.Checked);
  CheckBox9.Checked:=ReadBool(OPT,'ClearBackup',CheckBox9.Checked);

  //CheckBox1.Checked:=ReadBool(OPT,'SaveOptions',CheckBox1.Checked);
  //Combobox1.ItemIndex:=ReadInteger(OPT,'Compress',combobox1.ItemIndex);
  //RadioGroup1.ItemIndex:=ReadInteger(OPT,'Overlay',RadioGroup1.ItemIndex);
  Free;
  end;
  end;
end;

function DeleteFile(const AFile: string): boolean;
var
 sh: SHFileOpStruct;
begin
 ZeroMemory(@sh, sizeof(sh));
 with sh do
   begin
   Wnd := Application.Handle;
   wFunc := fo_Delete;
   pFrom := PChar(AFile +#0);
   fFlags := fof_Silent or fof_NoConfirmation;
   end;
 result := SHFileOperation(sh) = 0;
end;

procedure FileCopy(von,nach:string);
var src,dest : tFilestream;
begin
  src := tFilestream.create(von,fmShareDenyNone or fmOpenRead);
  try
    dest := tFilestream.create(nach,fmCreate);
    try
      dest.copyfrom(src,src.size);
    finally
      dest.free;
    end;
  finally
  src.free;
end;
end;


procedure TForm1.ClearFields;
begin
   edArtist.Text := '';
   edTitle.Text := '';
   edAlbum.Text := '';
   edGenre.Text := '';
   edTrack.Text := '';
   edDate.Text := '';
   memoComment.Clear;
   lbExtraTags.Clear;

   cbMIMETypes.ItemIndex := -1;
   cbPicTypes.ItemIndex := -1;
   cbPictureList.Clear;
   edDescription.Text := '';
   lblAttribute.Caption := '';
end;

procedure TForm1.edDateKeyPress(Sender: TObject; var Key: Char);
begin
  If not (Key in [#46, #48..#57, #8]) then Key := #0;
end;

procedure TForm1.edTrackKeyPress(Sender: TObject; var Key: Char);
begin
  If not (Key in [#48..#57, #8]) then Key := #0;
end;

procedure TForm1.FillExtraTags(Tags : WIdeString);
var
   TAGStr : WideString;
   tmpStr : WideString;
   SeperatorPos : integer;

begin
   if Tags = '' then
      exit;

     tmpStr := Tags;
     repeat
        SeperatorPos := pos(WideChar(0), tmpStr);
        if SeperatorPos > 0 then
        begin
           TAGStr := copy(tmpStr, 1, SeperatorPos - 1);
           tmpStr := copy(tmpStr, SeperatorPos + 1, length(tmpStr) - SeperatorPos);
        end else
           TAGStr := tmpStr;

        lbExtraTags.Items.Add(TAGStr);

     until (SeperatorPos = 0);
end;

function TForm1.GetExtraTags : WideString;
var
   i : integer;
begin
   result := '';

   for i := 1 to lbExtraTags.Items.Count do
      if result = '' then
         result := lbExtraTags.Items[i-1]
      else
         result := result + WideChar(0) + lbExtraTags.Items[i-1];
end;

procedure TForm1.ViewPicture(PicNo : DWORD);
var
   PicType: DWORD;
   MIME: AnsiString;
   Description: UnicodeString;
   PicInfo: TPictureInfo;
   tmpPictureData: TMemoryStream;
   jp: TJPEGImage;
   i : integer;
begin
   tmpPictureData := TMemoryStream.Create;
   if FLACfile.GetPicture(cbPictureList.ItemIndex, PicType, MIME, Description, PicInfo, tmpPictureData) then
   begin
      cbPicTypes.ItemIndex := PicType;
      for i := 1 to (cbMIMETypes.Items.Count - 1) do
         if (cbMIMETypes.Items[i] = MIME) then
         begin
            cbMIMETypes.ItemIndex := i;
            break;
         end;
      edDescription.Text := Description;

      tmpPictureData.Seek(0, soFromBeginning);
      jp := TJPEGImage.Create;
      try
        try
          jp.LoadFromStream(tmpPictureData);
          jp.DIBNeeded;
          TagPic.Picture.Bitmap.Assign(jp);
        // PicInfo may does not have correct value of Width, Height..
        // So, get the data from image property directly.
          PictureInfo.Width := jp.Width;
          PictureInfo.Height := jp.Height;
          if jp.PixelFormat = jf24Bit then
             PictureInfo.BitsPerPixel := 24
          else
             PictureInfo.BitsPerPixel := 8;
          PictureInfo.Colors := 0; // 0 : non-indexed picture
          lblAttribute.Caption := intToStr(jp.Width) + ' x ' + intToStr(jp.Height)
                              + ' (' + intToStr(PictureInfo.BitsPerPixel) + 'bpp)';
          lblAttribute.Visible := true;
        // If image on panel is changed then clear previously loaded data from a image file,
        //  to avoid confusion.
          if Assigned(PictureData) then
             PictureData.Clear;
        except
          TagPic.Picture.Assign(nil);
        end;
      finally
        jp.Free;

      end;
   end;

   tmpPictureData.Free;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked = true then begin
  SetWindowPos(Handle, HWND_TOPMOST, Left,Top, Width,Height,
             SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
  end else begin
  SetWindowPos(Handle, HWND_NOTOPMOST, Left,Top, Width,Height,
             SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
  end;
  StatusBar1.SetFocus;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.Checked = true then
  ShowWindow(Application.Handle, SW_HIDE) else
  ShowWindow(Application.Handle, SW_SHOW);
  StatusBar1.SetFocus;
end;

procedure TForm1.CheckBox4Click(Sender: TObject);
begin
  StatusBar1.SetFocus;
end;

procedure TForm1.CheckBox5Click(Sender: TObject);
begin
  StatusBar1.SetFocus;
end;

procedure TForm1.CheckBox6Click(Sender: TObject);
begin
  if CheckBox6.Checked = true then begin
  Label10.Enabled := true; Label11.Enabled := true;
  edPicCounter.Enabled := true;
  cbPictureList.Enabled := true;
  end else begin
  Label10.Enabled := false; Label11.Enabled := false;
  edPicCounter.Enabled := false;
  cbPictureList.Enabled := false;
  end;

  StatusBar1.SetFocus;
end;

procedure TForm1.CheckBox7Click(Sender: TObject);
begin
  StatusBar1.SetFocus;
end;

procedure TForm1.CheckBox8Click(Sender: TObject);
begin
  StatusBar1.SetFocus;
end;

procedure TForm1.CheckBox9Click(Sender: TObject);
begin
  StatusBar1.SetFocus;
end;

function TForm1.CheckForChanges : boolean;
var
  // edTrack_Value : word;
   lbTags_ : TStringList;
   i, j : integer;
   FoundMatched : boolean;

  procedure SetExtraTags(Tags : WideString; const lbTags : TStringList);
  var
    TAGStr : WideString;
    tmpStr : WideString;
    SeperatorPos : integer;

  begin
    if Tags = '' then
      exit;

    tmpStr := Tags;
    repeat
        SeperatorPos := pos(WideChar(0), tmpStr);
        if SeperatorPos > 0 then
        begin
           TAGStr := copy(tmpStr, 1, SeperatorPos - 1);
           tmpStr := copy(tmpStr, SeperatorPos + 1, length(tmpStr) - SeperatorPos);
        end else
           TAGStr := tmpStr;

        lbTags.Add(TAGStr);

    until (SeperatorPos = 0);
  end;

begin
   result := false;

  { if edTrack.Text = '' then
      edTrack_Value := 0
   else
      edTrack_Value := StrToInt(edTrack.Text); }

   if (FLACfile.Artist <> trim(edArtist.Text)) or
      (FLACfile.Title <> trim(edTitle.Text)) or
      (FLACfile.Album <> trim(edAlbum.Text)) or
      (FLACfile.Genre <> trim(edGenre.Text)) or
      (FLACfile.Date <> trim(edDate.Text)) or
      (FLACfile.Track <> trim(edTrack.Text)) or
      (FLACfile.Comment <> trim(memoComment.Text)) then
      begin
         result := true;
         exit;
      end;

   if FLACfile.ExtraTag <> '' then
   begin
      if lbExtraTags.Items.Count <> 0 then
      begin
         lbTags_ := TStringList.Create;
         SetExtraTags(FLACfile.ExtraTag, lbTags_);
         if lbTags_.Count = lbExtraTags.Items.Count then
         begin
            for i := 1 to lbTags_.Count do
            begin
              FoundMatched := false;
              for j := 1 to lbTags_.Count do
                if lbTags_[i-1] = lbExtraTags.Items[j-1] then
                begin
                  FoundMatched := true;
                  break;
                end;
              if not FoundMatched then
              begin
                lbTags_.Free;
                result := true;
                exit;
              end;
            end;
         end else
         begin
            lbTags_.Free;
            result := true;
            exit;
         end;

         lbTags_.Free;
      end else
      begin
        result := true;
        exit;
      end;
   end else
     if lbExtraTags.Items.Count <> 0 then
       result := true;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if Assigned(FLACfile) then
     if FLACfile.Valid then
       if CheckForChanges then
         if MessageBox(Self.Handle, MsgConfirmClose, '»Æ¿Œ', MB_YESNO + MB_ICONQUESTION) <> ID_YES then
         begin
            Action := caNone;
            exit;
         end;

   TAGEditForm.Free;
   if Assigned(PictureData) then PictureData.Free;
   if Assigned(FLACfile) then FLACfile.Free;
   if CheckBox9.Checked = true then begin
   DeleteFile(MainDir+ 'Data\Backup\*.*');
   end;
   WriteOptions;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  if not FileExists(MainDir + 'Data\Drivers\FLACEdit.dll') then begin
  ShowMessage('Error "FLACEdit.dll" not found, check Drivers Folder !');
  Application.Terminate; end;

  if not FileExists(MainDir + 'Data\Drivers\FLACfile.dll') then begin
  ShowMessage('Error "FLACfile.dll" not found, check Drivers Folder !');
  Application.Terminate; end;


end;

procedure TForm1.FormShow(Sender: TObject);
var
   i : integer;
begin
   ReadOptions;
   TAGEditForm := TTAGEditForm.Create(Self);
   edFile.Text := '';
   edArtist.Text := '';
   edTitle.Text := '';
   edAlbum.Text := '';
   edGenre.Text := '';
   edDate.Text := '';
   edTrack.Text := '';

   CheckBox6.OnClick(Sender);

   for i := 1 to PictureTypes do
      cbPicTypes.Items.Add(GetPictureTypeStr(i-1));
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
   TimeStr : string;
   tmpStr : string;
   SpacePos, SpacePos2 : integer;
   N : DWORD;
   i : integer;
begin
   if OpenDialog1.Execute then
   begin
      if not Assigned(FLACfile) then
         FLACfile := TFLACfile.Create;
      FLACfile.ReadFromFile(OpenDialog1.FileName);
      if not FLACfile.Valid then
      begin
         ClearFields;
         MessageBox(Self.Handle, 'Not a valid FLAC file.', 'Information', MB_OK + MB_ICONINFORMATION);
         Exit;
      end;

      ClearFields;
      edFile.Text := OpenDialog1.FileName;
      if FLACfile.Artist <> '' then edArtist.Text := FLACfile.Artist;
      if FLACfile.Title <> '' then edTitle.Text := FLACfile.Title;
      if FLACfile.Album <> '' then edAlbum.Text := FLACfile.Album;
      if FLACfile.Genre <> '' then edGenre.Text := FLACfile.Genre;
      if FLACfile.Date <> '' then edDate.Text := FLACfile.Date;
     { if FLACfile.Track = 0 then
         edTrack.Text := ''
      else
         edTrack.Text := intToStr(FLACfile.Track); }
      edTrack.Text := FLACfile.Track;
      if FLACfile.Comment <> '' then
         memoComment.Text := FLACfile.Comment;
      if FLACfile.ExtraTag <> '' then
         FillExtraTags(FLACfile.ExtraTag);

      lbFileSize.Caption := 'File size: ' + FormatFloat('#,# byte', FLACfile.FileSize);
      TimeStr := FormatDateTime('nn:ss.zzz', FLACfile.Duration / (24 * 60 * 60));
      if TimeStr[1] = '0' then
         lbLength.Caption := 'Length: ' + copy(TimeStr, 2, 8) + ' second'
      else
         lbLength.Caption := 'Length: ' + TimeStr + ' second';
      lbBitrate.Caption := 'Bitrate: ' + intToStr(FLACfile.BitRate) + ' KBPS';
      lbChannels.Caption := 'Channels: ' + intToStr(FLACfile.Channels);
      lbSamples.Caption := 'Samples: ' + FormatFloat('#,#', FLACfile.Samples);
      lblBPS.Caption := 'Bits Per Sample: ' + intToStr(FLACfile.BitsPerSample);
      lbSamplingRate.Caption := 'Sampling rate: ' + FormatFloat('#,# Hz', FLACfile.SampleRate);
      lbCompressRatio.Caption := 'Compression Ratio: ' + FormatFloat('0.0 %', FLACfile.CompressRatio);
      if length(FLACfile.Vendor) < 25 then
      begin
         lbVendor1.Caption := FLACfile.Vendor;
         lbVendor2.Caption := '';
         if not lbVendor1.Visible then
            lbVendor1.Visible := true;
      end else
      begin
         SpacePos := pos(' ', FLACfile.Vendor);
         if SpacePos < 25 then
         begin
            SpacePos2 := 0;
            repeat
               SpacePos := SpacePos + SpacePos2;
               tmpStr := copy(FLACfile.Vendor, SpacePos+1, 50);
               SpacePos2 := pos(' ', tmpStr);
            until (SpacePos2 = 0) or (SpacePos + SpacePos2 > 25);
         end;
         lbVendor1.Caption := copy(FLACfile.Vendor, 1, SpacePos-1);
         lbVendor2.Caption := copy(FLACfile.Vendor, SpacePos+1, 25);
         if not lbVendor1.Visible then lbVendor1.Visible := true;
         if not lbVendor2.Visible then lbVendor2.Visible := true;
      end;
      N := FLACfile.NumPictures;
      if N > 0 then
      begin
         for i := 1 to N do
            cbPictureList.Items.Add(intToStr(i));
         cbPictureList.ItemIndex := 0;
         ViewPicture(0);
      end else
         TagPic.Picture.Assign(nil);
      edPicCounter.Text := intToStr(N);
      OpenedFLACFile := true;
   end;
   StatusBar1.Panels[1].Text := ExtractFileName(OpenDialog1.FileName);
end;
procedure TForm1.BitBtn2Click(Sender: TObject);
var
   TAGStr : string;
   EqualPos : integer;
   TAGID : string;
begin
   if lbExtraTags.ItemIndex < 0 then
   begin
      MessageBox(Self.Handle, 'Select an item to modify.', 'Information', MB_OK + MB_ICONINFORMATION);
      exit;
   end;

   TAGStr := lbExtraTags.Items[lbExtraTags.ItemIndex];
   EqualPos := pos('=', TAGStr);
   TAGID := copy(TAGStr, 1, EqualPos - 1);
   TAGEditForm.TAGName.Text := TAGID;
   TAGEditForm.TAGValue.Text := copy(TAGStr, EqualPos + 1, length(TAGStr) - EqualPos);
   TAGEditForm.TAGName.ReadOnly := true;
   if TAGEditForm.ShowModal = mrOK then
   begin
      if (trim(TAGEditForm.TAGValue.Text) = '') then
      begin
         MessageBox(Self.Handle, 'Put item value first.', 'Information', MB_OK + MB_ICONINFORMATION);
         exit;
      end;

      lbExtraTags.Items[lbExtraTags.ItemIndex] := TAGID + '=' + TAGEditForm.TAGValue.Text;
   end;  StatusBar1.SetFocus;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
var
   i, EqualPos : integer;
   TAGID, tmpStr : string;
begin
   if not OpenedFLACFile then
   begin
      MessageBox(Self.Handle, 'Not opened a FLAC file.', 'Information', MB_OK + MB_ICONINFORMATION);
      Exit;
   end;

   TAGEditForm.TAGName.Text := '';
   TAGEditForm.TAGValue.Clear;
   TAGEditForm.TAGName.ReadOnly := false;
   if TAGEditForm.ShowModal = mrOK then
   begin
      TAGID := UPPERCASE(trim(TAGEditForm.TAGName.Text));
      for i := 1 to VORBIS_FIELD_COUNT do
         if TAGID = VORBIS_FIELD[i] then
         begin
            MessageBox(Self.Handle, 'Can''t add predefined TAG ID, Operation canceled.', 'Information',
                                            MB_OK + MB_ICONINFORMATION);
            exit;
         end;

      for i := 0 to (lbExtraTags.Items.Count - 1) do
      begin
         EqualPos := pos('=', lbExtraTags.Items[i]);
         tmpStr := copy(lbExtraTags.Items[i], 1, EqualPos - 1);
         if TAGID = tmpStr then
         begin
            MessageBox(Self.Handle, 'Duplicate TAG ID, Operation canceled.', 'Information',
                                                        MB_OK + MB_ICONINFORMATION);
            exit;
         end;
      end;

      lbExtraTags.Items.Add(TAGID + '=' + trim(TAGEditForm.TAGValue.Text));
   end; StatusBar1.SetFocus;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
  if lbExtraTags.ItemIndex < 0 then
   begin
      MessageBox(Self.Handle, 'Select an item to delete.', 'Information', MB_OK + MB_ICONINFORMATION);
      exit;
   end;
   lbExtraTags.Items.Delete(lbExtraTags.ItemIndex);
   StatusBar1.SetFocus;
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
var
  jp: TJPEGImage;
begin
  if not OpenedFLACFile then
   begin
      MessageBox(Self.Handle, 'Not opened a FLAC file.', 'Information', MB_OK + MB_ICONINFORMATION);
      exit;
   end;
  if OpenPictureDialog1.Execute then
  begin
    jp := TJpegImage.Create;
    try
      try
        jp.LoadFromFile(OpenPictureDialog1.FileName);
        jp.DIBNeeded;
        TagPic.Picture.Bitmap.Assign(jp);
        PictureInfo.Width := jp.Width;
        PictureInfo.Height := jp.Height;
        if jp.PixelFormat = jf24Bit then
           PictureInfo.BitsPerPixel := 24
        else
           PictureInfo.BitsPerPixel := 8;
        PictureInfo.Colors := 0; // 0 : non indexed-color picture
        lblAttribute.Caption := intToStr(jp.Width) + ' x ' + intToStr(jp.Height)
                              + ' (' + intToStr(PictureInfo.BitsPerPixel) + 'bpp)';
        lblAttribute.Visible := true;
        cbPicTypes.ItemIndex := -1;
        cbMIMETypes.ItemIndex := 3;
        edDescription.Text := '';
        if Assigned(PictureData) then
           PictureData.Clear
        else
           PictureData := TMemoryStream.Create;
        jp.SaveToStream(PictureData);
      except
        TagPic.Picture.Assign(nil);
      end;
    finally
      jp.Free;
    end;
  end;
  StatusBar1.SetFocus;
end;

procedure TForm1.BitBtn6Click(Sender: TObject);
var
   i : integer;
begin
   if not OpenedFLACFile then
   begin
      MessageBox(Self.Handle, 'Not opened a FLAC file.', 'Information', MB_OK + MB_ICONINFORMATION);
      exit;
   end;

   if TagPic.Picture.Bitmap.Empty or (not Assigned(PictureData)) then
   begin
      MessageBox(Self.Handle, 'Not loaded a picture image.', 'Information', MB_OK + MB_ICONINFORMATION);
      exit;
   end;

   if PictureData.Size = 0 then
   begin
      MessageBox(Self.Handle, 'Not loaded a picture image.', 'Information', MB_OK + MB_ICONINFORMATION);
      exit;
   end;

   if trim(edDescription.Text) = '' then
      if MessageBox(Self.Handle, 'Description field is empty.'#10#10'Proceed ?', 'Confirm', MB_YESNO + MB_ICONQUESTION) <> ID_YES then
         exit;

   if (cbPicTypes.ItemIndex = -1) then
      if MessageBox(Self.Handle, 'Picture type is not specified.'#10#10'Proceed with default value ?',
                       'Confirm', MB_YESNO + MB_ICONQUESTION) <> ID_YES then
         exit;

   if cbPicTypes.ItemIndex = -1 then
      cbPicTypes.ItemIndex := 0;
   cbMIMETypes.ItemIndex := 3;

 // Check if the picture with specified picture type, MIME & description exists.
   if FLACfile.GetPictureNo(cbPicTypes.ItemIndex, cbMIMETypes.Text, trim(edDescription.Text)) <> -1 then
      if MessageBox(Self.Handle, 'A picture with specified picture type, MIME & description exists.'#10#10'Proceed ?',
                       'Confirm', MB_YESNO + MB_ICONQUESTION) <> ID_YES then
         exit;

   if FLACfile.SavePicture(cbPicTypes.ItemIndex,
                           cbMIMETypes.Text, trim(edDescription.Text),
                           PictureInfo, PictureData) then
   begin
      PictureData.Clear;
     // Reload Picture tag data
     cbPictureList.Clear;
     edPicCounter.Text := intToStr(FLACfile.NumPictures);
     if FLACfile.NumPictures > 0 then
     begin
        for i := 1 to FLACfile.NumPictures do
          cbPictureList.Items.Add(intToStr(i));
        cbPictureList.ItemIndex := FLACfile.NumPictures-1;
        ViewPicture(FLACfile.NumPictures-1);
     end;
   end else
     MessageBox(Self.Handle, 'Failed to save a picture.'#10#10'Check if FLAC file is being used by other application.', 'Information', MB_OK + MB_ICONINFORMATION);
   StatusBar1.SetFocus;
end;

procedure TForm1.BitBtn7Click(Sender: TObject);
var
   i : integer;
begin
   if not OpenedFLACFile then
   begin
      MessageBox(Self.Handle, 'Not opened a FLAC file.', 'Information', MB_OK + MB_ICONINFORMATION);
      exit;
   end;

   if FLACfile.NumPictures = 0 then
   begin
      MessageBox(Self.Handle, 'No picture to be deleted.', 'Information', MB_OK + MB_ICONINFORMATION);
      exit;
   end;

   if MessageBox(Self.Handle, 'A picture will be deleted permanently.'#10#10'Proceed ?',
                       'Confirm', MB_YESNO + MB_ICONQUESTION) <> ID_YES then
      exit;

   if FLACfile.DeletePicture(cbPictureList.ItemIndex) then
      edPicCounter.Text := intToStr(FLACfile.NumPictures)
   else begin
      MessageBox(Self.Handle, 'Failed to delete a picture.'#10#10'Check if FLAC file is being used by other application.', 'Information', MB_OK + MB_ICONINFORMATION);
      exit;
   end;

 // Reload Picture tag data
   cbPictureList.Clear;
   edPicCounter.Text := intToStr(FLACfile.NumPictures);
   if FLACfile.NumPictures > 0 then
   begin
      for i := 1 to FLACfile.NumPictures do
         cbPictureList.Items.Add(intToStr(i));
      cbPictureList.ItemIndex := 0;
      ViewPicture(0);
   end else
   begin
      TagPic.Picture.Assign(nil);
      cbPicTypes.ItemIndex := -1;
      cbMIMETypes.ItemIndex := -1;
      edDescription.Text := '';
      lblAttribute.Visible := false;
   end;
   StatusBar1.SetFocus;
end;

procedure TForm1.BitBtn8Click(Sender: TObject);
begin
  if CheckBox8.Checked = true then begin
  FileCopy(OpenDialog1.FileName, MainDir + 'Data\Backup\' + ExtractFileName(OpenDialog1.FileName));
  end;


  if not OpenedFLACFile then
   begin
      MessageBox(Self.Handle, 'Not opened a FLAC file.', 'Information', MB_OK + MB_ICONINFORMATION);
      Exit;
   end;

   FLACfile.Artist := edArtist.Text;
   FLACfile.Title := edTitle.Text;
   FLACfile.Album := edAlbum.Text;
   FLACfile.Genre := edGenre.Text;
   FLACfile.Date := edDate.Text;
  { if edTrack.Text = '' then
      FLACfile.Track := 0
   else
      FLACfile.Track := StrToInt(edTrack.Text); }
   FLACfile.Track := edTrack.Text;
   FLACfile.Comment := memoComment.Text;
   FLACfile.ExtraTag := GetExtraTags;
 //  if not FLACfile.SaveTag(OpenDialog1.FileName) then
   if not FLACfile.SaveTag then begin
      MessageBox(Self.Handle, 'Failed to update tag.'#10#10'Check if FLAC file is being used by other application.', 'Information', MB_OK + MB_ICONINFORMATION);
   Exit; end;

   MessageBox(Self.Handle, 'Tags Saved done!', 'Save Tag', MB_OK + MB_ICONINFORMATION);

   StatusBar1.SetFocus;
end;

procedure TForm1.cbMIMETypesChange(Sender: TObject);
begin
  StatusBar1.SetFocus;
end;

procedure TForm1.cbPictureListChange(Sender: TObject);
begin
   if cbPictureList.ItemIndex >= 0 then
      ViewPicture(cbPictureList.ItemIndex);
   StatusBar1.SetFocus;
end;

procedure TForm1.cbPicTypesChange(Sender: TObject);
begin
  StatusBar1.SetFocus;
end;

end.
