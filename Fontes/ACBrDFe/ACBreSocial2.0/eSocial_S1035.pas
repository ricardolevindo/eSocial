{******************************************************************************}
{ Projeto: Componente ACBreSocial                                              }
{  Biblioteca multiplataforma de componentes Delphi para envio dos eventos do  }
{ eSocial - http://www.esocial.gov.br/                                         }
{                                                                              }
{ Direitos Autorais Reservados (c) 2008 Wemerson Souto                         }
{                                       Daniel Simoes de Almeida               }
{                                       Andr� Ferreira de Moraes               }
{                                                                              }
{ Colaboradores nesse arquivo:                                                 }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do Projeto ACBr     }
{ Componentes localizado em http://www.sourceforge.net/projects/acbr           }
{                                                                              }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }
{                                                                              }
{******************************************************************************}


{$I ACBr.inc}

unit eSocial_S1035;

interface

uses
  SysUtils, Classes, DateUtils, Controls,
  eSocial_Common, eSocial_Conversao,
  pcnConversao,
  ACBreSocialGerador;

type
  TS1035Collection = class;
  TS1035CollectionItem = class;
  TEvtTabCarreira = class;
  TIdeCarreira = class;
  TInfoCarreira = class;
  TDadosCarreira = class;

  TS1035Collection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TS1035CollectionItem;
    procedure SetItem(Index: Integer; Value: TS1035CollectionItem);
  public
    function Add: TS1035CollectionItem;
    property Items[Index: Integer]: TS1035CollectionItem read GetItem write SetItem; default;
  end;

  TS1035CollectionItem = class(TCollectionItem)
  private
    FTipoEvento: TTipoEvento;
    FEvtTabCarreira: TEvtTabCarreira;
    procedure setEvtTabCarreira(const Value: TEvtTabCarreira);
  public
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;
  published
    property TipoEvento: TTipoEvento read FTipoEvento;
    property evtTabCarreira: TEvtTabCarreira read FEvtTabCarreira write FEvtTabCarreira;
  end;

  TEvtTabCarreira = class(TeSocialEvento)
  private
    FModoLancamento: TModoLancamento;
    FIdeEvento: TIdeEvento;
    FIdeEmpregador: TIdeEmpregador;
    FInfoCarreira: TInfoCarreira;
  public
    constructor Create(AACBreSocial: TObject);overload;
    destructor Destroy; override;

    function GerarXML: boolean; override;
    procedure gerarIdeCarreira();
    procedure gerarDadosCarreira();
    property ModoLancamento: TModoLancamento read FModoLancamento write FModoLancamento;
    property IdeEvento: TIdeEvento read fIdeEvento write fIdeEvento;
    property IdeEmpregador: TIdeEmpregador read fIdeEmpregador write fIdeEmpregador;
    property InfoCarreira: TInfoCarreira read FInfoCarreira write FInfoCarreira;
  end;

  TDadosCarreira = class(TPersistent)
  private
    FDSCCarreira: string;
    FLeiCarr: string;
    FDTLeiCarr: TDate;
    FSitCarr: tpSitCarr;
  public
    property dscCarreira: string read FDSCCarreira write FDSCCarreira;
    property leiCarr: string read FLeiCarr write FLeiCarr;
    property dtLeiCarr: TDate read FDTLeiCarr write FDTLeiCarr;
    property sitCarr: tpSitCarr read FSitCarr write FSitCarr;
  end;

  TIdeCarreira = class(TPersistent)
  private
    FCodCarreira: string;
    FIniValid : string;
    FFimValid : string;
  public
    property codCarreira: string read FCodCarreira write FCodCarreira;
    property iniValid: string read FIniValid write FIniValid;
    property fimValid: string read FFimValid write FFimValid;
  end;

  TInfoCarreira = class(TPersistent)
  private
    FIdeCarreira: TIdeCarreira;
    FDadosCarreira: TDadosCarreira;
    FNovaValidade: TidePeriodo;

    function getNovaValidade: TidePeriodo;
  public
    constructor create;
    destructor destroy; override;
    function novaValidadeInst(): Boolean;

    property dadosCarreira: TDadosCarreira read FDadosCarreira write FDadosCarreira;
    property ideCarreira: TIdeCarreira read FIdeCarreira write FIdeCarreira;
    property NovaValidade: TidePeriodo read getNovaValidade write FNovaValidade;
  end;

implementation

{ TS1035Collection }

function TS1035Collection.Add: TS1035CollectionItem;
begin
  Result := TS1035CollectionItem(inherited Add);
  Result.Create(TComponent(Self.Owner));
end;

function TS1035Collection.GetItem(Index: Integer): TS1035CollectionItem;
begin
  Result := TS1035CollectionItem(inherited GetItem(Index));
