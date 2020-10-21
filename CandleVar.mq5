//+------------------------------------------------------------------+
//|                                                    CandleVar.mq5 |
//|                                                   Abraão Moreira |
//|                                                abraaomoreira.com |
//+------------------------------------------------------------------+
#property copyright "Abraão Moreira"
#property link      "abraaomoreira.com"
#property version   "1.00"

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
input group "CONFIGURAÇÕES DO HORÁRIO";
  input string beginTime = "09:30";
  input string finishTime = "17:30";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

}
//+------------------------------------------------------------------+
