#include <Trade/Trade.mqh>
CTrade trade;

ulong pticket;
input int start_hour = 15;
input int end_hour = 17;
input int fastema = 8;
input double lots = 0.01;
double lot=lots;
input double ris=0.3125,rrr=2;
input int ddwn=4;
double risk=ris;
input int accnt=50;
input bool dd_=true;
double ema1,s_price,b_price;
int fresh,s=1;
double acc,initial,summ=accnt,l=lots,r=risk;
int i=2;
input int levr=100;double jj=0;
bool IsInTradingHours()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int currentHour = dt.hour;
   
   return currentHour >= start_hour && currentHour <= end_hour;
}
int OnInit(){ 
   initial=ACCOUNT_BALANCE;
   ema1 = iMA(_Symbol,PERIOD_CURRENT,fastema,0,MODE_SMMA,PRICE_CLOSE);
   return(INIT_SUCCEEDED);
}

void OnTick(){
   if (!IsInTradingHours()){
      if(pticket){
         trade.PositionClose(pticket,0);
         pticket=0;
      }
      if(summ>=accnt*i && lot+l<levr){
         lot+=l;
         risk+=r;
         i++;
      }
      jj=0;
      acc=ACCOUNT_BALANCE;
      return;
   }
   if(dd_ && jj<0 && (-1)*jj>summ*((ddwn-0.5)/100)){
      if(pticket){
         trade.PositionClose(pticket,0);
         pticket=0;
      }
      printf("drowdown reached");
      
      return;
   }
   double e1[];
   CopyBuffer(ema1,0,1,1,e1);
   s_price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   b_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double d;
   if(!pticket){
      if(b_price<e1[0]){
         trade.Sell(lot,_Symbol,s_price);
         pticket=trade.ResultOrder(); 
          d=b_price-s_price;
         s=1;
      }else{
         if(s_price>ema1){
            trade.Buy(lot,_Symbol,b_price);
            pticket=trade.ResultOrder(); 
             d=b_price-s_price;
         }
         s=0;
      }
   }else{
      if(PositionSelectByTicket(pticket)){
         if(PositionGetDouble(POSITION_PROFIT)>=rrr*risk){
            summ+=PositionGetDouble(POSITION_PROFIT);
            jj+=PositionGetDouble(POSITION_PROFIT);
            trade.PositionClose(pticket,0);
            if(s){
               trade.Sell(lot,_Symbol,s_price); d=s_price-b_price;
               pticket=trade.ResultOrder(); 
               s=1;
            }else{
               trade.Buy(lot,_Symbol,b_price); d=s_price-b_price;
               pticket=trade.ResultOrder(); 
               s=0;
            }
         }else{
            if(PositionGetDouble(POSITION_PROFIT)<=(-1)*risk){
               summ+=PositionGetDouble(POSITION_PROFIT);
               jj+=PositionGetDouble(POSITION_PROFIT);
               trade.PositionClose(pticket,0);
               if(s){
                  trade.Buy(lot,_Symbol,b_price); d=s_price-b_price;
                  pticket=trade.ResultOrder();
                  s=0;
               }else{
                  trade.Sell(lot,_Symbol,s_price); d=s_price-b_price;
                  pticket=trade.ResultOrder(); 
                  s=1;
               }
            }
         }
      }
   }
}
