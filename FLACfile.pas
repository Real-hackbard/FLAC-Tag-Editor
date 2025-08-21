// Unit to get the attribute and to edit tag data of FLAC file.
//
//  note) The source units of Tnt Delphi UNICODE Controls are needed if you compile this unit
//        with Delphi 2007 or earlier version.
//
//  Author : Silhwan Hyun (hyunsh@hanafos.com)
//
//
//  Version 0.9.2   (3 Sep 2010)
//   - Changed a property type : Track (from Word to UnicodeString)
//   - Added a property : CompressRatio
//   - Renamed a property : from BitPerSample to BitsPerSample
//   - Removed the need of include file Delphi_Ver.inc
//
//  Version 0.9.1   (23 Jul 2010)
//   - Added a property & functions to support Picture Tags.
//     ( property NumPictures, function GetPicture, function GetPictureTypeStr,
//       function SavePicture, function DeletePicture )
//   - Fixed some critical bugs such as file corruption after saving tag data.
//
//  initial Version : 0.9.0,  Date : 05 July 2010
//
//
//  #### Copyright Notice ####
// Delphi unit FLACfile.pas    Copyright Silhwan Hyun.
// All rights reserved.

// FLACfile.pas is free. It may be used both in commercial and non-commercial software
//  either in original or in modified form.
// FLACfile.pas can be freely distributed in any way and by any means provided this copyright
//  notice is preserved.


unit FLACfile;

interface

// {$INCLUDE Delphi_Ver.inc}

uses
  Classes, Windows, SysUtils,
  {$IFNDEF UNICODE} TntClasses, TntSysUtils {$ELSE} AnsiStrings, StrUtils{$ENDIF};

const
  PictureTypes = 21;
  VORBIS_FIELD_COUNT = 7;  // Number of supported tag fields

  { Names of supported tag fields }
  VORBIS_FIELD: array [1..VORBIS_FIELD_COUNT] of AnsiString =
    ('TITLE', 'ARTIST', 'ALBUM', 'TRACKNUMBER', 'DATE', 'GENRE', 'COMMENT');

type
  {$IFNDEF UNICODE}
  UnicodeString = WideString;
  {$ENDIF}

  TBlockRec = record
    BlockType: byte;      // Block Type (STREAMINFO=1, PADDING=3, APPLICATION=3,... , PICTURE=7)
    BlockPos: Int64;      // Block Position in file
    BlockSize: DWORD;     // Block Size in bytes
  end;
  TBlockTable = array of TBlockRec;

  TPictureInfo = record
    Width: DWORD;        // The width of the picture in pixels.
    Height: DWORD;       // The height of the picture in pixels.
    BitsPerPixel: DWORD; // The color depth of the picture in bits-per-pixel.
    Colors : DWORD;      // For indexed-color pictures (e.g. GIF), the number of colors used,
                         //  or 0 for non-indexed pictures.
  end;

  TPictureTag = record
    PicType: DWORD;            // The picture type according to the ID3v2 APIC frame.
    MIME: AnsiString;          // The MIME type string, in printable ASCII characters 0x20-0x7e.
    Description: UnicodeString;   // The description of the picture.
    PicWidth: DWORD;           // The width of the picture in pixels.
    PicHeight: DWORD;          // The height of the picture in pixels.
    BitsPerPixel: DWORD;       // The color depth of the picture in bits-per-pixel.
    Colors: DWORD;             // For indexed-color pictures (e.g. GIF), the number of colors used, or 0 for non-indexed pictures.
    Datalen: DWORD;            // The length of the picture data in bytes.
    DataPos: int64;            // The position of the picture data in file.
    BlockNumber: DWORD;        // The block number in file.  (first block = 0, second block = 1...)
  end;
  TPictureTable = array of TPictureTag;

  TFLAC_MD5 = array[0..15] of byte;  // Array to hold MD5 signature of the unencoded audio data.

  {$IFDEF UNICODE}
  TAnsiStringStream = class(TStream)
  private
    FDataString: ansistring;
    FPosition: Integer;
  protected
    procedure SetSize(NewSize: Longint); override;
  public
    constructor Create(const AString: ansistring);
    function Read(var Buffer; Count: Longint): Longint; override;
    function ReadString(Count: Longint): ansistring;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    procedure WriteString(const AString: ansistring);
    property DataString: ansistring read FDataString;
  end;
  {$ENDIF}

  { Class TFLACfile }
  TFLACfile = class(TObject)
  private
    { Private declarations }
    FFileName: UnicodeString;
    FFileSize: Int64;
    FChannels: integer;
    FSampleRate: integer;
    FBitsPerSample: integer;
    FSamples: int64;
    FDuration: Double;
    FTrack: UnicodeString;
    FTitle: UnicodeString;
    FArtist: UnicodeString;
    FAlbum: UnicodeString;
    FDate: UnicodeString;
    FGenre: UnicodeString;
    FComment: UnicodeString;
    FExtraTag: UnicodeString;
    FVendor: UnicodeString;
    FMD5Signature: TFLAC_MD5;

    FNumBlocks: DWORD;
    FBlockTable: TBlockTable;
    FNumPictures: DWORD;
    FPictureTags: TPictureTable;
    FInhibitDuplicate: boolean;

    procedure FResetData;
    function FGetBitRate: Word;
    function FGetCompressRatio: Double;
    function FIsValid: Boolean;

  public
    { Public declarations }
    constructor Create;                                          { Create object }
    destructor Destroy; override;                                { Destroy object }
    function ReadFromFile(const FileName: UnicodeString): Boolean;  { Load data }
    property Valid: Boolean read FIsValid;                       { True if file valid }
    function SaveTag(const FileName: UnicodeString): Boolean; Overload;   { Save tag data }
    function SaveTag: Boolean; Overload;                         { Save tag data }
    property FileSize: Int64 read FFileSize;                     { File size (bytes) }
    property Channels: integer read FChannels;                   { Num of Channels }
    property SampleRate: integer read FSampleRate;               { Sample rate (hz) }
    property BitsPerSample: integer read FBitsPerSample;         { Bits per Sample }
    property Samples: int64 read FSamples;                       { Number of total samples }
    property Title: UnicodeString read FTitle write FTitle;      { Song title }
    property Artist: UnicodeString read FArtist write FArtist;   { Artist name }
    property Album: UnicodeString read FAlbum write FAlbum;      { Album name }
    property Track: UnicodeString read FTrack write FTrack;      { Track number }
    property Date: UnicodeString read FDate write FDate;         { Year }
    property Genre: UnicodeString read FGenre write FGenre;      { Genre name }
    property Comment: UnicodeString read FComment write FComment;{ Comment }
    property NumPictures: DWORD read FNumPictures;               { Number of picture tags }
    property ExtraTag: UnicodeString read FExtraTag write FExtraTag; { Merged data of non-supported tag fields }
    property Vendor: UnicodeString read FVendor;                 { Vendor string }
    property Duration: Double read FDuration;                    { Duration in second }
    property BitRate: Word read FGetBitRate;                     { Average bit rate in KBPS }
    property CompressRatio: Double read FGetCompressRatio;       { Compression Ration in % }
    property MD5Signature: TFLAC_MD5 read FMD5Signature;         { MD5 signature of the unencoded audio data }

  // Get the picture # of specified picture type, MIME & description.
  // Use '*' as Description to get the first picture # mathcing the picture type and MIME.
  // Returns -1 if there is no specified picture in picture tags.
    function GetPictureNo(PicType: DWORD;
                          MIME: AnsiString;
                          Description: UnicodeString): integer;
    function GetPicture(PicNo : DWORD;                   // Get a picture data (PicNo : Picuture # to get data)
                        out PicType: DWORD;
                        out MIME: AnsiString;
                        out Description: UnicodeString;
                        out PictureInfo: TPictureInfo;
                        PictureData: TStream): boolean;
    function SavePicture(PicType: DWORD;                  // Add (or replace) a picture data
                         MIME: AnsiString;
                         Description: UnicodeString;
                         PictureInfo: TPictureInfo;
                         PictureData: TStream): boolean; // Delete a picture data
    function DeletePicture(PicNo: DWORD): boolean;
  end;

  function GetPictureTypeStr(PictureType: DWORD): AnsiString;

implementation

