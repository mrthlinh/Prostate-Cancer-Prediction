# EDA
# Scatter plot
library(ElemStatLearn)

# Part a
# data = prostate
# data.train = data[which(data$train == TRUE),]
data = prostate[,1:9]
# 1. How many predictors, types of predictors quantitive or qualitative, how many observations
dim(data) # 97 observations and 9 predictors,
str(data) # 'train' is a response (logical)
head(data) # view few observations

# 2. Check for missing data
sum(is.na(data)) # counting the number of missing values in the column

# 3. Observa the summary of each predictor / repsonse to have a first glance to the data
# e.g: how many catergory / mean, median, min max
summary(data$lcavol)
summary(data$train)

# Histogram
for (j in 1:9) {
  hist(data[,j], xlab=colnames(data)[j],
       main=paste("Histogram of",colnames(data[j])),
       col="lightblue",breaks=20)
}

# Correlations
pairs(data)

pros.cor = cor(data)
round(pros.cor,3)

pros.cor[upper.tri(pros.cor,diag=T)] = 0
pros.cor.sorted = sort(abs(pros.cor),decreasing=T)

for (i in 1:5){
  vars.big.cor = arrayInd(which(abs(pros.cor)==pros.cor.sorted[i]), 
                          dim(pros.cor))
  print(colnames(data)[vars.big.cor])
}


svi = factor(data$svi)
plot(svi, data$lcp, main="lcp versus svi",xlab="SVI? Yes or no", ylab="log of capsular penetration")

plot(svi, data$lpsa, main="lpsa versus svi",xlab="SVI? Yes or no", ylab="log PSA score")

t.test(data$lpsa[data$svi==0], data$lpsa[data$svi==1])

plot(svi, data$lcavol, main="lcavol versus svi",xlab="SVI? Yes or no", ylab="Log cancer volume")
t.test(data$lcavol[data$svi==0], data$lcavol[data$svi==1])
# round(pros.cor,3)

############################################################
# k-fold cross validation

cv.k.fold = function(formula = lpsa ~ .,data,name,bestlam = 0, k){
  library(glmnet)
  library (pls)
  set.seed(1)
  # formula = as.formula(str.formula)
  
  length = nrow(data)
  size.fold = floor(length / k)
  index = seq(1,length)
  trunc_index = index
  # acc_error = vector("numeric",length = k)
  acc_error = 0
  for (i in 1:k){
    # Get length(data) / 10 random number in index
    sample = sample(trunc_index,size.fold,replace = F)
    # validation set: those data whose index obtained from sampling
    validation = data[sample,]
    
    # train set: the remaining data
    train = data[which(! index %in% sample),]
    
    # train data and predict model with validation set.
    # fit = 0
    # fit.pred = predict(model,validation)
    # if (name == "lm"){
    #   
    # }
    if (name == "glm"){
      fit = glm(formula, data=train)
      fit.pred = predict(fit, s = bestlam, newdata = validation)
    }
    
    x = model.matrix(formula, train)[, -1]
    y = train$lpsa
    x.val = model.matrix(formula, validation)[, -1]
    
    if (name == "ridge"){
      fit = glmnet(x,y,alpha = 0,lambda = bestlam)
      fit.pred = predict(fit, s = bestlam, newx = x.val)
    }
    if (name == "lasso"){
      fit = glmnet(x,y,alpha = 1,lambda = bestlam)
      fit.pred = predict(fit, s = bestlam, newx = x.val)
    }
    if (name == "pcr"){
      fit = pcr(formula, data = train , scale =TRUE ,validation ="CV")
      fit.pred = predict(fit ,x.val, ncomp = bestlam)
    }
    if (name == "pls"){
      fit = plsr(formula, data = train , scale =TRUE ,validation ="CV")
      fit.pred = predict(fit ,x.val, ncomp = bestlam)
    }
    
    
    acc_error = acc_error + mean((fit.pred - validation[, 9])^2)
    
    
    # truncate index
    trunc_index = trunc_index[! trunc_index %in% sample]
  }
  
  MSE = acc_error / k
  return(MSE)
}

###############################################


# ------------------------- PART B -----------------------------------

# Fit a linear model with all predictors using the usual least squares

model.LQ = lm(lpsa ~ ., data)
summary(model.LQ)

# Estimate the test error using 10-fold cross validation
err.LQ = cv.k.fold(data = data,name = "glm",k=10)
err.LQ
# --------------------------------------------------------------------

# ------------------------ PART C ------------------------------------

# Repeat (b) using best-subset selection

library(leaps)
par(mfrow = c(1, 1))
model.BSS = regsubsets(lpsa ~ ., data) #need to add nvmax in case you want more predictors
model.BSS.summary =  summary(model.BSS)

