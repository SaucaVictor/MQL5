#include <Trade/Trade.mqh>

input int start_hour = 0;
input int end_hour = 23;
input double lot = 1.00;
double lots=lot;
input double tp = 30;
double ema1,ema2,ema3,rsi;
input int fastema=8;
input int slowema=40;
input bool ema_trend_confirm=true; 
input int confirm_trand_ema=200;
input bool alternative_lot=true;
input bool exponential=true;
input int ratio=2;
input double constant=1.00;
input bool add=false;
int k=0,p=0,ok1=1,ok2=1;
input int n = 5;//Nr. de comenzi
input bool rsi_confirm=true;
input int rsi_period=14;

input group "Evade hours | -1 is not avoiding | the number of the hour is | example: h8=8 is avoiding the interval 8:00 - 8:59 | double click to hide " 
input int h0=-1;input int h1=-1;
input int h2=-1;input int h3=-1;
input int h4=-1;input int h5=-1;
input int h6=-1;input int h7=-1;
input int h8=-1;input int h9=-1;
input int h10=-1;input int h11=-1;
input int h12=-1;input int h13=-1;
input int h14=-1;input int h15=-1;
input int h16=-1;input int h17=-1;
input int h18=-1;input int h19=-1;
input int h20=-1;input int h21=-1;
input int h22=-1;input int h23=-1;


ulong pticket;
ulong ticket_array[100];
int fresh_upload=-1,first_cross,ok=0;
ulong v[100]={NULL};
CTrade trade;

int OnInit(){   
   ema1 = iMA(_Symbol,PERIOD_CURRENT,fastema,0,MODE_SMMA,PRICE_CLOSE);
   ema2 = iMA(_Symbol,PERIOD_CURRENT,slowema,0,MODE_SMA,PRICE_CLOSE);
   if(confirm_trand_ema)
      ema3 = iMA(_Symbol,PERIOD_CURRENT,confirm_trand_ema,0,MODE_EMA,PRICE_CLOSE);
   
   if(rsi_confirm)
      rsi=iRSI(_Symbol,PERIOD_CURRENT,rsi_period,PRICE_CLOSE);
   
   if(ema1<ema2 && ok==0){
      first_cross=0;
      ok++;
   }else{
      first_cross=1;
      ok++;
   }
   return(INIT_SUCCEEDED);
}

bool isit(int x){
   if(x==h0)return false;if(x==h12)return false;
   if(x==h1)return false;if(x==h13)return false;
   if(x==h2)return false;if(x==h14)return false;
   if(x==h3)return false;if(x==h15)return false;
   if(x==h4)return false;if(x==h16)return false;
   if(x==h5)return false;if(x==h17)return false;
   if(x==h6)return false;if(x==h18)return false;
   if(x==h7)return false;if(x==h19)return false;
   if(x==h8)return false;if(x==h20)return false;
   if(x==h9)return false;if(x==h21)return false;
   if(x==h10)return false;if(x==h22)return false;
   if(x==h11)return false;if(x==h23)return false;
   
   return true;
}
bool IsInTradingHours()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int currentHour = dt.hour;
   
   return currentHour >= start_hour && currentHour <= end_hour && isit(currentHour);
}