const
{ See http://flac.sourceforge.net/format.html for complete explanation about FLAC format. }
  FLAC_ID = 'fLaC';

  {constants for block types}
  btStreamInfo     = 0;
  btPadding        = 1;
  btApplication    = 2;
  btSeekable       = 3;
  btVorbis_Comment = 4;
  btCueSheet       = 5;
  btPicture        = 6;

  PictureTypeStr : array[0..PictureTypes-1] of AnsiString =
                      ('Other',                                // 0
                       '32x32 pixels "file icon" (PNG only)',  //  1
                       'Other file icon',                      //  2
                       'Cover (front)',                        //  3
                       'Cover (back)',                         //  4
                       'Leaflet page',                         //  5
                       'Media (e.g. label side of CD)',        //  6
                       'Lead artist/lead performer/soloist',   //  7
                       'Artist/performer',                     //  8
                       'Conductor',                            //  9
                       'Band/Orchestra',                       // 10
                       'Composer',                             // 11
                       'Lyricist/text writer',                 // 12
                       'Recording Location',                   // 13
                       'During recording',                     // 14
                       'During performance',                   // 15
                       'Movie/video screen capture',           // 16
                       'A bright coloured fish',               // 17
                       'Illustration',                         // 18
                       'Band/artist logotype',                 // 19
                       'Publisher/Studio logotype');           // 20

type
  TFileID = array[1..4] of AnsiChar;
  TBlockHeader = packed record
    BlockType: byte;
    BlockSize: array[1..3] of byte;
  end;

  TBlock_StreamInfo = packed record
    MinBlockSize: array[1..2] of byte;
    MaxBlockSize: array[1..2] of byte;
    MinFlameSize: array[1..3] of byte;
    MaxFlameSize: array[1..3] of byte;
    SampleRate: array[1..3] of byte;   // 4bit of right side in SampleRate[3] is used for for other purpose
    TotalSamples: array[1..5] of byte; // 4bit of left side in TotalSamples[1] is used for for other purpose
                                       // Above 8(4+4)bits constitutes Number of Channel(3bits) + Bits per Sample(5bits)
    MD5Signature: TFLAC_MD5;
  end;

  { Vorbis tag data }
  VorbisTag = record
    Fields: Integer;                                         { Number of tag fields }
    FieldData: array [0..VORBIS_FIELD_COUNT] of UnicodeString;  { Data of supported tag fields }
    ExtraField: UnicodeString;                                  { Data of non-supported tag fields }
  end;

  { File data }
  FileInfo = record
    FileID: TFileID;                            { File Identifier -> Should be "fLaC" }
    Tag: VorbisTag;                             { Vorbis tag data }
    FileSize: Int64;                            { File size (bytes) }
    SampleRate: Integer;                        { Sampling rate in Hz }
    Channels: Integer;                          { Number of Channel }
    BitsPerSample: Integer;                     { Bits per Sample }
    Samples: Int64;                             { Total samples in stream }
    Duration: Double;                           { Playback duration in seconds }
    MD5Signature: TFLAC_MD5;                    { MD5 signature of the unencoded audio data }
    NumBlocks: DWORD;                           { Number of metadata blocks }
    BlockTable: TBlockTable;                    { Metadata block allocation table }
    NumPictures: DWORD;                         { Number of pictures(= PICTURE blocks) }
    PictureTags: TPictureTable;                 { Collection of picture tags }
  end;

const
  HeaderSize = SizeOf(TBlockHeader);

{$IFDEF UNICODE}
constructor TAnsiStringStream.Create(const AString: ansistring);
begin
  inherited Create;
  FDataString := AString;
end;

function TAnsiStringStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := Length(FDataString) - FPosition;
  if Result > Count then Result := Count;
  Move(PAnsiChar(@FDataString[FPosition + 1])^, Buffer, Result);
  Inc(FPosition, Result);
end;

function TAnsiStringStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result := Count;
  SetLength(FDataString, (FPosition + Result));
  Move(Buffer, PAnsiChar(@FDataString[FPosition + 1])^, Result);
  Inc(FPosition, Result);
end;

function TAnsiStringStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: FPosition := FPosition + Offset;
    soFromEnd: FPosition := Length(FDataString) - Offset;
  end;
  if FPosition > Length(FDataString) then
    FPosition := Length(FDataString)
  else if FPosition < 0 then FPosition := 0;
  Result := FPosition;
end;

function TAnsiStringStream.ReadString(Count: Longint): Ansistring;
var
  Len: Integer;
begin
  Len := Length(FDataString) - FPosition;
  if Len > Count then Len := Count;
  SetString(Result, PAnsiChar(@FDataString[FPosition + 1]), Len);
  Inc(FPosition, Len);
end;

procedure TAnsiStringStream.WriteString(const AString: Ansistring);
begin
  Write(PAnsiChar(AString)^, Length(AString));
end;

procedure TAnsiStringStream.SetSize(NewSize: Longint);
begin
  SetLength(FDataString, NewSize);
  if FPosition > NewSize then FPosition := NewSize;
end;

{$ENDIF}


procedure TFLACfile.FResetData;
begin
  { Reset variables }
  FFileSize := 0;
  FChannels := 0;
  FSampleRate := 0;
  FChannels := 0;
  FBitsPerSample := 0;
  FSamples := 0;
  FDuration := 0;
 // FTrack := 0;
  FNumBlocks := 0;
  FNumPictures := 0;

  FTitle := '';
  FTrack := '';
  FArtist := '';
  FAlbum := '';
  FDate := '';
  FGenre := '';
  FComment := '';
  FExtraTag := '';
  FVendor := '';

  FillChar(FMD5Signature, 16, 0);
end;

constructor TFLACfile.Create;
begin
  { Object constructor }
 // Because there is no uniqueness constraint on the description field of PICTURE block,
 // FInhibitDuplicate is always false which means pictures with same description
 // can be co-existed.
 // However you can use FInhibitDuplicate as a debug purpose.
  FInhibitDuplicate := false;  // Allow pictures with same description.
  FResetData;

  inherited;
end;

destructor TFLACfile.Destroy;
begin
  { Object destructor }
  SetLength(FBlockTable, 0);
  SetLength(FPictureTags, 0);

  inherited;
end;

function GetTrack(const TrackString: string): Byte;
var
  Index, Value, Code: Integer;
begin
  { Extract track from string }
  Index := Pos('/', TrackString);
  if Index = 0 then
    Val(TrackString, Value, Code)
  else
    Val(Copy(TrackString, 1, Index), Value, Code);

  if Code = 0 then
    Result := Value
  else
    Result := 0;
end;

procedure SetTagItem(const Data: AnsiString; var Tag: VorbisTag);
var
  Separator, Index: Integer;
  FieldID: AnsiString;
  FieldData: AnsiString;
  IsExtraField: boolean;
begin
  { Set Vorbis tag item }
  {$IFNDEF UNICODE}
  Separator := Pos('=', Data);
  {$Else}
  Separator := AnsiStrings.PosEx('=', Data, 1);
  {$ENDIF}

  if Separator > 0 then
  begin
    FieldID := UpperCase(Copy(Data, 1, Separator - 1));
    FieldData := Copy(Data, Separator + 1, Length(Data) - Length(FieldID));
    IsExtraField := true;  // Assume it's a non-supported tag field.
    for Index := 1 to VORBIS_FIELD_COUNT do
      if VORBIS_FIELD[Index] = FieldID then
      begin
       {$IFNDEF UNICODE}
        Tag.FieldData[Index] := UTF8Decode(Trim(FieldData));
       {$ELSE}
        Tag.FieldData[Index] := UTF8ToWideString(Trim(FieldData));
       {$ENDIF}
        IsExtraField := false;   // It's a supported tag field.
        break;
      end;

    if IsExtraField then
     { Non-supported tag fields are merged into ExtraField. }
      if Tag.ExtraField = '' then
        {$IFNDEF UNICODE}
         Tag.ExtraField := FieldId + '=' + UTF8Decode(Trim(FieldData))
        {$ELSE}
       //  Tag.ExtraField := FieldId + '=' + UTF8ToWideString(Trim(FieldData))   // **
       // ** Shows errorneous result if compiled with Delphi 2009.
         Tag.ExtraField := UTF8ToWideString(Trim(Data))
        {$ENDIF}
      else  // use chr(0) as seperator between tags
        {$IFNDEF UNICODE}
         Tag.ExtraField := Tag.ExtraField + WideChar(0) + FieldId + '=' + UTF8Decode(Trim(FieldData));
        {$ELSE}
       //  Tag.ExtraField := Tag.ExtraField + Char(0) + FieldId + '=' + UTF8ToWideString(Trim(FieldData));  // **
       //  ** Shows errorneous result if compiled with Delphi 2009.
         Tag.ExtraField := Tag.ExtraField + Char(0) + UTF8ToWideString(Trim(Data));
        {$ENDIF}
  end
  else
    if Tag.FieldData[0] = '' then Tag.FieldData[0] := Data;
end;

{ ---------------------------------------------------------------------------
 The data format of VORBIS_COMMENT block
   1) [vendor_length] = Length of Vendor string (unsigned integer of 32 bits)
   2) [vendor_string] = Vendor string in UTF-8
   3) [num_tag_field] = Number of tag fields (unsigned integer of 32 bits)
   4) iterate [num_tag_field] times {
              5) [field_length] = Length of a tag field (unsigned integer of 32 bits)
              6) [field_string] = A tag Field string in UTF-8. (Field_ID=......)
}
{$IFNDEF UNICODE}
procedure ReadTag(const Source: TTntFileStream; var Tag: VorbisTag);
{$ELSE}
procedure ReadTag(const Source: TFileStream; var Tag: VorbisTag);
{$ENDIF}
var
  Index, Size: Integer;
  DataStr: AnsiString;
begin
  { Read Vorbis tag }
  Index := 0;
 // The Source is positioned at the data location of VORBIS_COMMENT block.
  repeat
   { Get the length of Vendor string(Index = 0) or the length of a tag field (Index > 0) }
    Source.Read(Size, SizeOf(Size));
    SetLength(DataStr, Size);
   { Get Vendor string(Index = 0) or a tag Field string(Index > 0) }
    Source.Read(DataStr[1], Size);

   { Set Vorbis tag item }
    SetTagItem(Trim(DataStr), Tag);
    if Index = 0 then
      { Get the number of tag fields }
       Source.Read(Tag.Fields, SizeOf(Tag.Fields));
    Inc(Index);
  until Index > Tag.Fields;

end;

