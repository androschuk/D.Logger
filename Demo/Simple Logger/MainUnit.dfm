object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 406
  ClientWidth = 646
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object mmoResult: TMemo
    AlignWithMargins = True
    Left = 6
    Top = 6
    Width = 634
    Height = 359
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 0
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitWidth = 491
    ExplicitHeight = 83
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 365
    Width = 646
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'pnlButtons'
    ShowCaption = False
    TabOrder = 1
    ExplicitTop = 240
    ExplicitWidth = 503
    DesignSize = (
      646
      41)
    object btnExecute: TButton
      Left = 566
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Run Tasks'
      TabOrder = 0
      OnClick = btnExecuteClick
      ExplicitLeft = 423
    end
  end
end
