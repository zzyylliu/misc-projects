;The following code is written in scheme, which should be run in an environment such as Dr.Racket.
;以下代码使用scheme编写，需要在相应开发环境中运行，例如Dr.Racket。

;Introduction
;  Bike sharing is a service in which bikes are made available for shared use to individuals on a short term basis for a 
;  price or free. In this project, we acquired a dataset on bike-sharing activities that provides information on the hourly 
;  number of bike shares in London, across a two-year period, from 1/1/2015 to 1/3/2017. Each entry of hourly record of bike 
;  shares is accompanied by information on weather conditions and the occasion (if it was holiday or not, if it was weekend 
;  or not) at that specific time. Therefore, in this project, we wrote a program to explore the patterns of bike sharing under 
;  different conditions of weather and occasion, by creating sub-categories of data and visualizing the dataset thereafter. 

;介绍
; 自行车共享是一项服务，自行车可以短期出租给个人并收取相应费用或免费使用。在此项目中，我们获取了有关共享自行车活动的数据集，该数据集提供了从2015年
; 1月1日到2017年1/3/2两年期间伦敦每小时的自行车份额信息。每小时记录一次自行车共享记录时，都应附有有关天气状况和特定时间（无论是否是假期，是否是周末）
; 的信息。因此，在这个项目中，我们编写了一个程序，通过创建数据子类别并随后可视化数据集来探索不同天气和场合下自行车共享的模式。

;Data
;  The dataset we employed in this project is directly downloaded from the kaggle website: https://www.kaggle.com/hmavrodiev/
;  london-bike-sharing-dataset, which is originally acquired from 3 sources: 1) https://cycling.data.tfl.gov.uk/ (for biking 
;  data); 2) freemeteo.com (for weather data); 3) https://www.gov.uk/bank (for holidays data). This dataset is grouped by 
;  hour, so that we have information on the hourly new bike shares occurred, along with the timestamp and other factors 
;  grouped by hour. This dataset encompasses a two year period from 1/1/2015 to 1/3/2017. There are in total 17414 
;  observations. In order to balance the dataset, we dropped the observations from 2017, leaving us with a total of 17342 
;  observations. Each entry in the dataset is a list of the form 
;  ‘(timestamp  cnt  t1  t2  hum  wind-speed  weather-code  is-holiday  is-weekend  season). 
;  To better understand the trend and patterns, we split the original dataset into subcategories and examined the differences 
;  between these subcategories of data. We created subcategories based on timestamp such that we categorized the data into 
;  morning rush, evening rush, day-time, night and mid-night. By a similar approach, we also created subcategories based on 
;  season, is-holiday and is-weekend.

;数据
; 我们在此项目中使用的数据集可直接从kaggle网站下载：https://www.kaggle.com/hmavrodiev/london-bike-sharing-dataset，该数据集最初是从3个
; 来源获得的：1）https://cycling .data.tfl.gov.uk/（用于自行车数据）； 2）freemeteo.com（用于天气数据）； 3）https://www.gov.uk/bank
; （用于节假日数据）。该数据集按小时分组，因此我们可以获得有关每小时发生的新单车份额的信息，以及按小时分组的时间戳和其他因素。此数据集涵盖从1/1/2015
; 到1/3/2017的两年时间。总共有17414个观测值。为了平衡数据集，我们删除了2017年以来的观测值，总共剩下17342个观测值。数据集中的每个条目都是以下列形式
; 排列：'(时间戳  单车数  实际温度  体感温度  湿度  风速  天气代码  是否节假日  是否周末  季节）。 
; 为了更好地了解趋势和模式，我们将原始数据集划分为子类别并检查了差异在这些数据子类别之间。我们根据时间戳创建了子类别，以便将数据分类为早高峰，晚高峰，
; 白天，黑夜和深夜。通过类似的方法，我们还创建了其他子类别比如季节、假日和周末。

;Algorithm and Implementation
;  The first procedure written is called “not-2017?”, which is to clean the dataset by dropping all data in 2017. We then 
;  defined a few predicates based on season, is-holiday and is-weekend, to help us filter the data as we try to create 
;  subcategories. 
;  After defining the predicates, we wrote a procedure called “describe-cnt-mean-min-max” to see the mean, minimum, and maximum 
;  of cnt for each subcategories of data, which is used to calculate the values in Table 2. 
;  Before visualizing the data, we divide the dataset into 5 time categories. We wrote a time-categories procedure to see if an 
;  entry lies in "morning traffic", "evening traffic", "evening", "night and early morning", or "regular time". Then we filtered 
;  the original dataset and created 5 datasets under these different time categories. 
;  Then we wrote var1-var2 to create a list of pairs, where all values of var1 and var2 are paired. Then We built a recursive 
;  procedure to show the mean values of var2 related to each value of var1. Next, we created filtered-var1-var2-mean where we 
;  added parameter "lst". By doing this, we could change the input file. So far, we could plot the scatterplots to see the 
;  correlations simply by changing the input strings and files.
;  There were also correlations that we wanted to visualize by seeing histograms, so we built hist-var1-var2-mean which works 
just like the scatter-plot procedure that we could change the input strings and files to see the correlations between two 
variables. Specially, we wanted to see the correlation between average counts and the 5 time categories, so we built a 
recursive procedure tally-cnt to count the total number of bike rentals under each time category and dividing the numbers 
by the length of different files to get the average counts. Then we could plot the histograms by listing 5 pairs. 

;算法与实现

<img src="https://github.com/zzyylliu/misc-projects/blob/master/%E5%85%B1%E4%BA%AB%E5%8D%95%E8%BD%A6%E6%95%B0%E6%8D%AE%E5%8F%AF%E8%A7%86%E5%8C%96/images/hist-time-catg.png" height="300">