{ ---------------------------------------------------------------------------
 The data format of PICTURE block
   1) The picture type according to the ID3v2 APIC frame (unsigned integer of 32 bits)
   2) The length of the MIME type string in bytes.
   3) The MIME type string, in printable ASCII characters 0x20-0x7e.
      The MIME type may also be --> to signify that the data part is a URL of the picture
       instead of the picture data itself.
   4) The length of the description string in bytes.
   5) The description of the picture, in UTF-8.
   6) The width of the picture in pixels.
   7) The height of the picture in pixels.
   8) The color depth of the picture in bits-per-pixel.
   9) For indexed-color pictures (e.g. GIF), the number of colors used, or 0 for non-indexed pictures.
  10) The length of the picture data in bytes.
  11) The binary picture data.
  * All numeric items are unsigned integers of 32 bits, big-endian coded.
}
procedure ReadPicture(out PictureTag: TPictureTag; Source: TStream);
var
  fSizeData: array[0..3] of byte;
  DescrStr: AnsiString;
  Val: DWORD;

 function GetValue(RawData: array of byte) : DWORD;
 begin
   result := (RawData[0] shl 24) + (RawData[1] shl 16) + (RawData[2] shl 8) + RawData[3];
 end;

begin
 { Read data of a PICTURE block }
  Source.Read(fSizeData[0], 4);
  PictureTag.PicType := GetValue(fSizeData); // Get the picture type according to ID3v2 APIC frame:

  Source.Read(fSizeData[0], 4);
  Val := GetValue(fSizeData);                // Get the length of MIME type string in bytes.
  SetLength(PictureTag.MIME, Val);

  Source.Read(PictureTag.MIME[1], Val);      // Get the MIME type string

  Source.Read(fSizeData[0], 4);
  Val := GetValue(fSizeData);                // Get the length of description string in bytes.
  if Val > 0 then
  begin
    SetLength(DescrStr, Val);
    Source.Read(DescrStr[1], Val);           // Get the description of picture, in UTF-8.
   {$IFNDEF UNICODE}
    PictureTag.Description := UTF8Decode(Trim(DescrStr));
   {$ELSE}
    PictureTag.Description := UTF8ToWideString(Trim(DescrStr));
   {$ENDIF}
  end else
    PictureTag.Description := '';

  Source.Read(fSizeData[0], 4);
  PictureTag.PicWidth := GetValue(fSizeData);  // Get the width of picture in pixels.

  Source.Read(fSizeData[0], 4);
  PictureTag.PicHeight := GetValue(fSizeData); // Get the height of picture in pixels.

  Source.Read(fSizeData[0], 4);
  PictureTag.BitsPerPixel := GetValue(fSizeData); // Get the color depth of picture in bits-per-pixel.

  Source.Read(fSizeData[0], 4);
  PictureTag.Colors := GetValue(fSizeData);    // Get the number of colors used for indexed-color pictures (e.g. GIF),
                                               //  or 0 for non-indexed pictures.
  Source.Read(fSizeData[0], 4);
  PictureTag.Datalen := GetValue(fSizeData);   // Get the length of picture data in bytes.

  PictureTag.DataPos := Source.Position;       // Get the position of binary picture data in file.
end;

function GetInfo(const FileName: UnicodeString; var Info: FileInfo): Boolean;
var
  {$IFNDEF UNICODE}
  SourceFile: TTntFileStream;
  {$ELSE}
  SourceFile: TFileStream;
  {$ENDIF}
  BlockHeader: TBlockHeader;
  BlockType: byte;
  Block_StreamInfo: TBlock_StreamInfo;
  GetLastFlag: boolean;
  BlockDataSize: integer;
  CurBlockPos: int64;
  NextBlockPos: int64;
begin
  { Get info from file }
  Result := false;
  SourceFile := nil;

  try
    {$IFNDEF UNICODE}
    SourceFile := TTntFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    {$ELSE}
    SourceFile := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    {$ENDIF}
    Info.FileSize := SourceFile.Size;
    SourceFile.Read(Info.FileID, 4);
    if Info.FileID <> FLAC_ID then
       exit;

    GetLastFlag := false;
    repeat
      CurBlockPos := SourceFile.Position;
      SourceFile.Read(BlockHeader, SizeOf(BlockHeader));
      if BlockHeader.BlockType > 127 then    // MSB = 1 ?
      begin
        GetLastFlag := true;
        BlockType := BlockHeader.BlockType and $7F;  // strip off MSB
      end else
        BlockType := BlockHeader.BlockType;

      BlockDataSize := BlockHeader.BlockSize[1] shl 16 +
                       BlockHeader.BlockSize[2] shl 8 +
                       BlockHeader.BlockSize[3];
      NextBlockPos := SourceFile.Position + BlockDataSize;
      if BlockType = btStreamInfo then
      begin
        SourceFile.Read(Block_StreamInfo, SizeOf(Block_StreamInfo));
        Info.SampleRate := Block_StreamInfo.SampleRate[1] * 4096 +
                           Block_StreamInfo.SampleRate[2] * 16 +
                           Block_StreamInfo.SampleRate[3] shr 4;
        Info.Channels := (Block_StreamInfo.SampleRate[3] and $0f) div 2 + 1;
        Info.BitsPerSample := (Block_StreamInfo.SampleRate[3] and $01) * 16 +
                             (Block_StreamInfo.TotalSamples[1] div 16) + 1;
        Info.Samples := (Block_StreamInfo.TotalSamples[1] and $0f) shl 32
                      + (Block_StreamInfo.TotalSamples[2] shl 24)
                      + (Block_StreamInfo.TotalSamples[3] shl 16)
                      + (Block_StreamInfo.TotalSamples[4] shl 8)
                      + Block_StreamInfo.TotalSamples[5];
        if Info.Samples > 0 then
           if Info.SampleRate > 0 then
              Info.Duration := Info.Samples / Info.SampleRate;

        Info.MD5Signature := Block_StreamInfo.MD5Signature;
      end;
      if BlockType = btVorbis_Comment then
      begin
        // Info.TagHeader := BlockHeader;
        ReadTag(SourceFile, Info.Tag);
      end;
      if BlockType = btPicture then
      begin
        inc(Info.NumPictures);
        SetLength(Info.PictureTags, Info.NumPictures);
        ReadPicture(Info.PictureTags[Info.NumPictures - 1], SourceFile);
        Info.PictureTags[Info.NumPictures - 1].BlockNumber := Info.NumBlocks;
      end;

      inc(Info.NumBlocks);
      SetLength(Info.BlockTable, Info.NumBlocks);
      Info.BlockTable[Info.NumBlocks - 1].BlockType := BlockType;
      Info.BlockTable[Info.NumBlocks - 1].BlockPos := CurBlockPos;
      Info.BlockTable[Info.NumBlocks - 1].BlockSize := NextBlockPos - CurBlockPos;

      if not GetLastFlag then
        SourceFile.Seek(NextBlockPos, soFromBeginning);
    until GetLastFlag;

    Result := true;
  finally
    SourceFile.Free;
  end;
end;

function TFLACfile.FIsValid: Boolean;
begin
  { Check for file correctness }
  Result := (FChannels > 0) and (FSampleRate > 0) and (FDuration > 0.1) and (FBitsPerSample >= 4);
end;

function TFLACfile.FGetBitRate: Word;
var
  AudioFramePos: int64;
begin
  { Calculate average bit rate in KBPS }
  Result := 0;
  if (FDuration > 0) and (FNumBlocks > 0) then
  begin
    AudioFramePos := FBlockTable[FNumBlocks - 1].BlockPos + FBlockTable[FNumBlocks - 1].BlockSize;
    Result := Round((FFileSize - AudioFramePos) / FDuration / 125);
  end;
end;

function TFLACfile.FGetCompressRatio: Double;
// var
//   AudioFramePos: int64;
begin
  { Calculate compression ratio in % }
  Result := 0;
  if (FDuration > 0) and (FNumBlocks > 0) then
  begin
   // AudioFramePos := FBlockTable[FNumBlocks - 1].BlockPos + FBlockTable[FNumBlocks - 1].BlockSize;
    Result := (FFileSize {- AudioFramePos}) / (FSamples * FChannels * FBitsPerSample / 8) * 100;
  end;
end;

function TFLACfile.ReadFromFile(const FileName: UnicodeString): Boolean;
var
  Info: FileInfo;
  i: integer;
begin
  { Read data from file }
  Result := false;
  FResetData;

  FillChar(Info, SizeOf(Info), 0);
  if GetInfo(FileName, Info) then
  begin
   { Fill variables }
    FFileName := FileName;
    FFileSize := Info.FileSize;
    FChannels := Info.Channels;
    FSampleRate := Info.SampleRate;
    FBitsPerSample := Info.BitsPerSample;
    FSamples := Info.Samples;
    FDuration := Info.Duration;
    FNumBlocks := Info.NumBlocks;
    SetLength(FBlockTable, FNumBlocks);
    for i := 1 to FNumBlocks do
      FBlockTable[i-1] := Info.BlockTable[i-1];
    SetLength(Info.BlockTable, 0); // free memory taken by Info.BlockTable

    FNumPictures := Info.NumPictures;
    if FNumPictures > 0 then
    begin
      SetLength(FPictureTags, FNumPictures);
      for i := 1 to FNumPictures do
        FPictureTags[i-1] := Info.PictureTags[i-1];

      SetLength(Info.PictureTags, 0);   // free memory taken by Info.PictureTags
    end;

    FTitle := Info.Tag.FieldData[1];
    FArtist := Info.Tag.FieldData[2];
    FAlbum := Info.Tag.FieldData[3];
  //  FTrack := GetTrack(Info.Tag.FieldData[4]);
    FTrack := Info.Tag.FieldData[4];
    FDate := Info.Tag.FieldData[5];
    FGenre := Info.Tag.FieldData[6];
    FComment := Info.Tag.FieldData[7];
    FVendor := Info.Tag.FieldData[0];
    FExtraTag := Info.Tag.ExtraField;

    FMD5Signature := Info.MD5Signature;
    Result := true;
  end;
