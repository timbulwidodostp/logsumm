program define boxcoxg
version 2.1
    if %_3<=0 | %_3==. | %_1>%_2 {
         di in red "invalid syntax -- see help boxcoxg"
         exit 198
    }
    if %_3<.01 {
         di in ye "you don't really mean that, do you?"
         di in gr "any step smaller than .01 is " in red "SILLY"
         exit 197
    }
        mac def _varlist "req ex min(2)"
        mac def _if "opt"
        mac def _in "opt"
              qui mac def lambda=%_1
              mac shift
              qui mac def _hi=%_1
              mac shift
              qui mac def _plus=%_1
              mac shift
        parse "%_*"
        parse "%_varlist", parse(" ")
              mac def _lhs "%_1"
              mac shift
              mac def _rhs "%_*"
              qui gen logdv=log(%_lhs)
              qui summarize logdv %_if %_in
              qui mac def _num=_result(1)
              qui mac def _K2 = exp(_result(3))
di "lambda" _sk(10) "SSE" _sk(5) "Log-likelihood"
while %lambda<%_hi+.01 {
         if %lambda==0 {
              qui gen double ylambda=%_K2*logdv
         }
         else {
qui gen double ylambda=((%_lhs^%lambda)-1)/(%lambda*(%_K2^(%lambda-1)))
         }
         qui reg ylambda %_rhs %_if %_in
         qui mac def _RSS=_result(4)
         qui mac def _lnRSS=log(%_RSS)
         mac def _LL=-(%_num/2)*%_lnRSS
    if %lambda<0 {
di %4.2f %lambda _sk(5) %10.2f _result(4) _sk(5) %10.4f %_LL
}
    else {
di _sk(1) %4.2f %lambda _sk(5) %10.2f _result(4) _sk(5) %10.4f %_LL
}
    drop ylambda
    mac def lambda=%lambda+%_plus
}
drop logdv
end
