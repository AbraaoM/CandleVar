//+------------------------------------------------------------------+
//|                                                    CandleVar.mq5 |
//|                                                   Abraão Moreira |
//|                                                abraaomoreira.com |
//+------------------------------------------------------------------+
#property copyright "Abraão Moreira"
#property link      "abraaomoreira.com"
#property version   "1.04"

#include <Trade/Trade.mqh>
#include <Limitations.mqh>
#include <Inputcheck.mqh>

#resource "\\VWAP.ex5"

enum PRICE_TYPE 
  {
   OPEN,
   CLOSE,
   HIGH,
   LOW,
   OPEN_CLOSE,
   HIGH_LOW,
   CLOSE_HIGH_LOW,
   OPEN_CLOSE_HIGH_LOW
  };

enum ACTION{
  SELL,
  BUY,
  NOTHING
};

enum SWITCH{
  ON,     //Ligado
  OFF     //Desligado
};

//+------------------------------------------------------------------+
//|  Inputs                                                          |
//+------------------------------------------------------------------+
input group "CONFIGURAÇÕES DO EXPERT";
  input double amount = 1;              //Quantidade de contratos
  input double TP = 300;                //Take profit
  input double SL = 100;                //Stop loss
  input double maxLoss = 1000;          //Loss máximo no dia
  input double maxProfit = 3000;        //Lucro máximo no dia
  input double minVolume5min = 50;      //Volume mínimo (5 min)
  input double minVolume1min = 20;      //Volume mínimo (1 min)
  input double minSize5min = 100;       //Tamanho mínimo (5 min)
  input double minSize1min = 50;        //Tamanho mínimo (1 min)
  input double minVWAPDistance = 100;   //Distância mínima até a VWAP
input group "CONFIGURAÇÕES DO INDICADOR";
  input SWITCH showVWAP = OFF;                    //Exibição gráfica da VWAP
  input PRICE_TYPE PriceType = CLOSE_HIGH_LOW;    //Tipo de preço utilizado para VWAP
input group "CONFIGURAÇÕES DO HORÁRIO";
  input string beginHour = "09:30";     //Horário de início (HH:MM)
  input string finishHour = "17:30";    //Horário de fim (HH:MM)

CTrade trade;
CInputCheck inputCheck;
CLimitations limitations;

int vwapHandle = 0;
double referenceNewCandle = 0;
string today;

double vwapBuffer[];


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {   
  vwapHandle = iCustom(NULL,
                       0,
                       "::VWAP.ex5",
                       "Volume Weighted Average Price (VWAP)",
                       PriceType);
  if(showVWAP == ON)                       
    ChartIndicatorAdd(0, 0, vwapHandle);                   
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  ChartIndicatorDelete(0, 0, "CandleVar.ex5::VWAP");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  ACTION orderControl = NOTHING; 

  double bid,
         ask;
         
  today = TimeToString(TimeCurrent(), TIME_DATE);      

  limitations.ProfitReached(maxProfit, StringToTime(today), TimeCurrent());
  limitations.LossReached(maxLoss, StringToTime(today), TimeCurrent());
  
  limitations.TimeLimit(finishHour, INT_MAX, true);
  
  ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
  bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);

  PositionSelect(_Symbol);
  
  orderControl = OperationalStrategy();
  if(orderControl == BUY &&
      inputCheck.VolumesOk(amount) &&
      limitations.InTimeInterval(beginHour, finishHour, true, false)) {
    trade.Buy(amount, NULL, ask, ask - SL*_Point, ask + TP*_Point);
  }
  if(orderControl == SELL &&
      inputCheck.VolumesOk(amount) &&
      limitations.InTimeInterval(beginHour, finishHour, true, false)) {
    trade.Sell(amount, NULL, bid, bid + SL*_Point, bid - TP*_Point);
  }  
}

//+------------------------------------------------------------------+
//|  Is new 5 minute candle function                                 |
//+------------------------------------------------------------------+
bool isNewCandle5min(){
  double m5Close = iClose(_Symbol,PERIOD_M5,1);
  
  if(m5Close != referenceNewCandle){
    referenceNewCandle = m5Close;
    return true;
  }
  return false;  
}

//+------------------------------------------------------------------+
//|  Operational Strategy Function                                   |
//+------------------------------------------------------------------+
ACTION OperationalStrategy(){
  long m1Volume,
       m5Volume;
       
  double m1Close,
         m5Close,
         m1Open,
         m5Open,
         m1Size,
         m5Size,
         vwapDistance;
         
  m1Close = iClose(_Symbol,PERIOD_M1,1) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  m5Close = iClose(_Symbol,PERIOD_M5,1) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  m1Open = iOpen(_Symbol, PERIOD_M1, 1) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  m5Open = iOpen(_Symbol, PERIOD_M5, 1) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  m1Volume = iRealVolume(_Symbol,PERIOD_M1,1);
  m5Volume = iRealVolume(_Symbol,PERIOD_M5,1);
  CopyBuffer(vwapHandle, 0, 0, 1, vwapBuffer);
  m1Size = fabs(m1Open - m1Close);
  m5Size = fabs(m5Open - m5Close);
  vwapDistance = fabs(vwapBuffer[0] - SymbolInfoDouble(_Symbol, SYMBOL_LAST)) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  if(isNewCandle5min() &&
     m1Size >= minSize1min &&
     m5Size >= minSize5min &&
     m1Volume >= minVolume1min &&
     m5Volume >= minVolume5min &&
     vwapDistance >= minVWAPDistance){
    if((m1Close - m1Open) > 0 &&
       (m5Close - m5Open) > 0 )
      return BUY;
    if((m1Close - m1Open) < 0 &&
       (m5Close - m5Open) < 0 )
      return SELL;
  }
  return NOTHING;
}
//+------------------------------------------------------------------+