end;

{ --------------------------------------------------------------------------- }

{$IFNDEF UNICODE}
function BuildTag(const TagData: VorbisTag): TStringStream;
{$ELSE}
function BuildTag(const TagData: VorbisTag): TAnsiStringStream;
{$ENDIF}
var
  Index, Fields, Size: Integer;
  tmpStr, TAGStr: UnicodeString;
  S1: AnsiString;
  S2: UnicodeString;
 {$IFNDEF UNICODE}
  FieldData: AnsiString;
 {$ELSE}
  FieldData: RawByteString;
 {$ENDIF}
  SeperatorPos, EqualPos: integer;
begin
  { Build Vorbis tag }

  {$IFNDEF UNICODE}
  Result := TStringStream.Create('');
  {$ELSE}
 // TStringStream of Delphi 2009 shows erroneous result at handling ansistring.
 // So, use TAnsiStringStream instead of TStringStream for ansistring.
  Result := TAnsiStringStream.Create('');
  {$ENDIF}

  Fields := 0;
  for Index := 1 to VORBIS_FIELD_COUNT do
    if TagData.FieldData[Index] <> '' then Inc(Fields);

  if TagData.ExtraField <> '' then
  begin
    tmpStr := TagData.ExtraField;

    repeat
      SeperatorPos := pos(WideChar(0), tmpStr);
      if SeperatorPos > 0 then
      begin
        TAGStr := copy(tmpStr, 1, SeperatorPos - 1);
        tmpStr := copy(tmpStr, SeperatorPos + 1, length(tmpStr) - SeperatorPos);
      end else
        TAGStr := tmpStr;

      EqualPos := pos('=', TAGStr);
      if EqualPos > 0 then
        Inc(Fields);
    until (SeperatorPos = 0);
  end;

 { Write vendor info and number of fields }
  FieldData := UTF8Encode(TagData.FieldData[0]);
  Size := Length(FieldData);
  Result.Write(Size, SizeOf(Size));
  if Size > 0 then
    Result.WriteString(FieldData);
  Result.Write(Fields, SizeOf(Fields));
  if Fields = 0 then
    exit;

 { Write tag fields }
  for Index := 1 to VORBIS_FIELD_COUNT do
    if TagData.FieldData[Index] <> '' then
    begin
      FieldData := VORBIS_FIELD[Index] +
                   '=' + UTF8Encode(TagData.FieldData[Index]);
      Size := Length(FieldData);
      Result.Write(Size, SizeOf(Size));
      Result.WriteString(FieldData);
    end;

  if TagData.ExtraField <> '' then
  begin
    tmpStr := TagData.ExtraField;
    repeat
      SeperatorPos := pos(WideChar(0), tmpStr);
      if SeperatorPos > 0 then
      begin
        TAGStr := copy(tmpStr, 1, SeperatorPos - 1);
        tmpStr := copy(tmpStr, SeperatorPos + 1, length(tmpStr) - SeperatorPos);
      end else
        TAGStr := tmpStr;

      EqualPos := pos('=', TAGStr);
      if EqualPos > 0 then
      begin
        S1 := copy(TAGStr, 1, EqualPos);  // Typecast to AnsiString
        S2 := copy(TAGStr, EqualPos + 1, length(TAGStr) - EqualPos);
        FieldData := S1 + UTF8Encode(S2);
        Size := Length(FieldData);
        Result.Write(Size, SizeOf(Size));
        Result.WriteString(FieldData);
      end;

    until (SeperatorPos = 0);
  end;
end;

function MoveMetadataBlock(const Stream: TStream; FromLoc, ToLoc, MoveSize: int64): boolean;
var
  tmpStream: TMemoryStream;
begin
  { Relocate Matadata blocks in file. }
  result := false;

  try
    tmpStream := TMemoryStream.Create;
    Stream.Seek(FromLoc, soFromBeginning);
    tmpStream.CopyFrom(Stream, MoveSize);
    tmpStream.Seek(0, soFromBeginning);
    Stream.Seek(ToLoc, soFromBeginning);
    Stream.CopyFrom(tmpStream, tmpStream.Size);
    tmpStream.Free;

    result := true;
  except

  end;
end;

function WriteBlockHeader(const Stream: TStream; BlockRec: TBlockRec; LastBlock: boolean): boolean;
var
  tmpHeader: TBlockHeader;
  BlockdataSize : DWORD;
begin
  result := false;

  BlockDataSize := BlockRec.BlockSize - HeaderSize;
  try
    if LastBlock then
      tmpHeader.BlockType := 128 + BlockRec.BlockType  // 128 : Last block flag
    else
      tmpHeader.BlockType := BlockRec.BlockType;
    tmpHeader.BlockSize[1] := Lo(HiWord(BlockDataSize));
    tmpHeader.BlockSize[2] := Hi(LoWord(BlockDataSize));
    tmpHeader.BlockSize[3] := Lo(LoWord(BlockDataSize));
    Stream.Seek(BlockRec.BlockPos, soFromBeginning);
    Stream.Write(tmpHeader, SizeOf(tmpHeader));

    result := true;
  except

  end;

end;

function PadSpace(const Stream: TStream; FromLoc: int64; PadSize: DWORD): boolean;
var
  Buffer: array of byte;
begin
  { Fill zeros for the expanded space of pad block }
  result := false;

  try
    SetLength(Buffer, PadSize);
    FillChar(Buffer[0], PadSize, 0);
    Stream.Seek(FromLoc, soFromBeginning);
    Stream.Write(Buffer[0], PadSize);
    SetLength(Buffer, 0);

    result := true;
  except

  end;
end;

function AddBlock(const FileName: UnicodeString; var BlockTable: TBlockTable;
                     var NumBlocks: DWORD; BlockType: byte; BlockSize: DWORD): boolean;
var
  {$IFNDEF UNICODE}
  Source: TTntFileStream;
  {$ELSE}
  Source: TFileStream;
  {$ENDIF}
  tmpBlockRec: TBlockRec;
begin
  { Try to make a new Metadata block using top portion of padding block.
     Result -> true : success,  false : failure }
  result := false;

 // If the last block is not padding block then exit.
  if (BlockTable[NumBlocks-1].BlockType <> btPadding) then
    exit
 // If the size of padding block is not enough to make a new block then exit.
  else if (BlockSize > BlockTable[NumBlocks-1].BlockSize - 6) then
    exit;

  try
   { Create file streams }
    {$IFNDEF UNICODE}
    Source := TTntFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
    {$ELSE}
    Source := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
    {$ENDIF}

    tmpBlockRec.BlockType := BlockType;
    tmpBlockRec.BlockPos := BlockTable[NumBlocks-1].BlockPos;
    tmpBlockRec.BlockSize := BlockSize;
   { Write block header information for the added block. }
    if not WriteBlockHeader(Source, tmpBlockRec, false{=LastBlock}) then
      raise Exception.Create('');

   { The new block is made from padding block. }
    inc(NumBlocks);
    SetLength(BlockTable, NumBlocks);
    BlockTable[NumBlocks-1].BlockType := btPadding;
    BlockTable[NumBlocks-1].BlockPos := BlockTable[NumBlocks-2].BlockPos + BlockSize;
    BlockTable[NumBlocks-1].BlockSize := BlockTable[NumBlocks-2].BlockSize - BlockSize;
   { Write block header information for the last block (= Padding Block) }
    WriteBlockHeader(Source, BlockTable[NumBlocks-1], true{=LastBlock});

    BlockTable[NumBlocks-2] := tmpBlockRec;
    Source.Free;
    result := true;
  except
    { Access error }

  end;
end;

function DeleteBlock(const FileName: UnicodeString; var BlockTable: TBlockTable;
                       var NumBlocks: DWORD; BlockNo: DWORD): boolean;
var
  {$IFNDEF UNICODE}
  Source: TTntFileStream;
  {$ELSE}
  Source: TFileStream;
  {$ENDIF}
  DelBlockSize: DWORD;
  AudioFramePos: int64;
  i: integer;

