;The following code is written in scheme, which needs to be ran in a scheme environment like Dr.Racket.
;以下代码使用scheme语言编写，需要在相应环境下运行，例如Dr.Racket。


#lang racket
(require csc151)
(require plot)

#|
Variable names and descrptions:
"timestamp" - timestamp field for grouping the data
"cnt" - the count of a new bike shares
"t1" - real temperature in C
"t2" - temperature in C "feels like"
"hum" - humidity in percentage
"wind_speed" - wind speed in km/h
"weather_code" - category of the weather
"is_holiday" - boolean field - 1 holiday / 0 non holiday
"is_weekend" - boolean field - 1 if the day is weekend
"season" - category field meteorological seasons: 0-spring ; 1-summer; 2-fall; 3-winter.
|#


;Cleaning
(define not-2017?
  (lambda (str)
    (not (equal? (string-ref str 3) #\7))));Our data cover from 2015 Janurary to 2017 Janurary, so we are dropping the one-month data from 2017
(define bike0 (drop (read-csv-file "/Users/london_bike_dataset.csv") 1)) ;remember to change the file path to implement this program, 请更换这里的文件地址
(define bike1 (filter (o (section not-2017? <>) car) bike0))


;first-row
(define first-row (list "timestamp" "month" "hour" "cnt" "t1" "t2" "hum" "wind-speed" "weather-code" "is-holiday" "is-weekend" "season"))
       
;variables
(define timestamp (map car bike1))
(define month (map string->number (map (section substring <> 5 7) (map car bike1))))
(define hour (map string->number (map (section substring <> 11 13) (map car bike1))))
(define is-holiday (map (section list-ref <> 7) bike1))
(define is-weekend (map (section list-ref <> 8) bike1))
(define season (map (section list-ref <> 9) bike1))
(define weather-code (map (section list-ref <> 6) bike1))
(define hum (map (section list-ref <> 4) bike1))
(define wind-speed (map (section list-ref <> 5) bike1))
(define t1 (map (section list-ref <> 2) bike1))
(define t2 (map (section list-ref <> 3) bike1))
(define cnt (map cadr bike1))
;We are defining all variables here in order to make the following procedures easier. 

;cleaned dataset
(define bike (map list timestamp month hour cnt t1 t2 hum wind-speed weather-code is-holiday is-weekend season))

;predicate?
(define spring? (lambda (lst) (= (list-ref lst 11) 0)))
(define summer? (lambda (lst) (= (list-ref lst 11) 1)))
(define fall? (lambda (lst) (= (list-ref lst 11) 2)))
(define winter? (lambda (lst) (= (list-ref lst 11) 3)))
(define is-holiday? (lambda (lst) (= (list-ref lst 9) 1)))
(define not-holiday? (lambda (lst) (= (list-ref lst 9) 0)))
(define is-weekend? (lambda (lst) (= (list-ref lst 10) 1)))
(define not-weekend? (lambda (lst) (= (list-ref lst 10) 0)))
;We are defining all predicates for future filterings.

;filter-by-month
(define filter-by-month
  (lambda (num lst)
    (filter (o (section = <> num) cadr) lst)))

;;;Procedure
;;; describe-cnt-mean-min-max
;;;Parameters
;;; lst, a list
;;;Purpose
;;; take a list and produce the mean, min and max of cnt for that list
;;;Produces
;;; cnt-description, a list of numbers
;;;Preconditions
;;; lst a subset of the dataset bike
;;;Postconditions
;;; (car cnt-description) is the mean of cnt for lst
;;; (cadr cnt-description) is the min of cnt for lst
;;; (caddr cnt-description) is the max of cnt for lst
(define describe-cnt-mean-min-max
  (lambda (lst)
    (let ([cnt (map cadr lst)])
      (map exact->inexact (list (/ (reduce + cnt) (length cnt)) (reduce min cnt) (reduce max cnt))))))

;time categories
;;;Procedure
;;; time-categories
;;;Parameters
;;; lst, a single list
;;;Purpose
;;; to output a string of the time category of lst  
;;;Produces
;;; str, a string 
;;;Preconditions
;;; lst is in the form of a small list in bike, where the first element is a string of time 
;;;Postconditions
;;; if hour (which we defined by let) is in [6, 10), str is "morning traffic"
;;; if hour is in [17, 20), str is "evening traffic"
;;; if hour is in [20, 23], str is "evening"
;;; if hour is in [0, 6), str is "night and early morning"
;;; else, str is "regular time"
(define time-categories
  (lambda (lst)
    (let ([hour (string->number (substring (list-ref lst 0) 11 13))])
      (cond [(and (>= hour 6) (< hour 10)) "morning traffic"]
            [(and (>= hour 17) (< hour 20)) "evening traffic"]
            [(and (>= hour 20) (<= hour 23)) "evening"]
            [(and (>= hour 0) (< hour 6)) "night and early morning"]
            [else "regular time"]))))

;;;Procedure
;;; filter-time 
;;;Parameters
;;; fname, a list of lists (or a file)
;;; str, a string 
;;;Purpose
;;; to output a new dataset which contains lists under "str" category 
;;;Produces
;;; new-fname, a new list of lists 
;;;Preconditions
;;; fname is in the form of bike, a list of lists and each small list has equal length. 
;;; str, an output from (time-categories lst)
;;;Postconditions
;;; new-fname is a list contains lists under "str" category  
(define filter-time
  (lambda (fname str)
    (if (null? fname) null
        (if (equal? (time-categories (car fname)) str) (cons (car fname) (filter-time (cdr fname) str))
            (filter-time (cdr fname) str)))))

(define morning-traffic-bike (filter-time bike "morning traffic"))
(define evening-traffic-bike (filter-time bike "evening traffic"))
(define night-bike (filter-time bike "evening"))
(define day-time-bike (filter-time bike "regular time"))
(define midnight-bike (filter-time bike "night and early morning"))
;We filter bike using filter-time to devide bike into 5 groups.


;var1-var2
;;;Procedure
;;; var1-var2
;;;Parameters
;;; var1, a defined variable
;;; var2, a defined variable
;;;Purpose
;;; to output a list of lists, each small list contains two elements
;;;Produces
;;; lst, a list of lists, each small list contains one value under var1 and one value under var2
;;;Preconditions
;;; var1 and var2 are defined above
;;;Postconditions
;;; [No addtional]
(define 2d-vars
  (lambda (var1 var2)
    (map list var1 var2)))

;var1-var2-mean
;;;Procedure
;;; var1-var2-mean
;;;Parameters
;;; var1, a defined variable
;;; var2, a defined variable
;;;Purpose
;;; to output a list of pairs
;;;Produces
;;; lst, a list of pairs. The first element of a pair is var1 and the 2nd element is the mean value of var2 under the certain var1
;;;Preconditions
;;; var1, var2 are variables we defined above
;;;Postconditions
;;; lst is a list of pairs, and each pair is in the form of (a value of var1, mean value of var2 under var1)
(define 2d-vars-mean
  (lambda (var1 var2)
    (let ([var1-val (map car (tally-all var1))])
      (let ([val1-var2 (lambda (val1) (filter (o (section = <> val1) car) (2d-vars var1 var2)))])
        (let ([val1-var2-mean (lambda (val1)
                                (list val1 (/ (reduce + (map cadr (val1-var2 val1))) (length (val1-var2 val1)))))])
          (let kernel ([lst var1-val])
            (cond
              [(null? lst) null]
              [else (cons (val1-var2-mean (car lst)) (kernel (cdr lst)))])))))))

;plot-var1-var2-mean
;;;Procedure
;;; plot-var1-var2-mean
;;;Parameters
;;; str1, a string
;;; str2, a string
;;; lst, a list (or a file)
;;;Purpose
;;; to output a scatter plot while x-axis represents str1 and y-aixs represents str2
;;;Produces
;;; plot, a scatter plot of correlation between str1 and str2
;;;Preconditions
;;; str1 and str2 are the strings contained in the first-row
;;; lst is in the form of bike, a list of lists and each small list has equal length. 
;;;Postconditions
;;; [No additional] 
(define plot2d-vars-mean
  (lambda (str1 str2 lst)
    (let ([var1 (map (section list-ref <> (index-of str1 first-row)) lst)]
          [var2 (map (section list-ref <> (index-of str2 first-row)) lst)])
      (plot (points (2d-vars-mean var1 var2)
                    #:sym 'fullcircle1
                    #:x-min (reduce min var1)
                    #:x-max (reduce max var1)
                    #:y-min (reduce min var2)
                    #:y-max (reduce max var2))
            #:title (string-append str1 " vs" str2)
            #:x-label str1
            #:y-label str2))))

;3d-vars
(define 3d-vars
  (lambda (var1 var2 var3)
    (map list var1 var2 var3)))

;3d-vars-mean
(define 3d-vars-mean
  (lambda (var1 var2 var3)
    (let ([vals-of-var1-var2 (map car (tally-all (map list var1 var2)))])
      (let ([vals-var3 (lambda (vals) (filter (o (section equal? <> vals) (section take <> 2)) (3d-vars var1 var2 var3)))])
        (let ([vals-var3-mean (lambda (vals)
                                (append vals (list (/ (reduce + (map caddr (vals-var3 vals))) (length (vals-var3 vals))))))])
          (let kernel ([lst vals-of-var1-var2])
            (cond
              [(null? lst) null]
              [else (cons (vals-var3-mean (car lst)) (kernel (cdr lst)))])))))))

;plot3d-vars-mean
(define plot3d-vars-mean
  (lambda (str1 str2 str3 lst)
    (let ([var1 (map (section list-ref <> (index-of str1 first-row)) lst)]
          [var2 (map (section list-ref <> (index-of str2 first-row)) lst)]
          [var3 (map (section list-ref <> (index-of str3 first-row)) lst)])
      (plot3d (points3d (3d-vars-mean var1 var2 var3)
                        #:sym 'fullcircle1
                        #:x-min (reduce min var1)
                        #:x-max (reduce max var1)
                        #:y-min (reduce min var2)
                        #:y-max (reduce max var2)
                        #:z-min (reduce min var3)	 
                        #:z-max (reduce max var3))
              #:title (string-append str1 " and " str2 " vs " str3)
              #:x-label str1
              #:y-label str2
              #:z-label str3
              #:altitude 10))))

;sorted-2d-hist
(define sorted-2d-hist
  (lambda (str1 str2 lst)
    (let ([var1 (map (section list-ref <> (index-of str1 first-row)) lst)]
          [var2 (map (section list-ref <> (index-of str2 first-row)) lst)])
      (let ([sort-by-key (lambda (pair1 pair2)
                           (if (< (car pair1) (car pair2))
                               #t
                               #f))])
        (let ([pairs (sort (2d-vars-mean var1 var2) sort-by-key)])
          (plot (discrete-histogram pairs)
                #:title (string-append str1 " vs " str2)
                  #:x-label str1
                  #:y-label str2))))))

;sorted-3d-hist
(define sorted-3d-hist
  (lambda (str1 str2 str3 lst)
    (let ([var1 (map (section list-ref <> (index-of str1 first-row)) lst)]
          [var2 (map (section list-ref <> (index-of str2 first-row)) lst)]
          [var3 (map (section list-ref <> (index-of str3 first-row)) lst)])
      (let ([sort-by-key (lambda (triple1 triple2)
                           (cond
                             [(> (car triple1) (car triple2)) #f]
                             [(> (cadr triple1) (cadr triple2)) #f]
                             [else #t]))])
        (let ([triples (sort (3d-vars-mean var1 var2 var3) sort-by-key)])
          (plot3d (discrete-histogram3d triples)
                  #:title (string-append str1 " and " str2 " vs " str3)
                  #:x-label str1
                  #:y-label str2
                  #:z-label str3))))))

;tally-cnt
(define tally-cnt
  (lambda (fname)
    (if (null? fname) 0
        (+ (list-ref (car fname) 1)
           (tally-cnt (cdr fname))))))

;avg-cnt
(define avg-cnt
  (lambda (fname)
    (/ (tally-cnt fname) (length fname))))

#|
Use the code below to plot the histogram for time-categories vs cnt.

(plot (discrete-histogram (list (list "morning-traffic" (avg-cnt morning-traffic-bike))
                          (list "evening-traffic" (avg-cnt evening-traffic-bike))
                          (list "night" (avg-cnt night-bike))
                          (list "day time" (avg-cnt day-time-bike))
                          (list "mid-night" (avg-cnt midnight-bike)))))

|#


