program define logsumm
version 2.1 
*! This is version 1.2 18 October 1991
        mac def _varlist "req ex min(2)"
        mac def _in "opt"
        mac def _if "opt"
        parse "%_*"
        parse "%_varlist", parse(" ")
        mac def _lhs "%_1"
        mac shift
        mac def _rhs "%_*"
    if ("%_if"!="") {
         di in red "invalid syntax--if not allowed--see help logsumm"
         exit 198
    }
    if ("%_in"!="") {
         di in red "invalid syntax--in not allowed--see help logsumm"
         exit 198
    }
       qui su %_lhs
       mac def _ybaraw=_result(3)
    qui gen logdepv=log(%_lhs)
la var logdepv "Log of Original D.V."
       qui su logdepv
       mac def _ybar=_result(3)
       mac def _ybara=exp(_result(3))*exp(_result(4)/2)
       mac def _ybare=exp(_result(3))
        reg %_lhs %_rhs
         mac def _rmseraw=_result(9)
         mac def _rsqraw=_result(7)
         mac def _arsqraw=_result(8)
         mac def _effraw=_result(6)
         qui predict yhatr
la var yhatr "Pred. Values/Untransformed Reg."
         qui gen yhatl=log(yhatr)
la var yhatl "Log of Pred. Values/Untransformed Reg."
         qui predict double _resr, res
la var _resr "Residuals/Untransformed Reg."
           qui gen double _DWr=sum((_resr-_resr[_n-1])^2)/sum(_resr*_resr)
la var _DWr "D-W/raw regression"
           di in gr "Durbin Watson Statistic = " in ye _DWr[_N]
mac def _CVraw=((%_rmseraw/%_ybaraw))*100
mac def _NUMr=_result(1)
mac def _DFNr=_result(3)
mac def _subtr=%_NUMr-%_DFNr-1
mac def _sser=_result(4)
mac def _DFEr=_result(5)
qui gen _SSEr=sum((logdepv-yhatl)^2)
la var _SSEr "Log transformed SSE"
qui gen _SSTr=sum((logdepv-%_ybar)^2)
la var _SSTr "Log transformed SST"
mac def RSQr=1-(_SSEr[_N]/_SSTr[_N])
mac def ARSQr=(%RSQr-(%_DFNr/(%_NUMr-1)))*((%_NUMr-1)/%_DFEr)
mac def EFFr=(%RSQr/%_DFNr)/((1-%RSQr)/%_DFEr)
mac def RMSEr=sqrt(_SSEr[_N]/%_DFEr)
mac def CVr=(%RMSEr/%_ybar)*100
di ""
        reg logdepv %_rhs
         mac def _rmselog=_result(9)
         mac def _rsqlog=_result(7)
         mac def _arsqlog=_result(8)
         mac def _efflog=_result(6)
           qui predict double yhat
la var yhat "Pred.Values/Transformed Reg, Logs"
           qui predict double _res, res
la var _res "Residuals/Transformed Reg, Logs"
           qui predict double stdf, stdf
la var stdf "Forecast Err/Transformed Reg, Logs"
mac def _NUM=_result(1)
mac def _DFN=_result(3)
mac def _subt=%_NUM-%_DFN-1
mac def _sse=_result(4)
mac def _DFE=_result(5)
              qui gen stdfl=(stdf^2)/2
              qui gen yhata=exp(yhat)*exp(stdfl)
la var yhata "Retransformed, Adj., Pred. Values"
              qui gen yhate=exp(yhat)
la var yhate "Retransformed, UNadj., Pred. Values"
qui gen _SSEa=sum((%_lhs-yhata)^2)
la var _SSEa "Retransformed, Adjusted, SSE"
qui gen _SSEe=sum((%_lhs-yhate)^2)
la var _SSEe "Retransformed, UNadjusted, SSE"
qui gen _SSTa=sum((%_lhs-%_ybara)^2)
la var _SSTa "Retransformed, Adjusted, SST"
qui gen _SSTe=sum((%_lhs-%_ybare)^2)
la var _SSTe "Retransformed, UNadjusted, SST"
mac def RSQa=1-(_SSEa[_N]/_SSTa[_N])
mac def RSQe=1-(_SSEe[_N]/_SSTe[_N])
mac def ARSQa=(%RSQa-(%_DFN/(%_NUM-1)))*((%_NUM-1)/%_DFE)
mac def ARSQe=(%RSQe-(%_DFN/(%_NUM-1)))*((%_NUM-1)/%_DFE)
mac def EFFa=(%RSQa/%_DFN)/((1-%RSQa)/%_DFE)
mac def EFFe=(%RSQe/%_DFN)/((1-%RSQe)/%_DFE)
mac def RMSEa=sqrt(_SSEa[_N]/%_DFE)
mac def RMSEe=sqrt(_SSEe[_N]/%_DFE)
mac def CVa=(%RMSEa/%_ybara)*100
mac def CVe=(%RMSEe/%_ybare)*100
           qui gen double _DW=sum((_res-_res[_n-1])^2)/sum(_res*_res)