begin
  { Try to delete a Metadata block then the space of deleted Metadata block is rendered
     to padding block.
      Result -> true : success,  false : failure }
  result := false;

  if BlockNo > (NumBlocks - 1) then
    exit;

  {$IFNDEF UNICODE}
  if (not WideFileExists(FileName)) or (WideFileSetAttr(FileName, 0) <> True) then exit;
  {$ELSE}
  if (not FileExists(FileName)) or (FileSetAttr(FileName, 0) <> 0) then exit;
  {$ENDIF}

  try
   { Create file streams }
    {$IFNDEF UNICODE}
    Source := TTntFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
    {$ELSE}
    Source := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
    {$ENDIF}

    AudioFramePos := BlockTable[NumBlocks-1].BlockPos + BlockTable[NumBlocks-1].BlockSize;
   { Move blocks forward behind the block to be deleted. }
    if not MoveMetadataBlock(Source, BlockTable[BlockNo + 1].BlockPos {From},
                                   BlockTable[BlockNo].BlockPos {To},
                                   AudioFramePos - BlockTable[BlockNo + 1].BlockPos {MoveSize}) then
      raise Exception.Create('');

    DelBlockSize := BlockTable[BlockNo].BlockSize;
    if BlockTable[NumBlocks-1].BlockType = btPadding then
    begin
    // for last block type is btPadding -> enlarge the padding block by the space of deleted block
      inc(BlockTable[NumBlocks-1].BlockSize, DelBlockSize);
      dec(BlockTable[NumBlocks-1].BlockPos, DelBlockSize);
      WriteBlockHeader(Source, BlockTable[NumBlocks-1], true{=LastBlock});
     { Pad expanded space }
      PadSpace(Source, BlockTable[NumBlocks-1].BlockPos + HeaderSize, DelBlockSize);

     { Move block information }
      for i := BlockNo to (NumBlocks - 2) do
      begin
        if i = (NumBlocks - 2) then
          BlockTable[i].BlockPos := BlockTable[i+1].BlockPos  // already substracted
        else
           BlockTable[i].BlockPos := BlockTable[i+1].BlockPos - DelBlockSize;
        BlockTable[i].BlockType := BlockTable[i+1].BlockType;
        BlockTable[i].BlockSize := BlockTable[i+1].BlockSize;
      end;
      dec(NumBlocks);
      SetLength(BlockTable, NumBlocks);
    end else
    begin
    // for last block type is not btPadding -> make a padding block from the space of deleted block
      // Move block information
      for i := BlockNo to (NumBlocks - 2) do
      begin
        BlockTable[i].BlockPos :=  BlockTable[i+1].BlockPos - DelBlockSize;
        BlockTable[i].BlockType := BlockTable[i+1].BlockType;
        BlockTable[i].BlockSize := BlockTable[i+1].BlockSize;
      end;

      BlockTable[NumBlocks-1].BlockType := 1;  //  = btPadding
      BlockTable[NumBlocks-1].BlockSize := DelBlockSize;
      BlockTable[NumBlocks-1].BlockPos := BlockTable[NumBlocks-2].BlockPos +
                                                 BlockTable[NumBlocks-2].BlockSize;
     { Write block header information for the last block (= Padding Block) }
      WriteBlockHeader(Source, BlockTable[NumBlocks-1], true{=LastBlock});

     { Remove last block flag of the previous last block }
      Source.Seek(BlockTable[NumBlocks-2].BlockPos, soFromBeginning);
      Source.Write(BlockTable[NumBlocks-2].BlockType, 1);

     { Pad new padding space }
      PadSpace(Source, BlockTable[NumBlocks-1].BlockPos + HeaderSize, DelBlockSize - HeaderSize);
    end;

    Source.Free;
    result := true;
  except
    { Access error }

  end;
end;

function ResizeBlock(const FileName: UnicodeString; var BlockTable: TBlockTable;
                     var NumBlocks: DWORD; BlockNo, NewBlockSize: DWORD): boolean;
var
  {$IFNDEF UNICODE}
  Source: TTntFileStream;
  {$ELSE}
  Source: TFileStream;
  {$ENDIF}
  DiffBlockSize: DWORD;
  i : integer;
  OrgBlockSize: DWORD;
  AudioFramePos: Int64;
begin
  { Try to resize a Metadata block,
     1) at resizing larger : expanded space is taken from padding block.
     2) at resizing smaller : returned space is rendered to padding block.
        Result -> true : success,  false : failure }
  result := false;

  if BlockNo > (NumBlocks - 1) then
    exit;

 { Determine if the specified blocks can be resized. }
  if (NewBlockSize > BlockTable[BlockNo].BlockSize) and
     (BlockTable[NumBlocks-1].BlockType <> btPadding) then
    exit
  else if (NewBlockSize > BlockTable[BlockNo].BlockSize + BlockTable[NumBlocks-1].BlockSize - 6) then
    exit
  else if ((BlockTable[BlockNo].BlockSize - NewBlockSize) < 6)
         and (BlockTable[NumBlocks-1].BlockType <> btPadding) then
    exit;    // for the case of very small size difference between new and original block
              // (not enough to make padding block).

  {$IFNDEF UNICODE}
  if (not WideFileExists(FileName)) or (WideFileSetAttr(FileName, 0) <> True) then exit;
  {$ELSE}
  if (not FileExists(FileName)) or (FileSetAttr(FileName, 0) <> 0) then exit;
  {$ENDIF}

  try
   { Create file streams }
    {$IFNDEF UNICODE}
    Source := TTntFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
    {$ELSE}
    Source := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
    {$ENDIF}

    if (NewBlockSize > BlockTable[BlockNo].BlockSize) then
    begin
      DiffBlockSize := NewBlockSize - BlockTable[BlockNo].BlockSize;
     { Move blocks backward behind the block to be resized by the difference between new & old size. }
      if not MoveMetadataBlock(Source,
                             BlockTable[BlockNo + 1].BlockPos {From},
                             BlockTable[BlockNo + 1].BlockPos + DiffBlockSize {To},
                             BlockTable[NumBlocks - 1].BlockPos - BlockTable[BlockNo + 1].BlockPos {MoveSize}) then
         raise Exception.Create('');

     { Adjust block information }
      for i := (BlockNo + 1) to (NumBlocks-1) do
        inc(BlockTable[i].BlockPos, DiffBlockSize);
      dec(BlockTable[NumBlocks-1].BlockSize, DiffBlockSize);
      BlockTable[BlockNo].BlockSize := NewBlockSize;

     { Change the resized block header information. }
      WriteBlockHeader(Source, BlockTable[BlockNo], false{=not LastBlock});

     { Write block header information for the last block (= Padding Block) }
      WriteBlockHeader(Source, BlockTable[NumBlocks-1], true{=LastBlock});
    end else
    if (NewBlockSize < BlockTable[BlockNo].BlockSize) then
    begin
      DiffBlockSize := BlockTable[BlockNo].BlockSize - NewBlockSize;
      AudioFramePos := BlockTable[NumBlocks-1].BlockPos + BlockTable[NumBlocks-1].BlockSize;
     { Move blocks forward behind the block to be resized by the difference between new & old size. }
      if not MoveMetadataBlock(Source, BlockTable[BlockNo + 1].BlockPos {From},
                                     BlockTable[BlockNo + 1].BlockPos - DiffBlockSize {To},
                                     AudioFramePos - BlockTable[BlockNo + 1].BlockPos {MoveSize}) then
        raise Exception.Create('');

      BlockTable[BlockNo].BlockSize := NewBlockSize;
     { Change the resized block header information. }
      WriteBlockHeader(Source, BlockTable[BlockNo], false{=not LastBlock});

      for i := (BlockNo + 1) to (NumBlocks-1) do
        dec(BlockTable[i].BlockPos, DiffBlockSize);

      if BlockTable[NumBlocks-1].BlockType = btPadding then
      begin
        OrgBlockSize := BlockTable[NumBlocks-1].BlockSize;
        inc(BlockTable[NumBlocks-1].BlockSize, DiffBlockSize);
       { Write block header information for the last block (= Padding Block) }
        WriteBlockHeader(Source, BlockTable[NumBlocks-1], true{=LastBlock});
       { Pad not-zeroed block data area. }
        if DiffBlockSize > (OrgBlockSize - HeaderSize) then
          PadSpace(Source, BlockTable[NumBlocks-1].BlockPos + OrgBlockSize, DiffBlockSize - OrgBlockSize + HeaderSize);
      end else
      begin
        if DiffBlockSize >= 6 then    // -> 6 : Minimum value to make a Padding block
        begin
          inc(NumBlocks);
          SetLength(BlockTable, NumBlocks);
          BlockTable[NumBlocks-1].BlockPos := BlockTable[NumBlocks-2].BlockPos
                                                    + BlockTable[NumBlocks-2].BlockSize;
          BlockTable[NumBlocks-1].BlockSize := DiffBlockSize;
          BlockTable[NumBlocks-1].BlockType := 1;  // = btPadding
         { Write block header information for the last block (= Padding Block) }
          WriteBlockHeader(Source, BlockTable[NumBlocks-1], true{=LastBlock});
         { Pad block data area }
          PadSpace(Source, BlockTable[NumBlocks-1].BlockPos + HeaderSize, DiffBlockSize - HeaderSize);
        end else
        begin  // This case cannot happen.
         { Cannot make padding block -> Just resize the last block }
          inc(BlockTable[NumBlocks-1].BlockSize, DiffBlockSize);
         { Write block header information for the last block (= Padding Block) }
          WriteBlockHeader(Source, BlockTable[NumBlocks-1], true{=LastBlock});
        end;
      end;
    end;

    Source.Free;
    result := true;
  except
    { Access error }

  end;

end;

