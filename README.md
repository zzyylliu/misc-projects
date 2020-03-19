# Visualizing the Trends in London Bike Sharing
> 伦敦市共享单车：数据可视化项目报告

### Introduction
> 项目介绍

Bike sharing is a service in which bikes are made available for shared use to individuals on a short term basis for a price or free. In this project, we acquired a dataset on bike-sharing activities that provides information on the hourly number of bike shares in London, across a two-year period, from 1/1/2015 to 1/3/2017. Each entry of hourly record of bike shares is accompanied by information on weather conditions and the occasion (if it was holiday or not, if it was weekend or not) at that specific time. Therefore, in this project, we used scheme to write a program to explore the patterns of bike sharing under different conditions of weather and occasion, by creating sub-categories of data and visualizing the dataset thereafter. 

> 自行车共享是一项服务，自行车可以短期出租给个人并收取相应费用或免费使用。在此项目中，我们获取了有关共享自行车活动的数据集，该数据集提供了从2015年
1月1日到2017年1/3/2两年期间伦敦每小时的自行车共享数量。每小时记录一次自行车共享记录时，都同时记录了有关天气状况和特定场景（是否假期，是否周末）的信息。在这个项目中，我们用scheme编写了一系列程序，实现数据清洗、创建数据子集、和数据可视化，探索不同天气和场合下自行车共享的规律。

### Data Background and Cleaning
> 数据背景及清洗

The dataset we employed in this project is directly downloaded from the kaggle website: https://www.kaggle.com/hmavrodiev/london-bike-sharing-dataset, which is originally acquired from 3 sources: 1) https://cycling.data.tfl.gov.uk/ (for biking data); 2) freemeteo.com (for weather data); 3) https://www.gov.uk/bank (for holidays data). This dataset is grouped by hour, so that we have information on the hourly new bike shares occurred, along with the timestamp and other factors grouped by hour. This dataset encompasses a two year period from 1/1/2015 to 1/3/2017. There are in total 17414 observations. In order to balance the dataset, we dropped the observations from 2017, using a procedure called `not-2017?` leaving us with a total of 17342 observations. 
> 我们在此项目中使用的数据集可直接从kaggle网站下载：https://www.kaggle.com/hmavrodiev/london-bike-sharing-dataset 。该数据集最初是从3个来源获得的：1）https://cycling.data.tfl.gov.uk/ （用于自行车数据）；2）https://freemeteo.com （用于天气数据）；3）https://www.gov.uk/bank （用于节假日数据）。该数据集按小时分组，因此我们可以获得有关每小时发生的新单车份额的信息，以及按小时分组的时间戳和其他因素。此数据集涵盖从1/1/2015到1/3/2017的两年时间。总共有17414个观测值。为了平衡数据集，我们用`not-2017?`这个程序删除了2017年以来的观测值，总共剩下17342个观测值。

```scheme
;Cleaning
(define not-2017?
  (lambda (str)
    (not (equal? (string-ref str 3) #\7))))
;The original data is taken from 2015 Janurary to 2017 Janurary, we are dropping the data from 2017
```
Each entry in the dataset is a list of the form ‘(timestamp  cnt  t1  t2  hum  wind-speed  weather-code  is-holiday  is-weekend  season). Below is a table of details on these variables. 
> 数据集中的每个条目都是以下列形式排列：'(时间戳  单车数  实际温度  体感温度  湿度  风速  天气代码  是否节假日  是否周末  季节）。下表是这些变量的详细信息。

