#include <Trade/Trade.mqh>
CTrade trade;

ulong pticket;
input int start_hour = 0;
input int end_hour = 23;
input int fastema = 8;
input double lot = 1.00;
input double risk=500,rrr=1;
int s=0;
input int cnt=1;
int cnt_=1,i=-1;
ulong v[100]={NULL};
input bool pro=true;
input int levrage=80;
double fullmargin;
double diff;
input double acc=100000;
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
double ema1,s_price,b_price;
void OnTick(){
   if (!IsInTradingHours()){
      cnt_=cnt;
      if(pticket){
         trade.PositionClose(pticket,0);
         pticket=0;
      }
      if(v[0]){
         CloseAll(i);pticket=0;
      }
      
      return;
   }
   
   double e1[];
   CopyBuffer(ema1,0,1,1,e1);
   s_price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   b_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   //if(cnt_>0){ shimba codul aici pt varianta de un an 
      if(!pticket && cnt_>0){
         if(b_price<e1[0]){
            if(iOpen(_Symbol,PERIOD_CURRENT,3)>iClose(_Symbol,PERIOD_CURRENT,3)){
               if(iOpen(_Symbol,PERIOD_CURRENT,2)>iClose(_Symbol,PERIOD_CURRENT,2)){
                  if(iOpen(_Symbol,PERIOD_CURRENT,1)>iClose(_Symbol,PERIOD_CURRENT,1)){
                     if(iLow(_Symbol,PERIOD_CURRENT,3)>iHigh(_Symbol,PERIOD_CURRENT,1)){
                        if(!pro){
                           if(lot>10){
                              int c=lot/10,lots;
                              lots=lot-c*10;
                              while(c){
                                 trade.Sell(10,_Symbol);
                                 pticket=trade.ResultOrder();
                                 i++;
                                 v[i]=pticket;
                                 c--;
                              }
                              if(lots){
                                 trade.Sell(lots,_Symbol);
                                 pticket=trade.ResultOrder();
                                 i++;
                                 v[i]=pticket;
                              }
                              cnt_--;
                           }else{
                              trade.Sell(lot,_Symbol);
                              pticket=trade.ResultOrder();
                              s=0;
                              cnt_--;
                           }
                        }else{
                           diff=iLow(_Symbol,PERIOD_CURRENT,3)-iHigh(_Symbol,PERIOD_CURRENT,1);
                           if(diff<0)diff*=-1;
                           fullmargin = (acc*levrage)/(s_price*100);
                           int c=fullmargin/10;
                           while(c){
                              trade.Sell(10,_Symbol);
                              pticket=trade.ResultOrder();
                              i++;
                              v[i]=pticket;
                              c--;
                           }
                           cnt_--;
                        }
                     }
                  }
               }
            }
         }else{
            if(s_price>e1[0]){
               if(iOpen(_Symbol,PERIOD_CURRENT,3)<iClose(_Symbol,PERIOD_CURRENT,3)){
                  if(iOpen(_Symbol,PERIOD_CURRENT,2)<iClose(_Symbol,PERIOD_CURRENT,2)){
                     if(iOpen(_Symbol,PERIOD_CURRENT,1)<iClose(_Symbol,PERIOD_CURRENT,1)){
                        if(iHigh(_Symbol,PERIOD_CURRENT,3)<iLow(_Symbol,PERIOD_CURRENT,1)){
                           if(!pro){
                              if(lot>10){
                                 int c=lot/10,lots;
                                 lots=lot-c*10;
                                 while(c){
                                    trade.Buy(10,_Symbol);
                                    pticket=trade.ResultOrder();
                                    i++;
                                    v[i]=pticket;
                                    c--;
                                 }
                                 if(lots){
                                    trade.Buy(lots,_Symbol);
                                    pticket=trade.ResultOrder();
                                    i++;
                                    v[i]=pticket;
                                 }
                                 cnt_--;
                              }else{
                                 trade.Buy(lot,_Symbol);
                                 pticket=trade.ResultOrder();
                                 s=1;
                                 cnt_--;
                              }
                           }else{
                              diff=iHigh(_Symbol,PERIOD_CURRENT,3)-iLow(_Symbol,PERIOD_CURRENT,1);
                              if(diff<0)diff*=-1;
                              fullmargin = (acc*levrage)/(s_price*100);
                              int c=fullmargin/10;
                              while(c){
                                 trade.Buy(10,_Symbol);
                                 pticket=trade.ResultOrder();
                                 i++;
                                 v[i]=pticket;
                                 c--;
                              }
                              cnt_--;
                           }
                        }
                     }
                  }
               }
            }
         }
      }else{
         if(!v[0]){
            if(PositionSelectByTicket(pticket)){
               if(PositionGetDouble(POSITION_PROFIT)>=rrr*risk){
                  trade.PositionClose(pticket,0);
                  pticket=0;
               }else{
                  if(PositionGetDouble(POSITION_PROFIT)<=(-1)*risk){
                     trade.PositionClose(pticket,0);
                     pticket=0;
                  }
               }
            }
         }else{
            if(!pro){
               double profit=0;
               int j=i;
               while(j>=0){
                  if(PositionSelectByTicket(v[j])){
                     profit+=PositionGetDouble(POSITION_PROFIT);
                  }
                  j--;
               }
               printf("- profit: %.2f",profit);
               if(profit>=rrr*risk){
                  CloseAll(i);
                  pticket=0;
                  i=-1;
               }else{
                  if(profit<=(-1)*risk){
                     CloseAll(i);
                     pticket=0;
                     i=-1;
                  }
               }
            }else{
               double profit=0;
               int j=i;
               while(j>=0){
                  if(PositionSelectByTicket(v[j])){
                     profit+=PositionGetDouble(POSITION_PROFIT);
                  }
                  j--;
               }
               printf("- profit: %.2f",profit);
               if(profit>=diff*1000*10){
                  CloseAll(i);
                  pticket=0;
                  i=-1;
               }else{
                  if(profit<=(-20)*diff*1000){
                     CloseAll(i);
                     pticket=0;
                     i=-1;
                  }
               }
            }
         }
      }
   //}
}
void CloseAll(int i){
   while(i>=0){
      if(PositionSelectByTicket(v[i])){
         trade.PositionClose(v[i],0);
         v[i]=0;
      }
      i--;
   }
   i=-1;
   pticket=0;
}