end;

procedure TS1035Collection.SetItem(Index: Integer;
  Value: TS1035CollectionItem);
begin
  inherited SetItem(Index, Value);
end;

{ TS1035CollectionItem }

constructor TS1035CollectionItem.Create(AOwner: TComponent);
begin
  FTipoEvento := teS1035;
  FEvtTabCarreira := TEvtTabCarreira.Create(AOwner);
end;

destructor TS1035CollectionItem.Destroy;
begin
  FEvtTabCarreira.Free;
  inherited;
end;

procedure TS1035CollectionItem.setEvtTabCarreira(const Value: TEvtTabCarreira);
begin
  FEvtTabCarreira.Assign(Value);
end;

{ TInfoCarreira }

constructor TInfoCarreira.create;
begin
  FIdeCarreira := TIdeCarreira.Create;
  FDadosCarreira := TDadosCarreira.Create;
  FNovaValidade := nil;
end;


destructor TInfoCarreira.destroy;
begin
  FIdeCarreira.Free;
  FDadosCarreira.Free;
  FreeAndNil(FNovaValidade);
  inherited;
end;

function TInfoCarreira.getNovaValidade: TidePeriodo;
begin
  if Not(Assigned(FNovaValidade)) then
    FNovaValidade := TIdePeriodo.Create;
  Result := FNovaValidade;
end;

function TInfoCarreira.novaValidadeInst: Boolean;
begin
  Result := Assigned(FNovaValidade);
end;

{ TEvtTabCarreira }

constructor TEvtTabCarreira.Create(AACBreSocial: TObject);
begin
  inherited;
  fIdeEvento := TIdeEvento.Create;
  fIdeEmpregador := TIdeEmpregador.Create;
  FInfoCarreira := TInfoCarreira.Create;
end;

destructor TEvtTabCarreira.Destroy;
begin
  fIdeEvento.Free;
  fIdeEmpregador.Free;
  FInfoCarreira.Free;
  inherited;
end;

procedure TEvtTabCarreira.gerarDadosCarreira;
begin
  Gerador.wGrupo('dadosCarreira');
    Gerador.wCampo(tcStr, '', 'dscCarreira', 0, 0, 0, InfoCarreira.dadosCarreira.dscCarreira);
    Gerador.wCampo(tcStr, '', 'leiCarr', 0, 0, 0, InfoCarreira.dadosCarreira.leiCarr);
    Gerador.wCampo(tcDat, '', 'dtLeiCarr', 0, 0, 0, InfoCarreira.dadosCarreira.dtLeiCarr);
    Gerador.wCampo(tcInt, '', 'sitCarr', 0, 0, 0, eStpSitCarrToStr(InfoCarreira.dadosCarreira.sitCarr));
  Gerador.wGrupo('/dadosCarreira');
end;

procedure TEvtTabCarreira.gerarIdeCarreira;
begin
  Gerador.wGrupo('ideCarreira');
    Gerador.wCampo(tcStr, '', 'codCarreira', 0, 0, 0, InfoCarreira.ideCarreira.codCarreira);
    Gerador.wCampo(tcStr, '', 'iniValid', 0, 0, 0, InfoCarreira.ideCarreira.iniValid);
    Gerador.wCampo(tcStr, '', 'fimValid', 0, 0, 0, InfoCarreira.ideCarreira.fimValid);
  Gerador.wGrupo('/ideCarreira');
end;

function TEvtTabCarreira.GerarXML: boolean;
begin
  try
    gerarCabecalho('evtTabCarreira');
    Gerador.wGrupo('evtTabCarreira Id="'+ GerarChaveEsocial(now, self.ideEmpregador.NrInsc, 0) +'"');
      //gerarIdVersao(self);
      gerarIdeEvento(self.IdeEvento);
      gerarIdeEmpregador(self.IdeEmpregador);
      Gerador.wGrupo('infoCarreira');
      gerarModoAbertura(Self.ModoLancamento);
        gerarIdeCarreira();
        if Self.ModoLancamento <> mlExclusao then
        begin
          gerarDadosCarreira();
          if Self.ModoLancamento = mlAlteracao then
            if (InfoCarreira.novaValidadeInst()) then
              GerarIdePeriodo(InfoCarreira.NovaValidade, 'novaValidade');
        end;
      gerarModoFechamento(Self.ModoLancamento);
      Gerador.wGrupo('/infoCarreira');
    Gerador.wGrupo('/evtTabCarreira');
    GerarRodape;

    XML := Assinar(Gerador.ArquivoFormatoXML, 'evtTabCarreira');
    Validar('evtTabCarreira');
  except on e:exception do
    raise Exception.Create(e.Message);
  end;

  Result := (Gerador.ArquivoFormatoXML <> '')
end;


end.