# Plot Adjusted R^2 against number of variables and pick the best num of variables
plot(model.BSS.summary$adjr2, xlab = "Number of Variables", ylab = "Adjusted RSq", type = "l")
optimal.var = which.max(model.BSS.summary$adjr2)
points(optimal.var, model.BSS.summary$adjr2[optimal.var], col = "red", cex = 2, pch = 20)

plot(model.BSS, scale = "adjr2")

# Get coefficients of best model for a given size
coefi = coef(model.BSS, optimal.var)

# Fit model with selected variables
model.BSS = lm(lpsa ~ .-gleason,data)
summary(model.BSS)

# Estimate the test error using 10-fold cross validation
err.BSS = cv.k.fold(lpsa ~ .-gleason,data=data,name = "glm",k=10)
err.BSS
# --------------------------------------------------------------------

# ------------------------ PART D ------------------------------------
# part d: Ridge regression
library(glmnet)

# Set up a grid of lambda values (from 10^10 to 10^(-2)) in decreasing sequence
grid = 10^seq(10, -2, length = 100)

# Fit ridge regression for each lambda on the grid
x = model.matrix(lpsa ~ ., data)[, -1]
y = data$lpsa
ridge.mod = glmnet(x, y, alpha = 0, lambda = grid)

plot(ridge.mod, xvar = "lambda")

# Use cross-validation to estimate test MSE from training data
set.seed(1)
cv.out = cv.glmnet(x, y, alpha = 0)
plot(cv.out)

bestlam.ridge = cv.out$lambda.min


# out = glmnet(x,y,alpha = 0,lambda = bestlam)
out = glmnet(x,data$lpsa,alpha = 0)
# out = glmnet(x,y,alpha = 0)
predict(out , type ="coefficients",s= bestlam.ridge)[1:9,]

# Calculate the error
err.ridge = cv.k.fold(lpsa ~ .,data=data,name = "ridge",bestlam = bestlam.ridge,k=10)
err.ridge
# --------------------------------------------------------------------
# ------------------------ PART E ------------------------------------
# part e: Lasso

lasso.mod = glmnet(x, y, alpha = 1, lambda = grid)

plot(lasso.mod, xvar = "lambda")

# Use cross-validation to estimate test MSE from training data
set.seed(1)
cv.out = cv.glmnet(x, y, alpha = 1)

plot(cv.out)
bestlam.lasso = cv.out$lambda.min

# lasso.pred = predict(lasso.mod, s = bestlam.lasso, newx = x)

out = glmnet(x,y,alpha = 1)
predict(out , type ="coefficients",s= bestlam.lasso)[1:9,]

err.lasso = cv.k.fold(lpsa ~ .,data=data,name = "lasso",bestlam = bestlam.lasso,k=10)
err.lasso

# --------------------------------------------------------------------
# ------------------------ PART F ------------------------------------
# Part f: PCR
library (pls)
set.seed(2)
pcr.fit = pcr(lpsa ~ ., data = data , scale =TRUE ,validation ="CV")
summary(pcr.fit)

validationplot(pcr.fit ,val.type ="MSEP")

optimal.pcr.ncomp = as.numeric(which.min(MSEP(pcr.fit)$val[1, 1,]) - 1)

err.pcr = cv.k.fold(lpsa ~ .,data=data,name = "pcr",bestlam = optimal.pcr.ncomp,k=10)
err.pcr
pcr.fit$coefficients[,,optimal.pcr.ncomp]

coefi = pcr.fit$coefficients[,,optimal.pcr.ncomp]
test.mat <- model.matrix(lpsa ~ ., data = data)
# coefi = coef(fit.best, id = i) # Coefficients of best model of size i
pred = test.mat[, names(coefi)] %*% coefi # Predictions from this model
intercept = mean(data[,9] - pred)
# --------------------------------------------------------------------
# ------------------------ PART G ------------------------------------
# Part g: PLS
pls.fit = plsr(lpsa ~ ., data = data , scale =TRUE ,validation ="CV")
summary(pls.fit)

validationplot(pls.fit ,val.type ="MSEP")

MSEP(pls.fit)
sqrt(MSEP(pls.fit)$val[1, 1,])
which.min(MSEP(pls.fit)$val[1, 1,])

optimal.pls.ncomp = as.numeric(which.min(MSEP(pls.fit)$val[1, 1,]) - 1)

err.pls = cv.k.fold(lpsa ~ .,data=data,name = "pls",bestlam = optimal.pls.ncomp,k=10)
err.pls
pls.fit$coefficients[,,optimal.pls.ncomp]

