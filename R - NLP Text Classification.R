---
title: "R Notebook"
output: html_notebook
---

### LIBRARY
```{r}
library("kernlab") 
library("caret") 
library("tm") 
library("dplyr") 
library("splitstackshape")
library("e1071")
library("readxl")
library("xlsx")

```

###
```{r}
data = read_excel("DATA.xlsx")

data = data[,c(-1,-4)]


colnames(data) <- c("text", "tag")
data$text = as.factor(data$text)
data$tag =  as.factor(data$tag)

trainObs <- sample(nrow(data), .7 * nrow(data), replace = FALSE)
testObs <- sample(nrow(data), .3 * nrow(data), replace = FALSE)
train <- data[trainObs,]
test <- data[testObs,]


train <- VCorpus(VectorSource(train$text),readerControl=list(language="English"))
train <- tm_map(train, content_transformer(stripWhitespace))
train <- tm_map(train, content_transformer(tolower))
train <- tm_map(train, content_transformer(removeNumbers))
train <- tm_map(train, content_transformer(removePunctuation))
train <- tm_map(train, removeWords, stopwords("english"))
train <- tm_map(train, stemDocument)

train.dtm <- as.matrix(DocumentTermMatrix(train, control=list(wordLengths=c(1,Inf))))



test <- VCorpus(VectorSource(test$text),readerControl=list(language="English"))
test <- tm_map(test, content_transformer(stripWhitespace))
test <- tm_map(test, content_transformer(tolower))
test <- tm_map(test, content_transformer(removeNumbers))
test <- tm_map(test, content_transformer(removePunctuation))
test <- tm_map(test, removeWords, stopwords("english"))
test <- tm_map(test, stemDocument)

test.dtm <- as.matrix(DocumentTermMatrix(test, control=list(wordLengths=c(1,Inf))))


train.df <- data.frame(train.dtm[,intersect(colnames(train.dtm), colnames(test.dtm))])
test.df <- data.frame(test.dtm[,intersect(colnames(test.dtm), colnames(train.dtm))])

train <- data[trainObs,]
test <- data[testObs,]

train.df$tag<- train$tag
test.df$tag <- test$tag
```

```{r}
set.seed(123)

df.train <- train.df
df.test <- test.df
df.model<-ksvm(tag~., data= df.train, kernel="rbfdot")
df.pred<-predict(df.model, df.test)
con.matrix<-confusionMatrix(df.pred, df.test$tag)
print(con.matrix)

```

```{r}


October = read_excel("DATA.xlsx")
October = October[,2]


#data = read_excel("DATA.xlsx")

#data = data[,c(-1,-4)]

colnames(October) <- c("text")
October$text = as.factor(October$text)


data = read_excel("DATA.xlsx")

data = data[,c(-1,-4,-5)]

colnames(data) <- c("text", "tag")
data$text = as.factor(data$text)
data$tag =  as.factor(data$tag)


train <- VCorpus(VectorSource(data$text),readerControl=list(language="English"))
train <- tm_map(train, content_transformer(stripWhitespace))
train <- tm_map(train, content_transformer(tolower))
train <- tm_map(train, content_transformer(removeNumbers))
train <- tm_map(train, content_transformer(removePunctuation))
train <- tm_map(train, removeWords, stopwords("english"))
train <- tm_map(train, stemDocument)

train.dtm <- as.matrix(DocumentTermMatrix(train, control=list(wordLengths=c(1,Inf))))


test <- VCorpus(VectorSource(October$text),readerControl=list(language="English"))
test <- tm_map(test, content_transformer(stripWhitespace))
test <- tm_map(test, content_transformer(tolower))
test <- tm_map(test, content_transformer(removeNumbers))
test <- tm_map(test, content_transformer(removePunctuation))
test <- tm_map(test, removeWords, stopwords("english"))
test <- tm_map(test, stemDocument)

test.dtm <- as.matrix(DocumentTermMatrix(test, control=list(wordLengths=c(1,Inf))))


train.df <- data.frame(train.dtm[,intersect(colnames(train.dtm), colnames(test.dtm))])
test.df <- data.frame(test.dtm[,intersect(colnames(test.dtm), colnames(train.dtm))])


train.df$tag<- data$tag



df.train <- train.df
df.test <- test.df
df.model<-ksvm(tag~., data= df.train, kernel="rbfdot")
df.pred<-predict(df.model, df.test)

outputs <- print(df.pred)

```




```{r}
combined <- cbind(October, df.pred)

write.xlsx(combined, file= "PredictedCategories.xlsx", sheetName = "PredictedCategories", append = FALSE)

```










