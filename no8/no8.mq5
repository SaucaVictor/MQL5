#include <Trade/Trade.mqh>
CTrade trade;

ulong pticket;
input int start_hour = 0;
input int end_hour = 23;
input int fastema = 8;
input double lot = 1.00;
input double risk=500,rrr=1;
double ema1,s_price,b_price;
int fresh,s=1;
bool IsInTradingHours()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int currentHour = dt.hour;
   
   return currentHour >= start_hour && currentHour <= end_hour;
}
int OnInit(){ 
   ema1 = iMA(_Symbol,PERIOD_CURRENT,fastema,0,MODE_SMMA,PRICE_CLOSE);
   return(INIT_SUCCEEDED);
}
void OnTick(){
   if (!IsInTradingHours()){
      if(pticket){
         trade.PositionClose(pticket,0);
         pticket=0;
      }
      return;
   }
   double e1[];
   CopyBuffer(ema1,0,1,1,e1);
   s_price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   b_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   if(!pticket){
      if(b_price<e1[0]){
         trade.Sell(lot,_Symbol);
         pticket=trade.ResultOrder(); 
         s=1;
      }else{
         if(s_price>ema1){
            trade.Buy(lot,_Symbol);
            pticket=trade.ResultOrder(); 
         }
         s=0;
      }
   }else{
      if(PositionSelectByTicket(pticket)){
         if(PositionGetDouble(POSITION_PROFIT)>=rrr*risk){
            trade.PositionClose(pticket,0);
            if(s){
               trade.Sell(lot,_Symbol);
               pticket=trade.ResultOrder(); 
               s=1;
            }else{
               trade.Buy(lot,_Symbol);
               pticket=trade.ResultOrder(); 
               s=0;
            }
         }else{
            if(PositionGetDouble(POSITION_PROFIT)<=(-1)*risk){
               trade.PositionClose(pticket,0);
               if(s){
                  trade.Buy(lot,_Symbol);
                  pticket=trade.ResultOrder();
                  s=0;
               }else{
                  trade.Sell(lot,_Symbol);
                  pticket=trade.ResultOrder(); 
                  s=1;
               }
            }
         }
      }
   }
}