la var _DW "D-W from Transformed Reg."
           di in gr "Durbin Watson Statistic = " in ye _DW[_N]
mac def _CVlog=((%_rmselog/%_ybar))*100
di ""
di "Following are some summary statistics for each of the above two models"
di "3 of the 5 sets of statistics are 'adjusted', the other two just repeat"
di "what was shown above for ease of comparison."
di ""
di "The first column shows the unadjusted statistics for the linear model,"
di "just as shown in the first regression above; the second column shows"
di "summary statistics for the same model but this time adjusted by"
di "transforming to logs; the third column repeats the unadjusted figures"
di "from the transformed regression (the second regression above); this is"
di "followed by two sets of adjusted statistics: (1) a less biased"
di "re-transformation than the standard one (see the help file or the"
di "STB article); (2) using the 'standard', biased, re-transformation"
di "by just exponentiating the predicted values from the log model."
di ""
di _col(14) in gr "|" _col(28) "Adjusted" _sk(15) "Better" _sk(4) "Standard"
di _col(14) in gr "|" _col(19) "Raw" _sk(8) "Raw" _sk(8) "Log" _sk(5) /*
  */ "Adj'd Log" _sk(2) "Adj'd Log"
di in red _dup(70) "-"
di "R-Square" _sk(5) in gr "|" %9.4f %_rsqraw _sk(2) %9.4f %RSQr /*
  */ _sk(2) %9.4f %_rsqlog _sk(2) %9.4f %RSQa _sk(2) %9.4f %RSQe
di "Adjusted R-SQ" in gr "|" %9.4f %_arsqraw _sk(2) %9.4f %ARSQr _sk(2) /*
  */ %9.4f %_arsqlog _sk(2) %9.4f %ARSQa _sk(2) %9.4f %ARSQe
di "F-Value" _sk(6) in gr "|"  %7.2f %_effraw _sk(4) %7.2f %EFFr _sk(4) /*
  */ %7.2f %_efflog _sk(4) %7.2f %EFFa _sk(4) %7.2f %EFFe
di "RMSE" _sk(9) in gr "|"  %9.4f %_rmseraw _sk(2) %9.4f %RMSEr _sk(2) /*
  */ %9.4f %_rmselog _sk(2) %9.4f %RMSEa _sk(2) %9.4f %RMSEe
di "CV (*100)" _sk(4) in gr "|"  %7.2f %_CVraw _sk(4) %7.2f %CVr _sk(4) /*
  */ %7.2f %_CVlog _sk(4) %7.2f %CVa _sk(4) %7.2f %CVe
di ""
di ""
di "Results of the MacKinnon-Davidson (PE) test:"
    qui gen lidiff=yhatr-yhate
la var lidiff "Difference between Raw and Re-transformed log Residuals"
    qui gen lodiff=yhat-yhatl
la var lodiff "Difference between Log and Logged Raw Residuals"
    mac def _rhs3 "%_rhs lidiff"
    mac def _rhs4 "%_rhs lodiff"
    qui reg %_lhs %_rhs4
         emdef tlin2 : t lodiff	
    qui reg logdepv %_rhs3
         emdef tlog2 : t lidiff
di "The t-statistic (p-value) for test of linearity is "_sk(3) %7.3f %tlin2 /*
    */_sk(3) %4.3f in gr (tprob(%_subtr,%tlin2))
di "The t-statistic (p-value) for test of log-linearity is "_sk(3) %7.3f %tlog2 /*
    */_sk(3) %4.3f in gr (tprob(%_subt,%tlog2))
di ""
di "Note that it is quite possible that BOTH the above tests might be"
di "significant (non-significant)!!"
di "This means that this test is indeterminate for this model;"
di "in this case, the use of boxcoxg.ado may be particularly helpful;"
di "regardless, you might also want to use ramsey.ado (STB-2).
di "If only one test is significant, then we reject the functional"
di "form for which the test is significant and 'accept' the other form."
di ""
di "Following is a crude look using boxcoxg; if this appears to be informative,"
di "you might want to use boxcoxg again with a finer grid; see boxcoxg.hlp"
di ""
boxcoxg -3 3 .5 %_lhs %_rhs
drop stdfl
end
