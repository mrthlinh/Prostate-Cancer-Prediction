# Description
Predict Prostate Cancer with various linear models

  - Usual least squares
  - Ridge regression
  - Lasso
  - Best-subset selection
  - PCR
  - and PLS

**Data**: Prostate Cancer data available in *ElemStatLearn* package as *prostate*. Features are as follows

- lpsa: log PSA score ( less or equal 4 is considered normal)
- lcavol: log cancer volume
- lweight: log prostate weight
- age: age of patient
- lbph: log of the amount of benign prostatic hyperplasia
- svi: seminal vesicle invasion
- lcp: log of capsular penetration
- gleason: Gleason score
- pgg45: percent of Gleason scores 4 or 5

# EDA
**Histogram**

|![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/his-lcavol.png)| ![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/his-lweight.png) | ![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/his-age.png) | ![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/his-lbph.png) |
|:---:|:---:|:---:|:---:|
|![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/his-svi.png)| ![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/his-lcp.png) | ![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/his-gleason.png) | ![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/his-pgg45.png) |

What we can see from these distributions:
 - lcavol,lweight and lpsa look like a normal distribution
 - lcp, pgg45 and lbph are highly right-skewed. It indicates that most of diagnosis are at low level.
 - Age distribution points out most of men are over 60 years old, however as shown above, most of their diagnoses are not critical.

Now let’s investigate the correlations between variables

![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/corr.png)

|     | lcavol | lweight | age | lbph | svi | lcp | gleason | pgg45 | lpsa |
|:---:|:---:|:---:|:---:|:--:|:--:|:--:|:--:|:--:|:--:|
|lcavol |1.000      |0.281| 0.225|  0.027|  0.539|  0.675|   0.432| 0.434| 0.734|
|lweight|0.281    |1.000| 0.348|  0.442|  0.155|  0.165|   0.057| 0.107| 0.433|
|age    |0.225    |0.348| 1.000|  0.350|  0.118|  0.128|   0.269| 0.276| 0.170|
|lbph   |0.027    |0.442  |0.350  |1.000 |-0.086 |-0.007   |0.078 |0.078 |0.180|
|svi    |0.539   |0.155  | 0.118| -0.086|  1.000|  0.673|   0.320| 0.458| 0.566|
|lcp    |0.675   |0.165  | 0.128| -0.007|  0.673|  1.000|   0.515| 0.632| 0.549|
|gleason|0.432   | 0.057 | 0.269|  0.078|  0.320|  0.515|   1.000| 0.752| 0.369|
|pgg45  |0.434   |  0.107| 0.276|  0.078|  0.458|  0.632|   0.752| 1.000| 0.422|
|lpsa   |0.734   |   0.433| 0.170|  0.180|  0.566|  0.549|   0.369| 0.422| 1.000|

**Top 4 correlations**
1. "pgg45" and "gleason"
2. "lpsa" and  "lcavol"
3. "lcp" and "lcavol"
4. "lcp" and "svi"

**Observation**
 - “pgg45” and “gleason” are very obvious because “pgg45” is percent of Gleason scores 4 or 5.
 - “lcavol” (log cancer volume) is supposed to play a key role in predict “lpsa”
 - log amount of capsular penetration “lcp”, and the log cancer volume “lcavol” are pretty related.
 - This is interesting, we plot a boxplot to see the difference between svi = 0,1 against “lcp”. It seems there are much difference of log capsular penetration between svi = 0 and svi = 1

 ![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/boxplot-lcp-svi.png)

- Let’s investigate how “svi” relates to “lcavol” and “lpsa” by constructing boxplot and take a simple t-test to see whether “svi” (seminal vesicle invasion) can distinguish patient with low and high “cancer volume” and “PSA score”. The test is strongly against our hypothesis that “there is no much difference in term of lcavol and lpsa between two types of svi. Hence, we can rely on svi when predicting lcavol and lpsa.

|![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/boxplot-lcavol-svi.png)|![](https://github.com/mrthlinh/Prostate-Cancer-Prediction/blob/master/pic/boxplot-lpsa-svi.png)|
|:--:|:--:|
|95 percent confidence interval: -2.047129 -1.110409|95 percent confidence interval: -1.917326 -1.150810|

# Results
|Term|LS|Best subset	Ridge	Lasso	PCR (8  ncomp)	PLS (7 ncomp)
Intercept	0.181561	0.494154754
	0.001797776
	0.180062440
	0	0
lcavol	0.564341279	0.569546032
	0.486656952
	0.560672762
	0.66514667
	0.66490149

lweight	0.622019787
	0.614419817	0.602120681	0.618795888	0.26648026	0.26713102
age	-0.021248185
	-0.020913467	-0.016371775	-0.020638683 	-0.15819522	-0.15827786
lbph	0.096712523
	0.097352535
	0.084976632
	0.095170395
	0.14031117
	0.13976404

svi	0.761673403
	0.752397342
	0.679825448
	0.750853157
	0.31532888
	0.31530989

lcp	-0.106050939	-0.104959408  	-0.035114327  	-0.098467238	-0.14828568	-0.14851785    

gleason	0.049227933
		0.064628095  	0.047253050
	0.03554917
	0.03590506
pgg45	0.004457512 	0.005324465	0.003351914	0.004310552
	0.12571982
	0.12575997
Test Error
	0.5521303
	0.5428351
 	0.5391117
 	0.5514344
 	0.5651155
	0.5650907
