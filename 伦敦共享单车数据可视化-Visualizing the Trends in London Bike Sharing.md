# Visualizing the Trends in London Bike Sharing
> 伦敦市共享单车：数据可视化项目报告

### Introduction
> 项目介绍

Bike sharing is a service in which bikes are made available for shared use to individuals on a short term basis for a price or free. In this project, we acquired a dataset on bike-sharing activities that provides information on the hourly number of bike shares in London, across a two-year period, from 1/1/2015 to 1/3/2017. Each entry of hourly record of bike shares is accompanied by information on weather conditions and the occasion (if it was holiday or not, if it was weekend or not) at that specific time. Therefore, in this project, we wrote a program to explore the patterns of bike sharing under different conditions of weather and occasion, by creating sub-categories of data and visualizing the dataset thereafter. 

> 自行车共享是一项服务，自行车可以短期出租给个人并收取相应费用或免费使用。在此项目中，我们获取了有关共享自行车活动的数据集，该数据集提供了从2015年
1月1日到2017年1/3/2两年期间伦敦每小时的自行车份额信息。每小时记录一次自行车共享记录时，都同时记录了有关天气状况和特定时间（无论是否是假期，是否是周末）的信息。因此，在这个项目中，我们编写了一个程序，通过创建数据子类别并随后可视化数据集来探索不同天气和场合下自行车共享的模式。

### Data
> 数据背景

The dataset we employed in this project is directly downloaded from the kaggle website: https://www.kaggle.com/hmavrodiev/london-bike-sharing-dataset, which is originally acquired from 3 sources: 1) https://cycling.data.tfl.gov.uk/ (for biking data); 2) freemeteo.com (for weather data); 3) https://www.gov.uk/bank (for holidays data). This dataset is grouped by hour, so that we have information on the hourly new bike shares occurred, along with the timestamp and other factors grouped by hour. This dataset encompasses a two year period from 1/1/2015 to 1/3/2017. There are in total 17414 observations. In order to balance the dataset, we dropped the observations from 2017, leaving us with a total of 17342 observations. Each entry in the dataset is a list of the form ‘(timestamp  cnt  t1  t2  hum  wind-speed  weather-code  is-holiday  is-weekend  season). 
> 我们在此项目中使用的数据集可直接从kaggle网站下载：https://www.kaggle.com/hmavrodiev/london-bike-sharing-dataset 。该数据集最初是从3个来源获得的：1）https://cycling.data.tfl.gov.uk/ （用于自行车数据）；2）https://freemeteo.com （用于天气数据）；3）https://www.gov.uk/bank （用于节假日数据）。该数据集按小时分组，因此我们可以获得有关每小时发生的新单车份额的信息，以及按小时分组的时间戳和其他因素。此数据集涵盖从1/1/2015到1/3/2017的两年时间。总共有17414个观测值。为了平衡数据集，我们删除了2017年以来的观测值，总共剩下17342个观测值。数据集中的每个条目都是以下列形式排列：'(时间戳  单车数  实际温度  体感温度  湿度  风速  天气代码  是否节假日  是否周末  季节）。下表是这些变量的详细信息。

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

To better understand the trend and patterns, we split the original dataset into subcategories and examined the differences between these subcategories of data. We created subcategories based on timestamp such that we categorized the data into morning rush, evening rush, day-time, night and mid-night. By a similar approach, we also created subcategories based on season, is-holiday and is-weekend.
> 为了更好地了解趋势和模式，我们将原始数据集划分为子类别并检查了这些数据子类别之间的差异。我们根据时间戳创建了子类别，将数据分类为早高峰，晚高峰，白天，黑夜和深夜。通过类似的方法，我们还创建了其他子类别比如季节、假日和周末。

### Algorithm and Implementation
> 算法与实现

The first procedure written is called `not-2017?`, which is to clean the dataset by dropping all data in 2017. 
> 在正式开始之前，我们首先编写一段程序对数据进行清洗，以删除2017年的三天数据。

```
;Cleaning
(define not-2017?
  (lambda (str)
    (not (equal? (string-ref str 3) #\7))))
;The original data is taken from 2015 Janurary to 2017 Janurary, we are dropping the data from 2017
```
We then defined a few `predicates` based on season, is-holiday and is-weekend, to help us filter the data as we try to create subcategories. 
> 接着我们定义如下判断条件来对数据进行分组，创建数据子类别。

```
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
We use a special procedure to make time sub-categories of data, namely morning-traffic-bike, evening-traffic-bike, day-time-bike, night-bike, and midnight-bike. 

After defining the predicates, we wrote a procedure called `describe-cnt-mean-min-max` to see the mean, minimum, and maximum of cnt for each subcategories of data, which is used to calculate the values in Table 2. 
> 接着我们对分类后的数据进行初步分析，通过下面的`describe-cnt-mean-min-max`得到不同子类别下的单车计数平均值、最小值和最大值，表2展示这些信息。

```
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
Table 2. Sub-categories of data(数据子类别)
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

Then we wrote var1-var2 to create a list of pairs, where all values of var1 and var2 are paired. Then We built a recursive procedure to show the mean values of var2 related to each value of var1. Next, we created filtered-var1-var2-mean where we added parameter "lst". By doing this, we could change the input file. So far, we could plot the scatterplots to see the correlations simply by changing the input strings and files.

There were also correlations that we wanted to visualize by seeing histograms, so we built hist-var1-var2-mean which works just like the scatter-plot procedure that we could change the input strings and files to see the correlations between two variables. Specially, we wanted to see the correlation between average counts and the 5 time categories, so we built a recursive procedure tally-cnt to count the total number of bike rentals under each time category and dividing the numbers by the length of different files to get the average counts. Then we could plot the histograms by listing 5 pairs. 





<img src=" " height="300">