// The whole file is rewritten if resized VORBIS_COMMENT block cannot be fitted within the Metadata
//  block area in file.
// ex) The file has no padding block or the size of padding block is smaller than the enlarged tag size.
// In case of no VORBIS_COMMENT block in file -> TagBlockPos = 1st Block End + 1, TagBlockEnd = 1st Block End
// ( => The VORBIS_COMMENT block is placed just behind the first block. )
function RebuildFile(FileName: UnicodeString; Tag: TStream; TagBlockPos, TagBlockEnd: int64; LastBlock: boolean): Boolean;
var
  {$IFNDEF UNICODE}
  Source, Destination: TTntFileStream;
  {$ELSE}
  Source, Destination: TFileStream;
  {$ENDIF}
  BufferName: UnicodeString;
  tmpHeader: TBlockHeader;
begin
  { Rebuild the file with the new Vorbis tag }
  Result := false;
  {$IFNDEF UNICODE}
  if (not WideFileExists(FileName)) or (WideFileSetAttr(FileName, 0) <> True) then exit;
  {$ELSE}
  if (not FileExists(FileName)) or (FileSetAttr(FileName, 0) <> 0) then exit;
  {$ENDIF}
  try
   { Create file streams }
    BufferName := FileName + '~';
    {$IFNDEF UNICODE}
    Source := TTntFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    Destination := TTntFileStream.Create(BufferName, fmCreate);
    {$ELSE}
    Source := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    Destination := TFileStream.Create(BufferName, fmCreate);
    {$ENDIF}
   { Copy data blocks }
    Destination.CopyFrom(Source, TagBlockPos);  // copy from 0 ~ (TagBlockPos - 1)

    if LastBlock then  // Tag Block is the last block ?
       tmpHeader.BlockType := 128 + btVorbis_Comment
    else
       tmpHeader.BlockType := btVorbis_Comment;
    tmpHeader.BlockSize[1] := Lo(HiWord(Tag.Size));
    tmpHeader.BlockSize[2] := Hi(LoWord(Tag.Size));
    tmpHeader.BlockSize[3] := Lo(LoWord(Tag.Size));
    Destination.Write(tmpHeader, SizeOf(tmpHeader));

    Destination.CopyFrom(Tag, 0);   // copy tag data
    Source.Seek(TagBlockEnd + 1, soFromBeginning);
    Destination.CopyFrom(Source, Source.Size - TagBlockEnd - 1); // copy (TagBlockEnd + 1) ~ File end
    Source.Free;
    Destination.Free;

   { Replace old file and delete temporary file }
    {$IFNDEF UNICODE}
    if (WideDeleteFile(FileName)) and (WideRenameFile(BufferName, FileName)) then
    {$ELSE}
    if (DeleteFile(FileName)) and (RenameFile(BufferName, FileName)) then
    {$ENDIF}
      Result := true
    else
      raise Exception.Create('');
  except
    { Access error }
    {$IFNDEF UNICODE}
    if WideFileExists(BufferName) then WideDeleteFile(BufferName);
    {$ELSE}
    if FileExists(BufferName) then DeleteFile(BufferName);
    {$ENDIF}
  end;

end;

function RewriteTag(FileName: UnicodeString; Tag: TStream; TagStartPos: int64): boolean;
var
  {$IFNDEF UNICODE}
  Source: TTntFileStream;
  {$ELSE}
  Source: TFileStream;
  {$ENDIF}
begin
  result := false;

  {$IFNDEF UNICODE}
  if (not WideFileExists(FileName)) or (WideFileSetAttr(FileName, 0) <> True) then exit;
  {$ELSE}
  if (not FileExists(FileName)) or (FileSetAttr(FileName, 0) <> 0) then exit;
  {$ENDIF}

  try
   { Create file streams }
    {$IFNDEF UNICODE}
    Source := TTntFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
    {$ELSE}
    Source := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
    {$ENDIF}

    Source.Seek(TagStartPos + HeaderSize, soFromBeginning);
    Source.CopyFrom(Tag, 0);
    Source.Free;
    Result := true;
  except
    { Access error }

  end;

end;

function TFLACfile.SaveTag(const FileName: UnicodeString): Boolean;
var
  Info: FileInfo;
 {$IFNDEF UNICODE}
  Tag: TStringStream;
 {$ELSE}
  Tag: TAnsiStringStream;
 {$ENDIF}
  i: integer;
  SizeDiff: integer;
  LastBlock: boolean;
  FoundTagBlock: boolean;
  VorbisPos: Int64;           // The position of VORBIS_COMMENT block
  TagBlockNo: DWORD;
  TagBlockSize: DWORD;
begin
  { Save Vorbis tag for the speicified file }
  Result := false;

  FillChar(Info, SizeOf(Info), 0);
  if FileName = FFileName then
  begin
    for i := 0 to (FNumBlocks - 1) do
      Info.BlockTable[i] := FBlockTable[i];
    Info.NumBlocks := FNumBlocks;
  end else
    if not GetInfo(FileName, Info) then
      exit;

 { Prepare tag data and save to file }
  Info.Tag.FieldData[1] := Trim(FTitle);
  Info.Tag.FieldData[2] := Trim(FArtist);
  Info.Tag.FieldData[3] := Trim(FAlbum);
 { if FTrack > 0 then
     Info.Tag.FieldData[4] := IntToStr(FTrack)
  else
     Info.Tag.FieldData[4] := ''; }
  Info.Tag.FieldData[4] := Trim(FTrack);
  Info.Tag.FieldData[5] := Trim(FDate);
  Info.Tag.FieldData[6] := Trim(FGenre);
  Info.Tag.FieldData[7] := Trim(FComment);
  Info.Tag.ExtraField := FExtraTag;
  Tag := BuildTag(Info.Tag);

 { Check if VORBIS_COMMENT block is present in file }
  FoundTagBlock := false;
  for i := 0 to (Info.NumBlocks - 1) do
    if Info.BlockTable[i].BlockType = btVorbis_Comment then
    begin
      FoundTagBlock := true;
      TagBlockNo := i;
      TagBlockSize := Info.BlockTable[i].BlockSize;
      VorbisPos := Info.BlockTable[i].BlockPos;
      break;
    end;

  if (Tag.Size = 8) then  // Tag.Size = 8 : No tag data
  begin
    if FoundTagBlock then
    begin
     { Delete VORBIS_COMMENT block }
      Result := DeleteBlock(FileName, Info.BlockTable, Info.NumBlocks, TagBlockNo);
     { Adjust the picture tags located behind the VORBIS_COMMENT block. }
      if Result and (FileName = FFileName) then
        for i := 0 to (FNumPictures - 1) do
        if FPictureTags[i].BlockNumber > TagBlockNo then
        begin
          dec(FPictureTags[i].BlockNumber);
          dec(FPictureTags[i].DataPos, TagBlockSize);
       end;
    end else
      Result := true;   // Nothing to do

    Tag.Free;
    exit;
  end;

  if not FoundTagBlock then
  begin
   { Try to make VORBIS_COMMENT block using the space of padding block }
    if AddBlock(FileName, Info.BlockTable, Info.NumBlocks, btVorbis_Comment, Tag.Size + HeaderSize) then
    begin
      TagBlockNo := Info.NumBlocks - 2;  // The last Metadata block should be padding block.
      VorbisPos := Info.BlockTable[TagBlockNo].BlockPos;
    end else
    begin
      LastBlock := (Info.NumBlocks = 1);
      Result := RebuildFile(FileName, Tag,
                            Info.BlockTable[0].BlockPos + Info.BlockTable[0].BlockSize,
                            Info.BlockTable[0].BlockPos + Info.BlockTable[0].BlockSize - 1,
                            LastBlock);
      Tag.Free;
      if Result and (FileName = FFileName) then
         ReadFromFile(FileName);
      exit;
    end;
  end;

  if Tag.Size = (Info.BlockTable[TagBlockNo].BlockSize - HeaderSize) then  // Tag Size is not changed ?
     Result := RewriteTag(FileName, Tag, VorbisPos)
  else
  begin  // Tag size changed -> the VORBIS_COMMENT block should be resized.
   { Adjust the size of VORBIS_COMMENT block }
    if ResizeBlock(FileName, Info.BlockTable, Info.NumBlocks, TagBlockNo, DWORD(Tag.Size) + HeaderSize) then
    begin
      if FileName = FFileName then   // The file(whose tag is to be rewritten) is the latest inquired file by ReadFromFile function ?
      begin                          // then FPictureTags[x].DataPos should be adjusted for the subsequent call to get picture data.
        SizeDiff := Tag.Size - (Info.BlockTable[TagBlockNo].BlockSize - HeaderSize);

        for i := 0 to (FNumPictures - 1) do
          if FPictureTags[i].BlockNumber > TagBlockNo then
           { For the PICTURE blocks located behind the resized VORBIS_COMMENT block. }
            FPictureTags[i].DataPos := FPictureTags[i].DataPos + SizeDiff;
      end;

      Result := RewriteTag(FileName, Tag, VorbisPos);
    end else begin
      LastBlock := (TagBlockNo = (Info.NumBlocks - 1));
      Result := RebuildFile(FileName, Tag, VorbisPos, VorbisPos + Info.BlockTable[TagBlockNo].BlockSize - 1, LastBlock);
  // Use ReadFromFile to refresh FPictureTags[x].DataPos.
  //  FBlockTable[x].BlockPos
      if Result and (FileName = FFileName) then
        ReadFromFile(FileName);
    end;
  end;

  Tag.Free;
end;

