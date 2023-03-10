#Packages
install.packages("twitteR")
install.packages("dplyr")
install.packages("tidyr")
install.packages("plotly")
install.packages("ggplot2")
install.packages("RColorBrewer")
install.packages("tidytext")
install.packages("rtweet")
install.packages("tm")
install.packages("slam")
install.packages("wordcloud")
install.packages("wordcloud2")
install.packages("corpus")

#libraries
library(twitteR)
library(dplyr)
library(tidyr)
library(plotly)
library(ggplot2)
library(RColorBrewer)
library(tidytext)
library(rtweet)
library(tm)
library(slam)
library(wordcloud)
library(wordcloud2)
library(corpus)

#Extract from twitter using your developer's credentials.Choose any keyword you want.
CONSUMER_SECRET <- "3Qc7R1DNGW32hzXXJFZoOyWyDMAMh05MC5RVDt4SY6JKtUb9kw"
CONSUMER_KEY <- "DKCugN5aVwJGDxS5fM8SvqyHz"
ACCESS_SECRET <- "TrGLcnSdYbgQL8bu0orXaqptx868NErd0sXSEunZddwHc"
ACCESS_TOKEN <- "1595258199812153344-N86DEcAhSSZJay5r6rDP5j3oy4iUWt"

setup_twitter_oauth(consumer_key = CONSUMER_KEY,
                    consumer_secret = CONSUMER_SECRET,
                    access_token = ACCESS_TOKEN,
                    access_secret = ACCESS_SECRET)


trendTweets <- searchTwitter("#food -filter:retweets",
                             n = 10000,
                             maxID = NULL,
                             lang = "en",
                             since = "2022-12-14",
                             until = "2022-12-21",
                             retryOnRateLimit=120)
trendTweets

trendTweetsDF <- twListToDF(trendTweets)
View(trendTweetsDF)
head(trendTweetsDF, n= 5)
names(trendTweetsDF)
class(trendTweetsDF)
data_text <- head(trendTweetsDF$text)[1:5]
data_text

save(trendTweetsDF,file= "trendTweetsDF.Rdata")
load(file= "trendTweetsDF.Rdata")

sapply(trendTweetsDF, function(x) sum(is.na(x)))

trending_twt <- trendTweetsDF %>% 
  select(screenName, text, created, statusSource)

#Plot time series from the date created. with legends.   
ggplot(data = trendTweetsDF, aes(x = created)) + geom_histogram(aes(fill = ..count..)) +
  xlab("Time") + ylab("Number of Tweets") +
  scale_fill_gradient(low = "coral", high = "cyan") +
  theme(legend.position = "right")

#Plot a graph (any graph you want)  based on the type of device - found in Source - that the user use. Include the legends.
TypeofDevices <- function(x) {
  if(grepl(">Twitter for iPhone</a>", x)){
    "iphone"
  }else if(grepl(">Twitter for iPad</a>", x)){
    "ipad"
  }else if(grepl(">Twitter for Android</a>", x)){
    "android"
  } else if(grepl(">Twitter Web Client</a>", x)){
    "Web"
  } else if(grepl(">Twitter for Windows Phone</a>", x)){
    "windows phone"
  }else if(grepl(">dlvr.it</a>", x)){
    "dlvr.it"
  }else if(grepl(">IFTTT</a>", x)){
    "ifttt"
  }else if(grepl(">Facebook</a>", x)){  
    "facebook"
  }else {
    "others"
  }
}
trendTweetsDF$tweetSource = sapply(trendTweetsDF$statusSource, TypeofDevices)

trends_Source <- trendTweetsDF %>% select(tweetSource) %>%
  group_by(tweetSource) %>% summarize(count=n()) %>%
  arrange(desc(count)) 

Device_Source <- subset(trends_Source, count >10)


data_Source <- data.frame(category = trends_Source$tweetSource,
                          count = trends_Source$count)

data_Source$fraction = data_Source$count / sum(data_Source$count)
data_Source$percentage = data_Source$count / sum(data_Source$count) * 100
data_Source$ymax = cumsum(data_Source$fraction)
data_Source$ymin = c(0, head(data_Source$ymax, n=-1))
data_Source$roundP = round(data_Source$percentage, digits = 2)

Device_Source <- paste(data_Source$category, data_Source$roundP, "%")

ggplot(trendTweetsDF[trendTweetsDF$tweetSource != 'others',], aes(tweetSource, fill = tweetSource)) +
  geom_bar() +
  theme(legend.position="right",
        axis.title.x = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  ylab("Number of tweets") +
  ggtitle("Type of Device that Users Use")

#Create a wordcloud from the screenName.
screen_name <- trendTweetsDF %>%
  select(screenName) %>%
  group_by(screenName) %>%
  summarize(count=n()) %>%
  arrange(desc(count)) 

corpus_file <- Corpus(VectorSource(trendTweetsDF$screenName))  
class(trendTweetsDF$screenName)

wordcloud2(data=screen_name, size=2, color='random-dark',
           shape = 'circle', backgroundColor="cyan")


