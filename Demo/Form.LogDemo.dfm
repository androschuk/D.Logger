object frmLogDemo: TfrmLogDemo
  Left = 0
  Top = 0
  Caption = 'frmLogDemo'
  ClientHeight = 248
  ClientWidth = 499
  Color = clBtnFace
  Constraints.MinHeight = 240
  Constraints.MinWidth = 288
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    499
    248)
  PixelsPerInch = 96
  TextHeight = 13
  object lblLogMessage: TLabel
    Left = 191
    Top = 8
    Width = 66
    Height = 13
    Caption = 'Log Message:'
  end
  object rgLogLevel: TRadioGroup
    Left = 8
    Top = 8
    Width = 177
    Height = 200
    Caption = 'Log Level'
    TabOrder = 0
  end
  object btnWrite: TButton
    Left = 416
    Top = 215
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Write'
    TabOrder = 1
    OnClick = btnWriteClick
  end
  object mmoLogMessage: TMemo
    Left = 191
    Top = 27
    Width = 300
    Height = 182
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Log message')
    TabOrder = 2
  end
  object btnGetLogger: TButton
    Left = 8
    Top = 214
    Width = 75
    Height = 25
    Caption = 'GetLogger'
    TabOrder = 3
    OnClick = btnGetLoggerClick
  end
  object btnOutputDbgStr: TButton
    Left = 89
    Top = 215
    Width = 104
    Height = 25
    Caption = 'OutpudDebugString'
    TabOrder = 4
    OnClick = btnOutputDbgStrClick
  end
  object btnTwoLoggerOneStorage: TButton
    Left = 199
    Top = 215
    Width = 138
    Height = 25
    Caption = 'Two Logger One Storage'
    TabOrder = 5
    OnClick = btnTwoLoggerOneStorageClick
  end
end