function TFLACfile.SaveTag: Boolean;
var
  TagData: VorbisTag;
 {$IFNDEF UNICODE}
  Tag: TStringStream;
 {$ELSE}
  Tag: TAnsiStringStream;
 {$ENDIF}
  i: integer;
  TagBlockNo: DWORD;
  TagBlockSize: DWORD;
  FoundTagBlock: boolean;
  LastBlock: boolean;
  SizeDiff: integer;
begin
  { Save Vorbis tag for the file whose information is just loaded by ReadFromFile. }
  Result := false;

  if FFileName = '' then
    exit;

  FoundTagBlock := false;
  for i := 0 to (FNumBlocks - 1) do
    if FBlockTable[i].BlockType = btVorbis_Comment then
    begin
      FoundTagBlock := true;
      TagBlockNo := i;
      TagBlockSize := FBlockTable[i].BlockSize;
      break;
    end;

  FillChar(TagData, SizeOf(TagData), 0);
 { Prepare tag data and save to file }
  TagData.FieldData[1] := Trim(FTitle);
  TagData.FieldData[2] := Trim(FArtist);
  TagData.FieldData[3] := Trim(FAlbum);
 { if FTrack > 0 then
    TagData.FieldData[4] := IntToStr(FTrack)
  else
    TagData.FieldData[4] := ''; }
  TagData.FieldData[4] := Trim(FTrack);
  TagData.FieldData[5] := Trim(FDate);
  TagData.FieldData[6] := Trim(FGenre);
  TagData.FieldData[7] := Trim(FComment);
  TagData.ExtraField := FExtraTag;
  Tag := BuildTag(TagData);

  if (Tag.Size = 8) then  // Tag.Size = 8 : No tag data
  begin
    if FoundTagBlock then
    begin
     { Delete VORBIS_COMMENT block }
      Result := DeleteBlock(FFileName, FBlockTable, FNumBlocks, TagBlockNo);
     { Adjust the picture tags located behind the VORBIS_COMMENT block. }
      if Result then
        for i := 0 to (FNumPictures - 1) do
        if FPictureTags[i].BlockNumber > TagBlockNo then
        begin
          dec(FPictureTags[i].BlockNumber);
          dec(FPictureTags[i].DataPos, TagBlockSize);
        end;
    end else
      Result := true;   // Nothing to do

    Tag.Free;
    exit;
  end;

  if not FoundTagBlock then
  begin
    if AddBlock(FFileName, FBlockTable, FNumBlocks, btVorbis_Comment, Tag.Size + HeaderSize) then
      TagBlockNo := FNumBlocks - 2
    else begin
      if FNumBlocks = 1 then
        LastBlock := true
      else
        LastBlock := false;
      Result := RebuildFile(FFileName, Tag,
                            FBlockTable[0].BlockPos + FBlockTable[0].BlockSize,
                            FBlockTable[0].BlockPos + FBlockTable[0].BlockSize - 1,
                            LastBlock);
      Tag.Free;
      if Result then
        ReadFromFile(FFileName);
      exit;
    end;
  end;

  if Tag.Size = (FBlockTable[TagBlockNo].BlockSize - HeaderSize) then  // Tag Size is not changed ?
    Result := RewriteTag(FFileName, Tag, FBlockTable[TagBlockNo].BlockPos)
  else
  begin  // Tag size changed -> the VORBIS_COMMENT block should be resized.
     SizeDiff := Tag.Size - (FBlockTable[TagBlockNo].BlockSize - HeaderSize);
    { Adjust the size of VORBIS_COMMENT block }
     if ResizeBlock(FFileName, FBlockTable, FNumBlocks, TagBlockNo, DWORD(Tag.Size) + HeaderSize) then
     begin
       for i := 0 to (FNumPictures - 1) do
         if FPictureTags[i].BlockNumber > TagBlockNo then
          { For the PICTURE blocks located behind the resized VORBIS_COMMENT block. }
           FPictureTags[i].DataPos := FPictureTags[i].DataPos + SizeDiff;

       Result := RewriteTag(FFileName, Tag, FBlockTable[TagBlockNo].BlockPos);
     end else begin
       LastBlock := (TagBlockNo = (FNumBlocks - 1));
       Result := RebuildFile(FFileName, Tag, FBlockTable[TagBlockNo].BlockPos,
                             FBlockTable[TagBlockNo].BlockPos + FBlockTable[TagBlockNo].BlockSize - 1, LastBlock);
  // Use ReadFromFile to refresh FPictureTags[x].DataPos.
  //  FBlockTable[x].BlockPos
       if Result then
         ReadFromFile(FFileName);
     end;
  end;

  Tag.Free;

end;


function TFLACfile.GetPicture(PicNo: DWORD;
                              out PicType: DWORD;
                              out MIME: AnsiString;
                              out Description: UnicodeString;
                              out PictureInfo: TPictureInfo;
                              PictureData: TStream): boolean;
var
  {$IFNDEF UNICODE}
  Source: TTntFileStream;
  {$ELSE}
  Source: TFileStream;
  {$ENDIF}
begin
  { Get Picture data from the specified PICTURE block in file }
  result := false;

  if not FIsValid then
    exit;
  if FNumPictures = 0 then
    exit;
  if PicNo > (FNumPictures - 1) then
    exit;

  try
    {$IFNDEF UNICODE}
    Source := TTntFileStream.Create(FFileName, fmOpenRead or fmShareDenyWrite);
    {$ELSE}
    Source := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyWrite);
    {$ENDIF}
   { Copy picture data blocks }
    Source.Seek(FPictureTags[PicNo].DataPos, soFromBeginning);
    PictureData.Seek(0, soFromBeginning);
    PictureData.CopyFrom(Source, FPictureTags[PicNo].Datalen);
    Source.Free;

    PicType := FPictureTags[PicNo].PicType;
    MIME := FPictureTags[PicNo].MIME;
    Description := FPictureTags[PicNo].Description;
    PictureInfo.Width := FPictureTags[PicNo].PicWidth;
    PictureInfo.Height := FPictureTags[PicNo].PicHeight;
    PictureInfo.BitsPerPixel := FPictureTags[PicNo].BitsPerPixel;
    PictureInfo.Colors := FPictureTags[PicNo].Colors;
    result := true;
  except

  end;

end;

function TFLACfile.GetPictureNo(PicType: DWORD; MIME: AnsiString; Description: UnicodeString): integer;
var
  i: integer;

begin
  { Get the Picture number of specified PicType, MIME & Description }
  result := -1;

  if FNumPictures = 0 then
     exit;

  for i := 0 to (FNumPictures - 1) do
    if (PicType = FPictureTags[i].PicType) and (MIME = FPictureTags[i].MIME) then
      if (Description = '*') or (Description = FPictureTags[i].Description) then
      begin
        result := i;
        break;
      end;
end;

{$IFNDEF UNICODE}
function GetPictureTag(PicType: DWORD; MIME: AnsiString; Description: UnicodeString;
                       PictureInfo: TPictureInfo; DataSize: DWORD): TStringStream;
{$ELSE}
function GetPictureTag(PicType: DWORD; MIME: AnsiString; Description: UnicodeString;
                       PictureInfo: TPictureInfo; DataSize: DWORD): TAnsiStringStream;
{$ENDIF}
var
  StrLen: integer;
  DescrStr: AnsiString;
  fSizeData: array[0..3] of byte;

 procedure FillSizeData(Val: DWORD);
 begin
   fSizeData[0] := Hi(HiWord(Val));
   fSizeData[1] := Lo(HiWord(Val));
   fSizeData[2] := Hi(LoWord(Val));
   fSizeData[3] := Lo(LoWord(Val));
 end;

begin
  { Build Picture tag }

  {$IFNDEF UNICODE}
  Result := TStringStream.Create('');
 {$ELSE}
 // TStringStream of Delphi 2009 shows erroneous result at handling ansistring.
 // So, use TAnsiStringStream instead of TStringStream for ansistring.
  Result := TAnsiStringStream.Create('');
  {$ENDIF}

  FillSizeData(PicType);
  Result.Write(fSizeData[0], 4);        // Set picture type
  StrLen := Length(MIME);
  FillSizeData(DWORD(StrLen));
  Result.Write(fSizeData[0], 4);        // Set the length of the MIME type string
  Result.WriteString(MIME);             // Set MIME type string
  DescrStr := UTF8Encode(Description);
  StrLen := Length(DescrStr);
  FillSizeData(DWORD(StrLen));
  Result.Write(fSizeData[0], 4);        // Set the length of the description string
  Result.WriteString(DescrStr);         // Set the description of the picture, in UTF-8.
  FillSizeData(PictureInfo.Width);
  Result.Write(fSizeData[0], 4);        // Set width of the picture
  FillSizeData(PictureInfo.Height);
  Result.Write(fSizeData[0], 4);        // Set height of the picture
  FillSizeData(PictureInfo.BitsPerPixel);
  Result.Write(fSizeData[0], 4);        // Set color depth of the picture
  FillSizeData(PictureInfo.Colors);
  Result.Write(fSizeData[0], 4);        // Set the number of colors used
  FillSizeData(DataSize);
  Result.Write(fSizeData[0], 4);        // Set the length of the picture data
end;

function RebuildFile2(FileName: UnicodeString; PictureTag, PictureData: TStream;
                                 NumBlocks: DWORD; BlockTable: TBlockTable): Boolean;
var
  {$IFNDEF UNICODE}
  Source, Destination: TTntFileStream;
  {$ELSE}
  Source, Destination: TFileStream;
  {$ENDIF}
  BufferName: UnicodeString;
  tmpHeader: TBlockHeader;
  HasPaddingBlock: boolean;
  CopyBoundary: int64;