void OnTick(){
   if (!IsInTradingHours()){
      if(pticket && tp==0){
         trade.PositionClose(pticket,0);
      }
      return;
   }
   double e1[],e2[],e3[],r[];
   CopyBuffer(ema1,0,1,1,e1);
   CopyBuffer(ema2,0,1,1,e2);
   CopyBuffer(ema3,0,1,1,e3);
   CopyBuffer(rsi,0,1,1,r);
   if(!ema_trend_confirm){
      if(tp!=0){
         if(e1[0]<e2[0]){
            if(rsi_confirm){
                  if(pticket<=0 && r[0]<50.00){
                     trade.Sell(lots,_Symbol);
                     pticket = trade.ResultOrder(); 
                     
                     if(PositionSelectByTicket(pticket)){
                        double price = PositionGetDouble(POSITION_PRICE_OPEN);
                        trade.PositionModify(pticket,0,price-tp);
                     }
                  }else{
                     if((int)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
                           if(alternative_lot){
                              if(PositionSelectByTicket(pticket)){
                                 if(PositionGetDouble(POSITION_PROFIT)>0){
                                    if(exponential){
                                       lots+=(double)1/ratio*lots;
                                    }else{
                                       lots+=constant;
                                    }
                                    lots=NormalizeDouble(lots,2);
                                 }else{
                                          lots=lot;
                                 }
                              }
                           }else{
                                 lots=lot;
                           }
                           trade.PositionClose(pticket,0);
                           if(r[0]<50.00){
                              trade.Sell(lots,_Symbol);
                              pticket = trade.ResultOrder();
                           }else{
                              pticket = 0;
                           }
                           if(PositionSelectByTicket(pticket)){
                              double price = PositionGetDouble(POSITION_PRICE_OPEN);
                              trade.PositionModify(pticket,0,price-tp);
                           }
                        }
                  }
               
               
            }else{//if !rsi_confirm
               if(pticket<=0){
                  trade.Sell(lots,_Symbol);
                  pticket = trade.ResultOrder(); 
                  if(PositionSelectByTicket(pticket)){
                     double price = PositionGetDouble(POSITION_PRICE_OPEN);
                     trade.PositionModify(pticket,0,price-tp);
                  }
               }else{
                  if((int)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
                        if(alternative_lot){
                           if(PositionSelectByTicket(pticket)){
                              if(PositionGetDouble(POSITION_PROFIT)>0){
                                 if(exponential){
                                    lots+=(double)1/ratio*lots;
                                 }else{
                                    lots+=constant;
                                 }
                                 lots=NormalizeDouble(lots,2);
                              }else{
                                       lots=lot;
                              }
                           }
                        }else{
                              lots=lot;
                        }
                        trade.PositionClose(pticket,0);
                        
                        trade.Sell(lots,_Symbol);
                        pticket = trade.ResultOrder();
                        if(PositionSelectByTicket(pticket)){
                           double price = PositionGetDouble(POSITION_PRICE_OPEN);
                           trade.PositionModify(pticket,0,price-tp);
                        }
                     }
               }
            }
            
         }else{
            if(e1[0]>e2[0]){
               if(pticket<=0){
                     trade.Buy(lots,_Symbol);
                     pticket = trade.ResultOrder();
                     if(PositionSelectByTicket(pticket)){
                        double price = PositionGetDouble(POSITION_PRICE_OPEN);
                        trade.PositionModify(pticket,0,price+tp);
                     }
               }else{
                  if((int)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){
                     if(alternative_lot){
                        if(PositionSelectByTicket(pticket)){
                           if(PositionGetDouble(POSITION_PROFIT)>0){
                              if(exponential){
                                 lots+=(double)1/ratio*lots;
                              }else{
                                 lots+=constant;
                              }
                              lots=NormalizeDouble(lots,2);
                           }else{
                                    lots=lot;
                           }
                        }
                     }else{
                           lots=lot;
                     }
                     
                     trade.PositionClose(pticket,0);
                     trade.Buy(lots,_Symbol);
                     pticket = trade.ResultOrder();
                     if(PositionSelectByTicket(pticket)){
                        double price = PositionGetDouble(POSITION_PRICE_OPEN);
                        trade.PositionModify(pticket,0,price+tp);
                     }
                  }
               }
            }
         }
      }else{
            if(e1[0]<e2[0]){
                     if(pticket<=0){
                        trade.Sell(lots,_Symbol);
                        pticket = trade.ResultOrder(); 
                     }else{
                        if((int)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
                              if(alternative_lot){
                                 if(PositionSelectByTicket(pticket)){
                                    if(PositionGetDouble(POSITION_PROFIT)>0){
                                       if(exponential){
                                          lots+=(double)1/ratio*lots;
                                       }else{
                                          lots+=constant;
                                       }
                                       lots=NormalizeDouble(lots,2);
                                    }else{
                                       lots=lot;
                                    }
                                 }
                              }else{
                                    lots=lot;
                              }
                              trade.PositionClose(pticket,0);
                              trade.Sell(lots,_Symbol);
                               
                              pticket = trade.ResultOrder();
                           }
                     }
                  }else{
                     if(e1[0]>e2[0]){
                        if(pticket<=0){
                               
                              trade.Buy(lots,_Symbol);
                              pticket = trade.ResultOrder();
                        }else{
                           if((int)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){
                              if(alternative_lot){
                                 if(PositionSelectByTicket(pticket)){
                                    if(PositionGetDouble(POSITION_PROFIT)>0){
                                       if(exponential){
                                          lots+=(double)1/ratio*lots;
                                       }else{
                                          lots+=constant;
                                       }
                                       lots=NormalizeDouble(lots,2);
                                    }else{
                                       lots=lot;
                                    }
                                 }
                              }else{
                                    lots=lot;
                              }
                              trade.PositionClose(pticket,0);
                              trade.Buy(lots,_Symbol);
                              pticket = trade.ResultOrder();
                           }
                        }
                     }
                  }
               
               }
    }else{//-------------------------------------------------------------------------------------------
         if(!add){
             if(e2[0]<e3[0]){
                  if(e1[0]<e2[0]){
                     if(pticket<=0){
                        trade.Sell(lots,_Symbol);
                        pticket = trade.ResultOrder(); 
                        if(tp!=0){
                           if(PositionSelectByTicket(pticket)){
                              double price = PositionGetDouble(POSITION_PRICE_OPEN);
                              trade.PositionModify(pticket,0,price-tp);
                           }
                        }else{;}
                     }
                  }else{
                       if(pticket<=0){
                            ;
                        }else{
                           if((int)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){
                              if(alternative_lot){
                                 if(PositionSelectByTicket(pticket)){
                                    if(PositionGetDouble(POSITION_PROFIT)>0){
                                       if(exponential){
                                          lots+=(double)1/ratio*lots;
                                       }else{
                                          lots+=constant;
                                       }
                                       lots=NormalizeDouble(lots,2);
                                    }else{
                                             lots=lot;
                                    }
                                 }
                              }else{
                                    lots=lot;
                              }
                              trade.PositionClose(pticket,0);
                              pticket = 0;
                           }
                        }
                     }
                 }else{
                     if(e2[0]>e3[0]){
                        if(e1[0]>e2[0]){
                           if(pticket<=0){
                              trade.Buy(lots,_Symbol);
                              pticket = trade.ResultOrder(); 
                              if(tp!=0){
                                 if(PositionSelectByTicket(pticket)){
                                    double price = PositionGetDouble(POSITION_PRICE_OPEN);
                                    trade.PositionModify(pticket,0,price+tp);
                                 }
                              }else{;}
                           }
                        }else{
                           if(pticket<=0){
                               ;
                           }else{
                              if((int)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
                                 if(alternative_lot){
                                    if(PositionSelectByTicket(pticket)){
                                       if(PositionGetDouble(POSITION_PROFIT)>0){
                                          if(exponential){
                                             lots+=(double)1/ratio*lots;
                                          }else{
                                             lots+=constant;
                                          }
                                          lots=NormalizeDouble(lots,2);
                                       }else{
                                                lots=lot;
                                       }
                                    }
                                 }else{
                                       lots=lot;
                                 }
                                 trade.PositionClose(pticket,0);
                                 pticket = 0;
                              }
                          }
                        }
                     }
                 }
          }else{//if add
               if(e2[0]<e3[0]){
                  if(p>0){
                     CloseAll(p);
                     p=0;
                  }
                  if(e1[0]<e2[0]){
                     if(k<n && !ok1){
                        trade.Sell(lots,_Symbol);
                        pticket = trade.ResultOrder();
                        v[k]=pticket;
                        k++;
                        ok1++;
                        if(tp!=0){
                           if(PositionSelectByTicket(pticket)){
                              double price = PositionGetDouble(POSITION_PRICE_OPEN);
                              trade.PositionModify(pticket,0,price-tp);
                           }
                        }else{;}
                     }
                  }else{ok1=0;
                              if(alternative_lot){
                                 if(PositionSelectByTicket(pticket)){
                                    if(PositionGetDouble(POSITION_PROFIT)>0){
                                       if(exponential){
                                          lots-=(double)1/ratio*lots;
                                       }else{
                                          lots-=constant;
                                       }
                                       lots=NormalizeDouble(lots,2);
                                    }else{
                                             lots=lot;
                                    }
                                 }
                              }else{
                                    lots=lot;
                              }
                     }
                 }else{
                     if(e2[0]>e3[0]){
                        if(k>0){
                           CloseAll(k);
                           k=0;
                        }
                        if(e1[0]>e2[0]){
                           if(p<n && !ok1){
                              trade.Buy(lots,_Symbol);
                              pticket = trade.ResultOrder(); 
                              v[p]=pticket;
                              p++;
                              ok1++;
                              if(tp!=0){
                                 if(PositionSelectByTicket(pticket)){
                                    double price = PositionGetDouble(POSITION_PRICE_OPEN);
                                    trade.PositionModify(pticket,0,price+tp);
                                 }
                              }else{;}
                           }
                        }else{ok1=0;
                                 if(alternative_lot){
                                    if(PositionSelectByTicket(pticket)){
                                       if(PositionGetDouble(POSITION_PROFIT)>0){
                                          if(exponential){
                                             lots-=(double)1/ratio*lots;
                                          }else{
                                             lots-=constant;
                                          }
                                          lots=NormalizeDouble(lots,2);
                                       }else{
                                                lots=lot;
                                       }
                                    }
                                 }else{
                                       lots=lot;
                                 }
                          }
                      }
                }
          }
    }
}
void CloseAll(int i){
   while(i>=0){
      if(v[i]){
         trade.PositionClose(v[i],0);
         v[i]=0;
      }
      i--;
   }
}