Table 1. Data description(数据说明）
| **variable name** | **variable description**                  | **type**                       | **min** | **max** |
| ----------------- | ----------------------------------------- | ------------------------------ | ------- | ------- |
| timestamp         | timestamp grouped by hour                 | string                         | NA      | NA      |
| cnt               | the count of a new bike shares            | number                         | 0       | 7860    |
| t1                | real temperature in Celsius               | number                         | -1.5    | 34.0    |
| t2                | temperature in Celcius "feels like"       | number                         | -6.0    | 34.0    |
| hum               | humidity in percentage                    | number                         | 20.5    | 100.0   |
| wind-speed        | wind speed in km/h                        | number                         | 0.0     | 56.5    |
| weather-code      | category of the weather                   | category represented by number | 1       | 26      |
| is-holiday        | boolean: 0 for non-holiday, 1 for holiday | boolean                        | 0       | 1       |
| is-weekend        | boolean: 0 for non-weekend, 1 for weekend | boolean                        | 0       | 1       |
| season            | category of seasons                       | category represented by number | 0       | 3       |

To better understand the trend and patterns, we split the original dataset into subcategories and examined the differences between these subcategories of data. We created subcategories based on timestamp using the following procedures, such that we categorized the data into morning rush, evening rush, day-time, night and mid-night. 
> 为了更好地理解单车共享模式，我们将原始数据集分类并检查了他们之间的差异。我们用一系列程序根据时间戳创建了数据子集，将数据分类为早高峰，晚高峰，白天，夜晚和深夜。

```scheme
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
```
By a similar approach, we defined a few `predicates` to help us create subcategories based on season, is-holiday and is-weekend. 
> 通过类似的方法，我们用下面这些`predicates`创建了其他子集比如季节、假日和周末。

```scheme
;predicate?
(define spring? (lambda (lst) (= (list-ref lst 9) 0)))
(define summer? (lambda (lst) (= (list-ref lst 9) 1)))
(define fall? (lambda (lst) (= (list-ref lst 9) 2)))
(define winter? (lambda (lst) (= (list-ref lst 9) 3)))
(define is-holiday? (lambda (lst) (= (list-ref lst 7) 1)))
(define not-holiday? (lambda (lst) (= (list-ref lst 7) 0)))
(define is-weekend? (lambda (lst) (= (list-ref lst 8) 1)))
(define not-weekend? (lambda (lst) (= (list-ref lst 8) 0)))
;We are defining all predicates for future filtering.
```
After defining the predicates, we wrote a procedure called `describe-cnt-mean-min-max` to see the mean, minimum, and maximum of cnt for each subcategories of data, which is used to calculate the values in Table 2. 
> 接着我们对分类后的数据进行初步分析，通过下面的`describe-cnt-mean-min-max`得到不同子集下的单车计数平均值、最小值和最大值，表2展示这些信息。

```scheme
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
```
Table 2. Sub-categories of data(数据子集)
| **category base**    | **sub-categories**   | **mean of cnt** | **min of cnt** | **max of cnt** |
| -------------------- | -------------------- | --------------- | -------------- | -------------- |
| timestamp            | morning-traffic-bike | 1621.124        | 21             | 7531           |
|                      | evening-traffic-bike | 2376.428        | 195            | 7860           |
|                      | day-time-bike        | 1440.608        | 150            | 6033           |
|                      | night-bike           | 710.854         | 82             | 3156           |
|                      | midnight-bike        | 150.959         | 0              | 982            | 
| is-holiday           | is-holiday?          | 787.986         | 14             | 3100           |
|                      | not-holiday?         | 1153.257        | 0              | 7860           |
| is-weekend           | is-weekend?          | 980.860         | 0              | 4341           |
|                      | not-weekend?         | 1211.436        | 9              | 7860           |
| season               | spring               | 1103.832        | 0              | 5322           |
|                      | summer               | 1464.465        | 12             | 7860           |
|                      | fall                 | 1178.954        | 9              | 5422           |
|                      | winter               | 826.775         | 12             | 4415           |

From the table above, we can see that the sub-category with the highest mean of cnt is “evening-traffic-bike” under the timestamp subcategories. The mean of cnt during holidays and weekends is lower than the mean of cnt outside of holidays and weekends, with holidays having the slightly lower mean of cnt than weekends do. For the four seasonal subcategories, all but winter has an exceptionally low mean of cnt. 
> 从上表中可以看出，在时间戳子类别下，cnt(单车共享数量）平均值最高的子集是晚高峰时段。假日和周末期间的cnt平均值低于假日和周末之外的cnt平均值，而假日的cnt平均值则比周末略低。四个季节子类别中，冬季在所有季节中的cnt均值均极低。

### Data Visualization
> 数据可视化

After cleaning and categorizing the dataset, we can begin with the main task of this project, data visualization. In this project, we are plotting both two-dimensional and three-dimensional graphs to see the pattern in London bike sharing. As a result, we are writing similar procedures for 2-d and 3-d data visualization respectively. We first write a procedure `2d-vars` or `3d-vars` (for 2-d and 3-d respectively) to extract the variables we want from the dataset and merge them into a new list. Based on this new list, we extract all the values of the second and third variables grouped under the same value of the first variable. Then we calculate the mean of the grouped values of the second or third variables, so that they correspond with each value of the first variable by the recursive procedure `2d-vars-mean` and `3d-vars-mean`. 

> 在对数据集进行清理和分类之后，我们可以开始本项目的主要任务，即数据可视化。在此项目中，我们绘制了二维和三维图，以理解伦敦市共享单车模式。因此，我们针对二维和三维数据可视化所撰写的程序具有一定相似性。首先，我们通过程序`2d-vars`或`3d-vars`（分别用于二维和三维），将从大数据集中提取的变量合并为一个新列表。基于此新列表，我们提取第一变量所有相同值下的第二或第三变量的所有值。然后，通过递归程序`2d-vars-mean`和`3d-vars-mean`产生一个新列表，展示第一变量/第二变量对应的第二变量或第三变量的平均值。

```scheme
;2d-vars
(define 2d-vars
  (lambda (var1 var2)
    (map list var1 var2)))

;2d-vars-mean
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
```

With the help of the above procedures, we can now plot 2-d and 3-d graphs with procedures `plot2d-vars-mean` and `plot3d-vars-mean`. Notice that in these two procedures, one can change the input file to control the subcategories of the dataset and make use of all the predicates we defined above. 
> 借助上面这些程序，我们现在可以使用`plot2d-vars-mean`和`plot3d-vars-mean`绘制2-d和3-d图。值得一提的是，这里可以使用在数据清理阶段定义的`predicates`来控制输入的数据子集，达到数据分类、对比的可视化效果。

```scheme
;;;Procedure
;;; plot2d-vars-mean
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
(define plot-var1-var2-mean
  (lambda (str1 str2 lst)
    (let ([var1 (map (section list-ref <> (index-of str1 first-row)) lst)]
          [var2 (map (section list-ref <> (index-of str2 first-row)) lst)])
      (plot (points (2d-vars-mean var1 var2) #:sym 'fullcircle1
                    #:x-min (reduce min var1)
                    #:x-max (reduce max var1)
                    #:y-min (reduce min var2)
                    #:y-max (reduce max var2))
            #:title (string-append str1 " vs " str2)
            #:x-label str1
            #:y-label str2))))

;plot3d-vars-mean
(define plot3d-vars-mean
  (lambda (str1 str2 str3 lst)
    (let ([var1 (map (section list-ref <> (index-of str1 first-row)) lst)]
          [var2 (map (section list-ref <> (index-of str2 first-row)) lst)]
          [var3 (map (section list-ref <> (index-of str3 first-row)) lst)])
      (plot3d (points3d (3d-vars-mean var1 var2 var3) #:sym 'fullcircle1
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
```
At last, there are also patterns that are best visualized by histograms, so we wrote `sorted-2d-hist` and `sorted-3d-hist` to do this for us. Just like the way we defined `plot2d` and `plot3d`, here one can also control the input file with `predicates` defined earlier. 
> 最后，还有一些适合通过柱状图可视化的数据关系，我们有`sorted-2d-hist`和`sorted-3d-hist`来做这件事。就像我们定义`plot2d`和`plot3d`的方式一样，这里也可以使用前面定义的`predicates`来控制输入数据，对比子集之间的差异。

```scheme
;sorted-2d-hist
(define sorted-2d-hist
  (lambda (str1 str2 lst)
    (let ([var1 (map (section list-ref <> (index-of str1 mod-first-row)) lst)]
          [var2 (map (section list-ref <> (index-of str2 mod-first-row)) lst)])
      (let ([sort-by-key (lambda (pair1 pair2)
                           (if (< (car pair1) (car pair2))
                               #t
                               #f))])
        (let ([pairs (sort (2d-vars-mean var1 var2) sort-by-key)])
          (plot (discrete-histogram pairs)))))))

;sorted-3d-hist
(define sorted-3d-hist
  (lambda (str1 str2 str3 lst)
    (let ([var1 (map (section list-ref <> (index-of str1 mod-first-row)) lst)]
          [var2 (map (section list-ref <> (index-of str2 mod-first-row)) lst)]
          [var3 (map (section list-ref <> (index-of str3 mod-first-row)) lst)])
      (let ([sort-by-key (lambda (triple1 triple2)
                           (cond
                             [(> (car triple1) (car triple2)) #f]
                             [(> (cadr triple1) (cadr triple2)) #f]
                             [else #t]))])
        (let ([triples (sort (3d-vars-mean var1 var2 var3) sort-by-key)])
          (plot3d (discrete-histogram3d triples)))))))
```

### Outcome and Analysis 
> 结果与分析

From implementing the above procedures, we have found some noteworthy patterns in London bike sharing. 
First, bike sharing distributes unevenly over the day on an hourly basis. Some noticeable spikes are from 7am to 9am, namely the morning-traffic period, and from 5pm to 7pm, the evening-traffic period. On average, cnt is higher during the morning traffic period than in the evening. 
> 借助上面这些程序，我们发现了一些伦敦自行车共享中值得注意的规律。
首先，单车共享数量在一天中分布不均。明显的高峰是从早上7点到早上9点（即早高峰时段）和从下午5点到晚上7点（晚高峰时段）。平均而言，早高峰时段的CNT（共享单车数量）高于晚高峰时段。

<img src="https://github.com/zzyylliu/misc-projects/blob/master/images%26dataset/images/hour-cnt.png" height="500">

Second, occasions like weekends and holiday has an lowering effect on cnt, the number of bike sharing. 
> 其次，周末和节假日这类场景中对单车共享数CNT会影响降低。

<img src="https://github.com/zzyylliu/misc-projects/blob/master/images%26dataset/images/holiday-cnt.png" height="500">

Combining the two correlations above, the following graph shows that people rent bikes differently with respect to time, under the effect of holidays. Naturally, morning-traffic and evening-traffic disappears on holidays, instead, the bike sharing count reaches its peak at around noon of the day. 
> 结合以上两个相关性，下图显示，在假期的影响下，人们在租车方面的时间有所不同。节假日期间早高峰和晚高峰的自然都会消失，取而代之的是，单车共享次数会在一天中午左右达到最高点。

<img src="https://github.com/zzyylliu/misc-projects/blob/master/images%26dataset/images/holiday-hour-cnt**.png" height="500">

Now, temperature also has a clear impact on cnt. As temperature goes up above 10 degree Celsius, cnt spikes up and remains this positive correlation with temperature up to nearly 30 degree Celsius. Then the increase in cnt slows down a bit, even starts to decrease from looking at the data we have. This graph below indicates that we should look at the effect of temperature on cnt by different temperature intervals. 
> 温度对cnt也有明显的影响。当温度升至10摄氏度以上时，cnt会飙升，在一直与温度保持正相关直到30摄氏度左右。然后，cnt的增加减缓，从我们拥有的数据中来看，cnt甚至会开始下降。由此可见，我们应该按不同的温度区间来看待温度对CNT的影响。

<img src="https://github.com/zzyylliu/misc-projects/blob/master/images%26dataset/images/t2-cnt.png" height="500">

As we try to combine effects of temperature and time on cnt, we found that in months of higher average temperatures like July and August, the comparison(from the first graph above, hour versus cnt) we made between morning and evening traffic period are reversed. As time moves into summer, temperature rises and the bike sharing count during evening-traffic period climbs and reaches its peak in July and August, exceeding the numbers during morning-traffic period. 
> 当我们尝试结合温度和时间对cnt的影响时，我们发现在平均气温较高的月份（例如7月和8月）中，早高峰和晚高峰的差异（见第一张图表：Hour vs CNT）被颠倒了。随着时间的流逝，夏季气温升高，晚上出行期间的自行车共享数量攀升，并在7月和8月达到高峰，超过了早高峰时段的共享单车数量。

<img src="https://github.com/zzyylliu/misc-projects/blob/master/images%26dataset/images/month:t-hour-cnt*.png" height="500">

Finally, we have found that, as temperature increases to around 15 degree Celsius, the number of bikes rented on holidays exceeds that on regular days. This, however, may have been caused not only by the fact of increases in temperature, but also from other factors outside of the dataset we have, such as visitors from outside of London spending their holiday in the city and renting bikes as they go around.
> 最后，我们发现，随着温度升高到15摄氏度左右，节假日租用的自行车数量超过了平日。但是，这可能不仅是由于温度升高而造成的，还可能是由于现有数据之外的其他因素引起的，例如外地游客在假期来到伦敦度假，并在出行时租用自行车而使得假期CNT上升。

<img src="https://github.com/zzyylliu/misc-projects/blob/master/images%26dataset/images/holiday-t2-cnt**.png" height="500">

There are still a lot about this project one could do and add to. Feel free to leave comments and contributing to this project. You can find the original code used in this project under this repository. 
> 最后的最后，这个项目还有很大的改进和提升空间，欢迎任何人随时评论和为这个项目做贡献。您可以在本仓库中找到此项目使用的原始代码。