begin
  { Rebuild the file with the new Picture tag data }
  Result := false;

  if BlockTable[NumBlocks - 1].BlockType = btPadding then
    HasPaddingBlock := true
  else
    HasPaddingBlock := false;

  if HasPaddingBlock then
    CopyBoundary := BlockTable[NumBlocks - 1].BlockPos
  else
    CopyBoundary := BlockTable[NumBlocks - 1].BlockPos + BlockTable[NumBlocks - 1].BlockSize;

  {$IFNDEF UNICODE}
  if (not WideFileExists(FileName)) or (WideFileSetAttr(FileName, 0) <> True) then exit;
  {$ELSE}
  if (not FileExists(FileName)) or (FileSetAttr(FileName, 0) <> 0) then exit;
  {$ENDIF}
  try
   { Create file streams }
    BufferName := FileName + '~';
    {$IFNDEF UNICODE}
    Source := TTntFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    Destination := TTntFileStream.Create(BufferName, fmCreate);
    {$ELSE}
    Source := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    Destination := TFileStream.Create(BufferName, fmCreate);
    {$ENDIF}
   { Copy data blocks }
    Destination.CopyFrom(Source, CopyBoundary);

    if HasPaddingBlock then
       tmpHeader.BlockType := btPicture
    else
       tmpHeader.BlockType := 128 + btPicture;   // add last block flag

    tmpHeader.BlockSize[1] := Lo(HiWord(PictureTag.Size + PictureData.Size));
    tmpHeader.BlockSize[2] := Hi(LoWord(PictureTag.Size + PictureData.Size));
    tmpHeader.BlockSize[3] := Lo(LoWord(PictureTag.Size + PictureData.Size));
    Destination.Write(tmpHeader, SizeOf(tmpHeader));

    Destination.CopyFrom(PictureTag, 0);
    Destination.CopyFrom(PictureData, 0);
    Source.Seek(CopyBoundary, soFromBeginning);
    Destination.CopyFrom(Source, Source.Size - CopyBoundary);
    Source.Free;
    Destination.Free;

   { Replace old file and delete temporary file }
    {$IFNDEF UNICODE}
    if (WideDeleteFile(FileName)) and (WideRenameFile(BufferName, FileName)) then
    {$ELSE}
    if (DeleteFile(FileName)) and (RenameFile(BufferName, FileName)) then
    {$ENDIF}
      Result := true
    else
      raise Exception.Create('');
  except
    { Access error }
    {$IFNDEF UNICODE}
    if WideFileExists(BufferName) then WideDeleteFile(BufferName);
    {$ELSE}
    if FileExists(BufferName) then DeleteFile(BufferName);
    {$ENDIF}
  end;

end;

function TFLACfile.SavePicture(PicType: DWORD;
                               MIME: AnsiString;
                               Description: UnicodeString;
                               PictureInfo: TPictureInfo;
                               PictureData: TStream): boolean;
var
  {$IFNDEF UNICODE}
  Source: TTntFileStream;
  PictureTag: TStringStream;
  {$ELSE}
  Source: TFileStream;
  PictureTag: TAnsiStringStream;
  {$ENDIF}

  PictureNo: integer;
  BlockNo: DWORD;
  SizeRequired: DWORD;
  NeedRescan: boolean;

 // Adjust information of a FPictureTags item
 function SetPictureTag(TagNo, PicType_: DWORD; MIME_: AnsiString;
                        Descr: UnicodeString; PicInfo : TPictureInfo;
                        DataLen_: DWORD; DataPos_: int64; BlockNo_: DWORD): boolean;
 begin
   result := false;

   if TagNo >= FNumPictures then
     exit;

   with FPictureTags[TagNo] do
   begin
     PicType := PicType_;
     MIME := MIME_;
     Description := Descr;
     PicWidth := PicInfo.Width;
     PicHeight := PicInfo.Height;
     BitsPerPixel := PicInfo.BitsPerPixel;
     Colors := PicInfo.Colors;
     Datalen := DataLen_;
     DataPos := DataPos_;
     BlockNumber := BlockNo_;
   end;

   result := true;
 end;

begin
  { Save Picture data to file }
  result := false;

  if not FIsValid then
    exit;

  NeedRescan := false;
  PictureTag := GetPictureTag(PicType, MIME, Description, PictureInfo, PictureData.Size);
  PictureNo := GetPictureNo(PicType, MIME, Description);
  SizeRequired := HeaderSize + PictureTag.Size + PictureData.Size;
  if (PictureNo <> -1) and FInhibitDuplicate then
  begin   // Replace a picture
    BlockNo := FPictureTags[PictureNo].BlockNumber;
    if (FBlockTable[BlockNo].BlockSize <> SizeRequired) then  // Space required for picture tag is changed ?
    begin
      if ResizeBlock(FFileName, FBlockTable, FNumBlocks, BlockNo, SizeRequired) then
      begin
        try
         { Create file streams }
          {$IFNDEF UNICODE}
          Source := TTntFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyWrite);
          {$ELSE}
          Source := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyWrite);
          {$ENDIF}

          Source.Seek(FBlockTable[BlockNo].BlockPos + HeaderSize, soFromBeginning);
          Source.CopyFrom(PictureTag, 0);
          Source.CopyFrom(PictureData, 0);
          Source.Free;
          Result := true;
        except
       { Access error }

        end;
      end else
      begin
         if DeletePicture(PictureNo) then
           result := RebuildFile2(FFileName, PictureTag, PictureData, FNumBlocks, FBlockTable);
      end;

      if Result then
        NeedRescan := true;
    end else
    begin   // for (FBlockTable[BlockNo].BlockSize = SizeRequired)
     try
       {$IFNDEF UNICODE}
       Source := TTntFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyWrite);
       {$ELSE}
       Source := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyWrite);
       {$ENDIF}

       Source.Seek(FBlockTable[BlockNo].BlockPos + HeaderSize, soFromBeginning);
       Source.CopyFrom(PictureTag, 0);
       Source.CopyFrom(PictureData, 0);
       Source.Free;
       SetPictureTag(PictureNo, PicType, MIME, Description, PictureInfo, PictureData.Size,
                     FBlockTable[BlockNo].BlockPos + HeaderSize + PictureTag.Size, BlockNo);
       Result := true;
     except
    { Access error }

     end;
    end;
  end else
  begin  // Add a picture
    if AddBlock(FFileName, FBlockTable, FNumBlocks, btPicture, SizeRequired) then
    begin
      try
       { Create file streams }
        {$IFNDEF UNICODE}
        Source := TTntFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyWrite);
        {$ELSE}
        Source := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyWrite);
        {$ENDIF}

        Source.Seek(FBlockTable[FNumBlocks - 2].BlockPos + HeaderSize, soFromBeginning);
        Source.CopyFrom(PictureTag, 0);
        Source.CopyFrom(PictureData, 0);
        Source.Free;
        inc(FNumPictures);
        SetLength(FPictureTags, FNumPictures);
        SetPictureTag(FNumPictures-1, PicType, MIME, Description, PictureInfo, PictureData.Size,
                      FBlockTable[FNumBlocks-2].BlockPos + HeaderSize + PictureTag.Size, FNumBlocks-2);
        Result := true;
      except

      end;
    end else
    begin
      result := RebuildFile2(FFileName, PictureTag, PictureData, FNumBlocks, FBlockTable);
      if Result then
        NeedRescan := true;
    end;
  end;

  PictureTag.Free;
 // if Result then
  if NeedRescan then
    ReadFromFile(FFileName);
end;

function TFLACfile.DeletePicture(PicNo: DWORD): boolean;
var
  BlockNo: DWORD;
  BlockSize: DWORD;
  i, j: integer;
begin
  { Delete Picture data from file }
  result := false;

  if FNumPictures = 0 then
    exit;
  if PicNo > (FNumPictures - 1) then
    exit;

  BlockNo := FPictureTags[PicNo].BlockNumber;
  BlockSize := FBlockTable[BlockNo].BlockSize;

  if DeleteBlock(FFileName, FBlockTable, FNumBlocks, BlockNo) then
  begin
  // Adjust the FPictureTags information
  // The PICTURE blocks behind the deleted PICTURE block are moved forward by
  //  the size of deleted PICTURE block.
    j := 0;
    for i := 0 to (FNumPictures - 1) do
      if FPictureTags[i].BlockNumber > BlockNo then
      begin
       { For the infomation of the PICTURE blocks located behind the deleted PICTURE block. }
        dec(FPictureTags[i].BlockNumber);
        dec(FPictureTags[i].DataPos, BlockSize);
        FPictureTags[j] := FPictureTags[i];
        inc(j);
      end else
      if FPictureTags[i].BlockNumber = BlockNo then
        continue   // Skip for the deleted PICTURE block.
      else begin
       { For the infomation of the PICTURE blocks located before the deleted PICTURE block. }
        FPictureTags[j] := FPictureTags[j];
        inc(j);
      end;

    dec(FNumPictures);
    SetLength(FPictureTags, FNumPictures);
  end;

  result := true;
end;

function GetPictureTypeStr(PictureType: DWORD): AnsiString;
begin
  if PictureType >= PictureTypes then
    result := ''
  else
    result := PictureTypeStr[PictureType];
end;

end.
