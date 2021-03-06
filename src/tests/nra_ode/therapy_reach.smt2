(set-logic QF_NRA_ODE)
(declare-fun tau () Real)
(declare-fun TA_d () Real)
(declare-fun TA () Real)
(declare-fun SP_d () Real)
(declare-fun SP () Real)
(declare-fun SC_d () Real)
(declare-fun SC () Real)
(declare-fun GC () Real)
(declare-fun GA_d () Real)
(declare-fun GA () Real)
(declare-fun CC_d () Real)
(declare-fun CC () Real)
(declare-fun tau_0_0 () Real)
(declare-fun tau_0_t () Real)
(declare-fun TA_d_0_0 () Real)
(declare-fun TA_d_0_t () Real)
(declare-fun TA_0_0 () Real)
(declare-fun TA_0_t () Real)
(declare-fun SP_d_0_0 () Real)
(declare-fun SP_d_0_t () Real)
(declare-fun SP_0_0 () Real)
(declare-fun SP_0_t () Real)
(declare-fun SC_d_0_0 () Real)
(declare-fun SC_d_0_t () Real)
(declare-fun SC_0_0 () Real)
(declare-fun SC_0_t () Real)
(declare-fun GC_0_0 () Real)
(declare-fun GC_0_t () Real)
(declare-fun GA_d_0_0 () Real)
(declare-fun GA_d_0_t () Real)
(declare-fun GA_0_0 () Real)
(declare-fun GA_0_t () Real)
(declare-fun CC_d_0_0 () Real)
(declare-fun CC_d_0_t () Real)
(declare-fun CC_0_0 () Real)
(declare-fun CC_0_t () Real)
(declare-fun time_0 () Real)
(declare-fun mode_0 () Real)
(define-ode flow_1 ((= d/dt[CC] (- (* 0.1112 GC) (* 0.0714286 CC))) (= d/dt[CC_d] (- (* 0.278 SP_d) (* 0.285714 CC_d))) (= d/dt[GA] (- (- (- (* (+ 0.1383 (* 2 0.01729)) TA) (* 1e-06 GA)) (* 0.2161 GA)) (* 0.00026 GA))) (= d/dt[GA_d] (- (- (- (* (+ 0.5532 (* 2 0.06916)) TA_d) (* 1e-06 GA_d)) (* 1.0805 GA_d)) (* 0.0003785 GA_d))) (= d/dt[GC] (- (- (* 0.0556 SP) (* 0.1112 GC)) (* 0.000133 GC))) (= d/dt[SC] (+ (- (- (* (* (/ (* 0.0033 100) (+ 1 (* (- 100 1) (^ (/ (+ TA TA_d) 560.931) 3)))) (- 1 (/ (+ SC (* 0.285714 SC_d)) 225))) SC) (* 1.97e-06 SC)) (* (/ (* 0.00164 100) (+ 1 (* (- 100 1) (^ (/ (+ TA TA_d) 560.931) 3)))) SC)) (* 1e-06 TA))) (= d/dt[SC_d] (+ (- (- (- (* (* 0.0132 (- 1 (/ (+ SC SC_d) 787.5))) SC_d) (* 2.296e-06 SC_d)) (* 0.00656 SC_d)) (/ (* 0.3 (^ SC_d 2)) (+ (^ 19 2) (^ SC_d 2)))) (* 1e-06 TA_d))) (= d/dt[SP] (- (- (* 0.2161 GA) (* 0.0556 SP)) (* 6.68e-05 SP))) (= d/dt[SP_d] (- (- (* 1.0805 GA_d) (* 0.278 SP_d)) (* 9.75e-05 SP_d))) (= d/dt[TA] (- (- (- (+ (+ (+ (* (/ (* 0.0131 100) (+ 1 (* (- 100 1) (^ (/ (+ TA TA_d) 560.931) 3)))) SC) (* (/ (* (* 2 0.00164) 100) (+ 1 (* (- 100 1) (^ (/ (+ TA TA_d) 560.931) 3)))) SC)) (* 0.014 TA)) (* 1e-06 GA)) (* 2.08e-05 TA)) (* 0.01729 TA)) (* 1e-06 TA))) (= d/dt[TA_d] (- (- (- (+ (+ (+ (* 0.0524 SC_d) (* (* 2 0.00656) SC_d)) (* 0.056 TA_d)) (* 1e-06 GA_d)) (* 2.42e-05 TA_d)) (* 0.06916 TA_d)) (* 1e-06 TA_d))) (= d/dt[tau] 1)))
(assert (<= 0 tau_0_0))
(assert (<= tau_0_0 10000))
(assert (<= 0 tau_0_t))
(assert (<= tau_0_t 10000))
(assert (<= 0 TA_d_0_0))
(assert (<= TA_d_0_0 100000))
(assert (<= 0 TA_d_0_t))
(assert (<= TA_d_0_t 100000))
(assert (<= 0 TA_0_0))
(assert (<= TA_0_0 100000))
(assert (<= 0 TA_0_t))
(assert (<= TA_0_t 100000))
(assert (<= 0 SP_d_0_0))
(assert (<= SP_d_0_0 100000))
(assert (<= 0 SP_d_0_t))
(assert (<= SP_d_0_t 100000))
(assert (<= 0 SP_0_0))
(assert (<= SP_0_0 100000))
(assert (<= 0 SP_0_t))
(assert (<= SP_0_t 100000))
(assert (<= 0 SC_d_0_0))
(assert (<= SC_d_0_0 100000))
(assert (<= 0 SC_d_0_t))
(assert (<= SC_d_0_t 100000))
(assert (<= 0 SC_0_0))
(assert (<= SC_0_0 100000))
(assert (<= 0 SC_0_t))
(assert (<= SC_0_t 100000))
(assert (<= 0 GC_0_0))
(assert (<= GC_0_0 100000))
(assert (<= 0 GC_0_t))
(assert (<= GC_0_t 100000))
(assert (<= 0 GA_d_0_0))
(assert (<= GA_d_0_0 100000))
(assert (<= 0 GA_d_0_t))
(assert (<= GA_d_0_t 100000))
(assert (<= 0 GA_0_0))
(assert (<= GA_0_0 100000))
(assert (<= 0 GA_0_t))
(assert (<= GA_0_t 100000))
(assert (<= 0 CC_d_0_0))
(assert (<= CC_d_0_0 100000))
(assert (<= 0 CC_d_0_t))
(assert (<= CC_d_0_t 100000))
(assert (<= 0 CC_0_0))
(assert (<= CC_0_0 100000))
(assert (<= 0 CC_0_t))
(assert (<= CC_0_t 100000))
(assert (<= 0 time_0 [0.000000]))
(assert (<= time_0 10000 [0.000000]))
(assert (<= 1 mode_0))
(assert (<= mode_0 1))
(assert (and (and (= CC_d_0_0 0) (= SP_d_0_0 0) (= GA_d_0_0 0) (= TA_d_0_0 0) (= SC_d_0_0 200) (= CC_0_0 0) (= GC_0_0 0) (= SP_0_0 0) (= GA_0_0 0) (= TA_0_0 0) (= SC_0_0 20) (= tau_0_0 0)) (= mode_0 1) (= [CC_0_t CC_d_0_t GA_0_t GA_d_0_t GC_0_t SC_0_t SC_d_0_t SP_0_t SP_d_0_t TA_0_t TA_d_0_t tau_0_t] (integral 0. time_0 [CC_0_0 CC_d_0_0 GA_0_0 GA_d_0_0 GC_0_0 SC_0_0 SC_d_0_0 SP_0_0 SP_d_0_0 TA_0_0 TA_d_0_0 tau_0_0] flow_1)) (= mode_0 1) (= mode_0 1) (= tau_0_t 2000)))
(check-sat)
(exit)
