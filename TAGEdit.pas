unit TAGEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TTAGEditForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    TAGValue: TMemo;
    TAGName: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{var
  TAGEditForm: TTAGEditForm; }

implementation

{$R *.DFM}


procedure TTAGEditForm.btnOKClick(Sender: TObject);
var
   i : integer;
begin
   if TAGName.Text <> '' then
      for i := 1 to Length(TAGName.Text) do
         if (TAGName.Text[i] < chr($20)) or (TAGName.Text[i] > chr($7D)) or (TAGName.Text[i] = '=') then
         begin
            MessageBox(Self.Handle, 'Invalid character(s) in Tag name (Use english alphabet only).', 'Information',
                                            MB_OK + MB_ICONINFORMATION);
            exit;
         end;

   if (trim(TAGName.Text) = '') then
   begin
      MessageBox(Self.Handle, 'Tag name is not given.', 'Information', MB_OK + MB_ICONINFORMATION);
      exit;
   end;

   if (trim(TAGValue.Text) = '') then
   begin
      MessageBox(Self.Handle, 'Tag value is not given.', 'Information', MB_OK + MB_ICONINFORMATION);
      exit;
   end;

   ModalResult := mrOK;
end;

procedure TTAGEditForm.btnCancelClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

end.
